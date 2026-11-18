package neko.music.app.db.entities

import com.music.neko.metadata.cleaner.MetadataCleaner
import com.music.neko.metadata.models.CleanedMetadata

val SongEntity.cleanedMetadata: CleanedMetadata
  get() = MetadataCleaner.clean(title, "")

val Song.cleanedMetadata: CleanedMetadata
  get() = MetadataCleaner.clean(title, artists.firstOrNull()?.name.orEmpty())

val Song.displayTitle: String
  get() = cleanedMetadata.toDisplayTitle()

val Song.cleanArtistName: String
  get() = cleanedMetadata.primaryArtist
