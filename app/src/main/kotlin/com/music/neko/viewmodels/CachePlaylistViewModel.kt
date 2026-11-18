package neko.music.app.viewmodels

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.media3.datasource.cache.SimpleCache
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import neko.music.app.constants.HideExplicitKey
import neko.music.app.constants.HideVideoSongsKey
import neko.music.app.db.MusicDatabase
import neko.music.app.db.entities.Song
import neko.music.app.di.DownloadCache
import neko.music.app.di.PlayerCache
import neko.music.app.extensions.filterExplicit
import neko.music.app.extensions.filterVideoSongs
import neko.music.app.utils.dataStore
import neko.music.app.utils.get
import java.time.LocalDateTime
import javax.inject.Inject
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class CachePlaylistViewModel
@Inject
constructor(
  @ApplicationContext private val context: Context,
  private val database: MusicDatabase,
  @PlayerCache private val playerCache: SimpleCache,
  @DownloadCache private val downloadCache: SimpleCache
) : ViewModel() {

  private val _cachedSongs = MutableStateFlow<List<Song>>(emptyList())
  val cachedSongs: StateFlow<List<Song>> = _cachedSongs

  init {
    viewModelScope.launch {
      while (true) {
        val hideExplicit = context.dataStore.get(HideExplicitKey, false)
        val hideVideoSongs = context.dataStore.get(HideVideoSongsKey, false)
        val cachedIds = playerCache.keys.toSet()
        val downloadedIds = downloadCache.keys.toSet()
        val pureCacheIds = cachedIds.subtract(downloadedIds)

        val songs =
          if (pureCacheIds.isNotEmpty()) {
            database.getSongsByIds(pureCacheIds.toList())
          } else {
            emptyList()
          }

        val completeSongs =
          songs.filter {
            val contentLength = it.format?.contentLength
            contentLength != null && playerCache.isCached(it.song.id, 0, contentLength)
          }

        if (completeSongs.isNotEmpty()) {
          database.query {
            completeSongs.forEach {
              if (it.song.dateDownload == null) {
                update(it.song.copy(dateDownload = LocalDateTime.now()))
              }
            }
          }
        }

        _cachedSongs.value =
          completeSongs
            .filter { it.song.dateDownload != null }
            .sortedByDescending { it.song.dateDownload }
            .filterExplicit(hideExplicit)
            .filterVideoSongs(hideVideoSongs)

        delay(1000)
      }
    }
  }

  fun removeSongFromCache(songId: String) {
    playerCache.removeResource(songId)
  }
}
