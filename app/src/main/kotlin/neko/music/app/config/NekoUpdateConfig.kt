package neko.music.app.config

/**
 * Central update and repository configuration for Neko Music.
 *
 * To connect your own update releases:
 * 1. Replace [GITHUB_OWNER] with your GitHub username or organization.
 * 2. Replace [GITHUB_REPO] with your GitHub repository name.
 * 3. Ensure your releases publish an APK asset named "nekomusic.apk" (or matching [releaseApkName])
 *    and optionally a "changelog.json".
 */
object NekoUpdateConfig {
  const val GITHUB_OWNER = "NEKO_USERNAME"
  const val GITHUB_REPO = "NEKO_REPOSITORY"

  /**
   * Evaluates true only when valid user/repo coordinates are provided.
   * While false:
   * - Startup auto-update checking is completely disabled.
   * - No background network requests are sent to GitHub or Echo Music.
   * - No false update dialogs or update notifications will appear.
   * - Manual update checking screens gracefully report that the update repository is not yet configured.
   */
  val isConfigured: Boolean
    get() = GITHUB_OWNER != "NEKO_USERNAME" &&
            GITHUB_REPO != "NEKO_REPOSITORY" &&
            GITHUB_OWNER.isNotBlank() &&
            GITHUB_REPO.isNotBlank()

  val REPOSITORY_URL: String
    get() = if (isConfigured) "https://github.com/$GITHUB_OWNER/$GITHUB_REPO" else ""

  val LATEST_RELEASE_API_URL: String
    get() = "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/latest"

  val ALL_RELEASES_API_URL: String
    get() = "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases"

  val COMMITS_API_URL: String
    get() = "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/commits?branch=main&per_page=50"

  val SERVER_JSON_URL: String
    get() = "https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/refs/heads/main/app/server.json"

  fun releaseApkUrl(version: String): String =
    "https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/download/$version/nekomusic.apk"

  fun changelogUrl(tag: String): String =
    "https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/download/$tag/changelog.json"

  /**
   * Correctly compares versions (semantic or dotted integers).
   * Returns true only if [remoteVersion] is strictly newer than [currentVersion].
   */
  fun isNewerVersion(currentVersion: String, remoteVersion: String): Boolean {
    val cleanCurrent = currentVersion.removePrefix("v").removePrefix("b").trim()
    val cleanRemote = remoteVersion.removePrefix("v").removePrefix("b").trim()
    if (cleanCurrent == cleanRemote) return false

    val currentParts = cleanCurrent.split(".", "-").mapNotNull { it.toIntOrNull() }
    val remoteParts = cleanRemote.split(".", "-").mapNotNull { it.toIntOrNull() }

    val length = maxOf(currentParts.size, remoteParts.size)
    for (i in 0 until length) {
      val c = currentParts.getOrElse(i) { 0 }
      val r = remoteParts.getOrElse(i) { 0 }
      if (r > c) return true
      if (r < c) return false
    }
    return false
  }
}

