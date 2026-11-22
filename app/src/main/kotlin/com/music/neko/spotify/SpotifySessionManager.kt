/** vivimusic Project (C) 2026 Licensed under GPL-3.0 | See git history for contributors */
package neko.music.app.spotify

import android.content.Context
import androidx.datastore.preferences.core.edit
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import neko.music.app.constants.*
import neko.music.app.spotify.models.SpotifySession
import neko.music.app.utils.dataStore
import neko.music.app.utils.reportException
import timber.log.Timber

object SpotifySessionManager {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    private const val TOKEN_EXPIRY_GRACE_MS = 60_000L

    suspend fun getSession(context: Context): SpotifySession? = withContext(Dispatchers.IO) {
        val prefs = context.dataStore.data.first()
        val sessionJson = prefs[SpotifySessionKey]
        if (!sessionJson.isNullOrBlank()) {
            try {
                return@withContext json.decodeFromString<SpotifySession>(sessionJson)
            } catch (e: Exception) {
                Timber.e(e, "Failed to decode SpotifySession JSON")
            }
        }

        // Migration from legacy fragmented preferences
        val legacySpDc = prefs[SpotifySpDcKey].orEmpty()
        if (legacySpDc.isNotBlank()) {
            val migrated = SpotifySession(
                spDc = legacySpDc,
                spKey = prefs[SpotifySpKeyKey],
                accessToken = prefs[SpotifyAccessTokenKey],
                expiresAt = prefs[SpotifyAccessTokenExpiresAtKey] ?: 0L,
                accountName = prefs[SpotifyAccountNameKey],
                accountAvatarUrl = prefs[SpotifyAccountAvatarUrlKey]
            )
            saveSession(context, migrated)
            return@withContext migrated
        }

        null
    }

    suspend fun saveSession(context: Context, session: SpotifySession) = withContext(Dispatchers.IO) {
        context.dataStore.edit { prefs ->
            prefs[SpotifySessionKey] = json.encodeToString(session)
            // Synchronize legacy keys so any remaining legacy consumers work without interruption
            prefs[SpotifySpDcKey] = session.spDc
            if (!session.spKey.isNullOrBlank()) {
                prefs[SpotifySpKeyKey] = session.spKey
            } else {
                prefs.remove(SpotifySpKeyKey)
            }
            if (!session.accessToken.isNullOrBlank()) {
                prefs[SpotifyAccessTokenKey] = session.accessToken
                prefs[SpotifyAccessTokenExpiresAtKey] = session.expiresAt
            }
            if (!session.accountName.isNullOrBlank()) {
                prefs[SpotifyAccountNameKey] = session.accountName
            }
            if (!session.accountAvatarUrl.isNullOrBlank()) {
                prefs[SpotifyAccountAvatarUrlKey] = session.accountAvatarUrl
            }
        }
    }

    suspend fun clearSession(context: Context) = withContext(Dispatchers.IO) {
        context.dataStore.edit { prefs ->
            prefs.remove(SpotifySessionKey)
            prefs.remove(SpotifySpDcKey)
            prefs.remove(SpotifySpKeyKey)
            prefs.remove(SpotifyAccessTokenKey)
            prefs.remove(SpotifyAccessTokenExpiresAtKey)
            prefs.remove(SpotifyAccountNameKey)
            prefs.remove(SpotifyAccountAvatarUrlKey)
        }
        Spotify.accessToken = null
    }

    suspend fun getValidAccessToken(context: Context): String? = withContext(Dispatchers.IO) {
        val session = getSession(context) ?: return@withContext null

        if (!session.accessToken.isNullOrBlank() && session.expiresAt > System.currentTimeMillis() + TOKEN_EXPIRY_GRACE_MS) {
            Spotify.accessToken = session.accessToken
            return@withContext session.accessToken
        }

        // Refresh token
        if (session.spDc.isBlank()) return@withContext null

        try {
            val token = SpotifyAuth.fetchAccessToken(session.spDc, session.spKey.orEmpty()).getOrThrow()
            Spotify.accessToken = token.accessToken

            val updatedSession = session.copy(
                accessToken = token.accessToken,
                expiresAt = token.accessTokenExpirationTimestampMs,
            )
            saveSession(context, updatedSession)
            token.accessToken
        } catch (e: Exception) {
            Timber.e(e, "Failed to refresh Spotify access token")
            null
        }
    }
}

