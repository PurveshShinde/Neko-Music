package neko.music.app.playback

import neko.music.app.db.entities.SongEntity

interface ISyncUtils {
  fun likeSong(song: SongEntity)
}
