package neko.music.app.models

import com.music.innertube.models.YTItem
import neko.music.app.db.entities.LocalItem

data class SimilarRecommendation(
  val title: LocalItem,
  val items: List<YTItem>,
)
