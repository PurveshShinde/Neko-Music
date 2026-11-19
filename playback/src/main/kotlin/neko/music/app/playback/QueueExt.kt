package neko.music.app.playback

import neko.music.app.extensions.toMediaItem
import neko.music.app.models.MediaMetadata
import neko.music.app.models.PersistQueue
import neko.music.app.models.QueueData
import neko.music.app.models.QueueType
import neko.music.app.playback.queues.ListQueue
import neko.music.app.playback.queues.LocalAlbumRadio
import neko.music.app.playback.queues.Queue
import neko.music.app.playback.queues.YouTubeAlbumRadio
import neko.music.app.playback.queues.YouTubeQueue

fun Queue.toPersistQueue(
  title: String?,
  items: List<MediaMetadata>,
  mediaItemIndex: Int,
  position: Long
): PersistQueue {
  return when (this) {
    is ListQueue ->
      PersistQueue(
        title = title,
        items = items,
        mediaItemIndex = mediaItemIndex,
        position = position,
        queueType = QueueType.LIST
      )
    is YouTubeQueue -> {

      val endpoint = "youtube_queue"
      PersistQueue(
        title = title,
        items = items,
        mediaItemIndex = mediaItemIndex,
        position = position,
        queueType = QueueType.YOUTUBE,
        queueData = QueueData.YouTubeData(endpoint = endpoint)
      )
    }
    is YouTubeAlbumRadio -> {

      PersistQueue(
        title = title,
        items = items,
        mediaItemIndex = mediaItemIndex,
        position = position,
        queueType = QueueType.YOUTUBE_ALBUM_RADIO,
        queueData = QueueData.YouTubeAlbumRadioData(playlistId = "youtube_album_radio")
      )
    }
    is LocalAlbumRadio -> {

      PersistQueue(
        title = title,
        items = items,
        mediaItemIndex = mediaItemIndex,
        position = position,
        queueType = QueueType.LOCAL_ALBUM_RADIO,
        queueData = QueueData.LocalAlbumRadioData(albumId = "local_album_radio", startIndex = 0)
      )
    }
    else ->
      PersistQueue(
        title = title,
        items = items,
        mediaItemIndex = mediaItemIndex,
        position = position,
        queueType = QueueType.LIST
      )
  }
}

fun PersistQueue.toQueue(): Queue {
  return when (queueType) {
    is QueueType.LIST ->
      ListQueue(
        title = title,
        items = items.map { it.toMediaItem() },
        startIndex = mediaItemIndex,
        position = position
      )
    is QueueType.YOUTUBE -> {

      ListQueue(
        title = title,
        items = items.map { it.toMediaItem() },
        startIndex = mediaItemIndex,
        position = position
      )
    }
    is QueueType.YOUTUBE_ALBUM_RADIO -> {

      ListQueue(
        title = title,
        items = items.map { it.toMediaItem() },
        startIndex = mediaItemIndex,
        position = position
      )
    }
    is QueueType.LOCAL_ALBUM_RADIO -> {

      ListQueue(
        title = title,
        items = items.map { it.toMediaItem() },
        startIndex = mediaItemIndex,
        position = position
      )
    }
  }
}
