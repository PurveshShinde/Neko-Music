package neko.music.app.listentogether

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

@Serializable
data class ListenTogetherServer(
  val name: String,
  val url: String,
  val location: String,
  val operator: String
)

object ListenTogetherServers {
  private val SERVER_JSON_URL =
    neko.music.app.config.NekoUpdateConfig.SERVER_JSON_URL

  private val DEFAULT_SERVER =
    ListenTogetherServer(
      name = "MetroList Server",
      url = "wss://metroserverx.meowery.eu/ws",
      location = "Poland",
      operator = "MetroList"
    )

  private val _servers = MutableStateFlow<List<ListenTogetherServer>>(listOf(DEFAULT_SERVER))

  val serversFlow: StateFlow<List<ListenTogetherServer>> = _servers

  val servers: List<ListenTogetherServer>
    get() = _servers.value

  init {
    GlobalScope.launch(Dispatchers.IO) {
      if (!neko.music.app.config.NekoUpdateConfig.isConfigured) return@launch
      try {
        val client = okhttp3.OkHttpClient()
        val request = okhttp3.Request.Builder().url(neko.music.app.config.NekoUpdateConfig.SERVER_JSON_URL).build()
        val response = client.newCall(request).execute()
        response.body?.string()?.let { jsonString ->
          val jsonObject = Json.parseToJsonElement(jsonString).jsonObject
          val name = jsonObject["name"]?.jsonPrimitive?.content ?: DEFAULT_SERVER.name
          val url =
            jsonObject["serverUrl"]?.jsonPrimitive?.content
              ?: DEFAULT_SERVER.url
          val region = jsonObject["region"]?.jsonPrimitive?.content ?: DEFAULT_SERVER.location

          _servers.value =
            listOf(ListenTogetherServer(name = name, url = url, location = region, operator = "MetroList"))
        }
      } catch (e: Exception) {
        // Fallback to default server retained
      }
    }
  }

  val defaultServerUrl: String
    get() = servers.firstOrNull()?.url ?: DEFAULT_SERVER.url

  fun findByUrl(url: String): ListenTogetherServer? = servers.firstOrNull { it.url == url }
}
