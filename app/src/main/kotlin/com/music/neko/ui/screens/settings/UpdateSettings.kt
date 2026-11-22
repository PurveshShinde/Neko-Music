package neko.music.app.ui.screens.settings

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarScrollBehavior
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import neko.music.app.BuildConfig
import neko.music.app.LocalPlayerAwareWindowInsets
import neko.music.app.R
import neko.music.app.echomusic.component.UpdateAvailableDialog
import neko.music.app.echomusic.component.UpdateInfoDialog
import neko.music.app.echomusic.updater.autoClearOldApks
import neko.music.app.echomusic.updater.getAutoUpdateCheckSetting
import neko.music.app.echomusic.updater.getBetaUpdatesSetting
import neko.music.app.echomusic.updater.getDownloadedApkCount
import neko.music.app.echomusic.updater.getUpdateAvailableState
import neko.music.app.echomusic.updater.getUpdateNotificationsSetting
import neko.music.app.echomusic.updater.saveUpdateAvailableState
import kotlinx.coroutines.launch
import neko.music.app.ui.component.IconButton
import neko.music.app.ui.component.Material3SettingsGroup
import neko.music.app.ui.component.Material3SettingsItem
import neko.music.app.ui.utils.backToMain
import neko.music.app.ui.utils.parseMarkdownToSections
import neko.music.app.ui.utils.parseSimpleMarkdown
import org.json.JSONObject

/**
 * Settings screen for managing app updates, checking for new releases, and displaying the latest
 * release notes ("What's New").
 *
 * @param navController Navigation controller for screen transitions.
 * @param scrollBehavior Top app bar scroll behavior.
 * @param highlightKey Optional key to highlight a specific settings item.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UpdateSettings(
  navController: NavController,
  scrollBehavior: TopAppBarScrollBehavior,
  highlightKey: String? = null
) {
  val scrollState = androidx.compose.foundation.rememberScrollState()

  val context = LocalContext.current
  val coroutineScope = androidx.compose.runtime.rememberCoroutineScope()
  var autoUpdateEnabled by remember { mutableStateOf(getAutoUpdateCheckSetting(context)) }
  var updateNotificationsEnabled by remember {
    mutableStateOf(getUpdateNotificationsSetting(context))
  }
  var betaUpdatesEnabled by remember { mutableStateOf(getBetaUpdatesSetting(context)) }
  val isUpdateAvailable =
    neko.music.app.config.NekoUpdateConfig.isConfigured &&
      getUpdateAvailableState(context) &&
      autoUpdateEnabled
  var apkCount by remember { mutableStateOf(getDownloadedApkCount(context)) }
  var showInfoDialog by remember { mutableStateOf(false) }
  var showUpdateDialog by remember { mutableStateOf(false) }
  var updateVersion by remember { mutableStateOf("") }
  var updateChangelog by remember {
    mutableStateOf<List<neko.music.app.echomusic.updater.ChangelogSection>>(emptyList())
  }
  var updateDescription by remember { mutableStateOf<String?>(null) }
  var updateApkUrl by remember { mutableStateOf<String?>(null) }
  var updateSize by remember { mutableStateOf<String?>(null) }
  var releaseNotes by remember { mutableStateOf<String?>(null) }

  LaunchedEffect(Unit) {
    autoClearOldApks(context)
    apkCount = getDownloadedApkCount(context)

    if (neko.music.app.config.NekoUpdateConfig.isConfigured) {
      neko.music.app.echomusic.updater.checkForUpdate(
        context = context,
        onSuccess = { tag, isAvailable, changelog, size, _, description, _, apkUrl ->
          saveUpdateAvailableState(context, isAvailable)
          if (isAvailable) {
            updateVersion = tag
            updateChangelog = changelog
            updateDescription = description
            updateSize = size
            updateApkUrl = apkUrl
          }
        },
        onError = {}
      )

      kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
        try {
          val url =
            java.net.URL(neko.music.app.config.NekoUpdateConfig.LATEST_RELEASE_API_URL)
          val json = url.openStream().bufferedReader().use { it.readText() }
          val targetRelease = JSONObject(json)
          releaseNotes = targetRelease.getString("body")
        } catch (e: Exception) {
          e.printStackTrace()
        }
      }
    }
  }

  if (showInfoDialog) {
    UpdateInfoDialog(onDismiss = { showInfoDialog = false })
  }

  if (showUpdateDialog) {
    UpdateAvailableDialog(
      version = updateVersion,
      changelog = updateChangelog,
      description = updateDescription,
      apkUrl = updateApkUrl,
      fileSize = updateSize,
      onDismiss = { showUpdateDialog = false },
    )
  }

  Column(
    Modifier.windowInsetsPadding(
        LocalPlayerAwareWindowInsets.current.only(WindowInsetsSides.Horizontal)
      )
      .verticalScroll(scrollState)
      .padding(horizontal = 16.dp),
  ) {
    Spacer(
      Modifier.windowInsetsPadding(LocalPlayerAwareWindowInsets.current.only(WindowInsetsSides.Top))
    )

    Spacer(modifier = Modifier.height(16.dp))

    Material3SettingsGroup(
      scrollState = scrollState,
      title = stringResource(R.string.app_updates_title),
      items =
        listOf(
          Material3SettingsItem(
            isHighlighted = (highlightKey == stringResource(R.string.system_update)),
            icon = painterResource(R.drawable.update),
            title = { Text(stringResource(R.string.system_update)) },
            description = {
              if (isUpdateAvailable && neko.music.app.config.NekoUpdateConfig.isConfigured) {
                Text(
                  text = "New update is available",
                  color = androidx.compose.ui.graphics.Color.Red
                )
              } else {
                Text(stringResource(R.string.version, BuildConfig.VERSION_NAME))
              }
            },
            onClick = {
              if (updateVersion.isNotEmpty()) {
                showUpdateDialog = true
              } else if (neko.music.app.config.NekoUpdateConfig.isConfigured) {
                coroutineScope.launch {
                  neko.music.app.echomusic.updater.checkForUpdate(
                    context = context,
                    onSuccess = { tag, isAvailable, changelog, size, _, description, _, apkUrl ->
                      saveUpdateAvailableState(context, isAvailable)
                      if (isAvailable) {
                        updateVersion = tag
                        updateChangelog = changelog
                        updateDescription = description
                        updateSize = size
                        updateApkUrl = apkUrl
                        showUpdateDialog = true
                      }
                    },
                    onError = {}
                  )
                }
              }
            }
          )
        )
    )

    Text(
      text =
        "Updates are published on GitHub Releases. When an update is available, tapping above will take you to the official release page.",
      style = MaterialTheme.typography.bodySmall,
      color = MaterialTheme.colorScheme.onSurfaceVariant,
      modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 16.dp)
    )

    releaseNotes?.let { notes ->
      neko.music.app.ui.component.PreferenceGroupTitle(title = "What's New")
      androidx.compose.material3.Card(
        modifier = Modifier.fillMaxWidth(),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(24.dp),
        colors =
          androidx.compose.material3.CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerHigh
          ),
        elevation = androidx.compose.material3.CardDefaults.cardElevation(defaultElevation = 0.dp)
      ) {
        Column(modifier = Modifier.fillMaxWidth().padding(20.dp)) {
          val (effectiveDescription, effectiveSections) =
            remember(notes) { parseMarkdownToSections(notes) }

          if (!effectiveDescription.isNullOrBlank()) {
            Text(
              text = parseSimpleMarkdown(effectiveDescription, MaterialTheme.colorScheme.primary),
              style = MaterialTheme.typography.bodyMedium,
              color = MaterialTheme.colorScheme.onSurfaceVariant,
              modifier = Modifier.padding(bottom = 8.dp)
            )
          }

          if (effectiveSections.isNotEmpty()) {
            effectiveSections.forEachIndexed { sectionIndex, section ->
              if (section.title.isNotBlank()) {
                Text(
                  text = parseSimpleMarkdown(section.title, MaterialTheme.colorScheme.primary),
                  style = MaterialTheme.typography.titleSmall,
                  fontWeight = FontWeight.Bold,
                  color = MaterialTheme.colorScheme.primary,
                  modifier =
                    Modifier.padding(
                      top =
                        if (sectionIndex == 0 && effectiveDescription.isNullOrBlank()) 0.dp
                        else 10.dp,
                      bottom = 4.dp
                    )
                )
              }
              section.items.forEach { item ->
                if (item.isNotBlank()) {
                  Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                  ) {
                    Text(
                      text = "•",
                      style = MaterialTheme.typography.bodyMedium,
                      color = MaterialTheme.colorScheme.primary,
                      fontWeight = FontWeight.Bold,
                    )
                    Text(
                      text = parseSimpleMarkdown(item.trim(), MaterialTheme.colorScheme.primary),
                      style = MaterialTheme.typography.bodyMedium,
                      color = MaterialTheme.colorScheme.onSurfaceVariant,
                      modifier = Modifier.weight(1f)
                    )
                  }
                }
              }
            }
          } else if (effectiveDescription.isNullOrBlank()) {
            Text(
              text = parseSimpleMarkdown(notes, MaterialTheme.colorScheme.primary),
              style = MaterialTheme.typography.bodyMedium,
              color = MaterialTheme.colorScheme.onSurfaceVariant
            )
          }
        }
      }
      Spacer(modifier = Modifier.height(16.dp))
    }

    Spacer(modifier = Modifier.height(16.dp))

    Spacer(
      Modifier.windowInsetsPadding(
        LocalPlayerAwareWindowInsets.current.only(WindowInsetsSides.Bottom)
      )
    )
  }

  TopAppBar(
    title = { Text(stringResource(R.string.update_settings_title)) },
    navigationIcon = {
      IconButton(onClick = navController::navigateUp, onLongClick = navController::backToMain) {
        Icon(painterResource(R.drawable.arrow_back), contentDescription = null)
      }
    }
  )
}
