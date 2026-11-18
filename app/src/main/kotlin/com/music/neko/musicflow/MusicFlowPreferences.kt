package neko.music.app.musicflow

import androidx.datastore.preferences.core.Preferences
import neko.music.app.constants.CanvasThumbnailAnimationKey
import neko.music.app.constants.DataSaverEnabledKey
import neko.music.app.constants.MusicFlowAnimatedBackgroundKey
import neko.music.app.constants.MusicFlowAutoNextKey
import neko.music.app.constants.MusicFlowAutoplayKey
import neko.music.app.constants.MusicFlowCellularPrefetchKey
import neko.music.app.constants.MusicFlowEnabledKey
import neko.music.app.constants.MusicFlowHideRecentKey
import neko.music.app.constants.MusicFlowLyricsKey

data class MusicFlowPreferences(
  val enabled: Boolean = true,
  val autoplay: Boolean = true,
  val autoNext: Boolean = true,
  val animatedBackground: Boolean = false,
  val lyrics: Boolean = true,
  val cellularPrefetch: Boolean = true,
  val hideRecent: Boolean = true,
  val dataSaver: Boolean = false,
) {
  companion object {
    fun from(preferences: Preferences) =
      MusicFlowPreferences(
        enabled = preferences[MusicFlowEnabledKey] ?: true,
        autoplay = preferences[MusicFlowAutoplayKey] ?: true,
        autoNext = preferences[MusicFlowAutoNextKey] ?: true,
        animatedBackground =
          preferences[MusicFlowAnimatedBackgroundKey]
            ?: preferences[CanvasThumbnailAnimationKey]
            ?: false,
        lyrics = preferences[MusicFlowLyricsKey] ?: true,
        cellularPrefetch = preferences[MusicFlowCellularPrefetchKey] ?: true,
        hideRecent = preferences[MusicFlowHideRecentKey] ?: true,
        dataSaver = preferences[DataSaverEnabledKey] ?: false,
      )
  }
}
