package neko.music.app.echomusic.component

import neko.music.app.R

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import java.io.File
import neko.music.app.echomusic.updater.ChangelogSection
import neko.music.app.echomusic.updater.downloadmanager.CustomDownloadManager
import neko.music.app.echomusic.updater.installDownloadedApk
import neko.music.app.echomusic.updater.isApkValid
import neko.music.app.ui.utils.parseMarkdownToSections
import neko.music.app.ui.utils.parseSimpleMarkdown
import racra.compose.smooth_corner_rect_library.AbsoluteSmoothCornerShape

private enum class UpdateDownloadState {
  Idle,
  Downloading,
  ReadyToInstall,
  Error,
}

/**
 * Displays an in-app dialog informing the user that a newer version of the application
 * is available, allowing direct download, progress monitoring, integrity verification,
 * and initiation of Android package installation without requiring a browser or manual APK handling.
 *
 * @param version The latest version tag or display string.
 * @param changelog Pre-parsed structured changelog sections, if available.
 * @param description Raw release description or fallback Markdown text.
 * @param apkUrl Architecture-matched APK download URL from GitHub Releases.
 * @param fileSize Formatted size string (e.g. "45.5 MB") when available.
 * @param onDismiss Invoked when the user dismisses the dialog (e.g. "Next time").
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UpdateAvailableDialog(
  version: String,
  changelog: List<ChangelogSection>,
  description: String?,
  apkUrl: String? = null,
  fileSize: String? = null,
  onDismiss: () -> Unit,
) {
  val context = LocalContext.current
  val cardShape =
    AbsoluteSmoothCornerShape(
      cornerRadiusTL = 30.dp,
      cornerRadiusTR = 30.dp,
      cornerRadiusBL = 30.dp,
      cornerRadiusBR = 30.dp,
      smoothnessAsPercentTL = 60,
      smoothnessAsPercentTR = 60,
      smoothnessAsPercentBL = 60,
      smoothnessAsPercentBR = 60,
    )
  val blockShape = AbsoluteSmoothCornerShape(22.dp, 60)
  val actionShape = AbsoluteSmoothCornerShape(18.dp, 60)

  val cleanVersion = remember(version) { version.removePrefix("v").removePrefix("b").trim() }
  val downloadDir = remember(context) { neko.music.app.echomusic.updater.getDownloadedApksDir(context) }
  val targetApk = remember(downloadDir, cleanVersion) {
    File(downloadDir, "nekomusic-$cleanVersion.apk")
  }

  val downloadManager = remember { CustomDownloadManager() }
  var downloadState by remember {
    mutableStateOf(
      if (isApkValid(context, targetApk)) UpdateDownloadState.ReadyToInstall
      else UpdateDownloadState.Idle
    )
  }
  var downloadProgress by remember { mutableFloatStateOf(0f) }
  var errorMessage by remember { mutableStateOf<String?>(null) }
  var permissionRequiredMessage by remember { mutableStateOf(false) }

  LaunchedEffect(downloadState) {
    if (downloadState == UpdateDownloadState.ReadyToInstall && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      if (context.packageManager.canRequestPackageInstalls()) {
        permissionRequiredMessage = false
      }
    }
  }

  DisposableEffect(Unit) {
    onDispose {
      if (downloadState == UpdateDownloadState.Downloading) {
        downloadManager.cancelDownload()
      }
    }
  }

  BasicAlertDialog(onDismissRequest = {
    if (downloadState == UpdateDownloadState.Downloading) {
      downloadManager.cancelDownload()
    }
    onDismiss()
  }) {
    Surface(
      modifier = Modifier.padding(horizontal = 16.dp).fillMaxWidth(),
      shape = cardShape,
      color = MaterialTheme.colorScheme.surfaceContainerHigh,
      tonalElevation = 8.dp,
    ) {
      Column(
        modifier = Modifier.padding(horizontal = 18.dp, vertical = 18.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp),
      ) {
        Surface(
          shape = blockShape,
          color = MaterialTheme.colorScheme.surfaceContainer,
        ) {
          Column(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
          ) {
            Row(
              modifier = Modifier.fillMaxWidth(),
              verticalAlignment = Alignment.CenterVertically,
              horizontalArrangement = Arrangement.SpaceBetween,
            ) {
              Surface(
                shape = AbsoluteSmoothCornerShape(12.dp, 60),
                color = MaterialTheme.colorScheme.primaryContainer,
              ) {
                Row(
                  modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                  verticalAlignment = Alignment.CenterVertically,
                  horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                  Icon(
                    painter = painterResource(R.drawable.update),
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier.size(16.dp),
                  )
                  Text(
                    text = stringResource(R.string.update_available_title),
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onPrimaryContainer,
                  )
                }
              }

              if (!fileSize.isNullOrBlank()) {
                Surface(
                  shape = AbsoluteSmoothCornerShape(10.dp, 60),
                  color = MaterialTheme.colorScheme.surfaceContainerHighest,
                ) {
                  Text(
                    text = fileSize,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                  )
                }
              }
            }

            Text(
              text = "Version $version is available",
              style = MaterialTheme.typography.titleLarge,
              fontWeight = FontWeight.Bold,
            )
          }
        }

        if (changelog.isNotEmpty() || !description.isNullOrEmpty()) {
          Surface(
            modifier = Modifier.weight(1f, fill = false),
            shape = blockShape,
            color = MaterialTheme.colorScheme.surfaceContainerLow,
          ) {
            Column(
              modifier =
                Modifier.fillMaxWidth().padding(14.dp).verticalScroll(rememberScrollState()),
              verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
              Text(
                text = stringResource(R.string.changelog),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary,
              )

              val (effectiveDescription, effectiveSections) =
                remember(changelog, description) {
                  if (changelog.isNotEmpty()) {
                    Pair(description?.takeIf { it.isNotBlank() }, changelog)
                  } else if (!description.isNullOrBlank()) {
                    parseMarkdownToSections(description)
                  } else {
                    Pair(null, emptyList())
                  }
                }

              if (!effectiveDescription.isNullOrBlank()) {
                Text(
                  text =
                    parseSimpleMarkdown(effectiveDescription, MaterialTheme.colorScheme.primary),
                  style = MaterialTheme.typography.bodyMedium,
                  color = MaterialTheme.colorScheme.onSurfaceVariant,
                  modifier = Modifier.padding(bottom = 4.dp),
                )
              }

              if (effectiveSections.isNotEmpty()) {
                effectiveSections.forEach { section ->
                  if (section.title.isNotBlank()) {
                    Text(
                      text = section.title,
                      style = MaterialTheme.typography.titleSmall,
                      fontWeight = FontWeight.Bold,
                      color = MaterialTheme.colorScheme.primary,
                      modifier = Modifier.padding(top = 6.dp),
                    )
                  }
                  section.items.forEach { item ->
                    Row(
                      modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp),
                      horizontalArrangement = Arrangement.spacedBy(8.dp),
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
                        modifier = Modifier.weight(1f),
                      )
                    }
                  }
                }
              }
            }
          }
        }

        // Progress / Feedback Section
        if (downloadState == UpdateDownloadState.Downloading) {
          Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(6.dp),
          ) {
            Row(
              modifier = Modifier.fillMaxWidth(),
              horizontalArrangement = Arrangement.SpaceBetween,
              verticalAlignment = Alignment.CenterVertically,
            ) {
              Text(
                text = "Downloading update...",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
              )
              Text(
                text = "${(downloadProgress * 100).toInt()}%",
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary,
              )
            }
            LinearProgressIndicator(
              progress = { downloadProgress },
              modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
            )
          }
        }

        if (downloadState == UpdateDownloadState.Error && errorMessage != null) {
          Text(
            text = errorMessage!!,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.error,
          )
        }

        if (permissionRequiredMessage) {
          Text(
            text = "Permission to install unknown apps is required to apply the update. Tap Install to open settings.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.tertiary,
          )
        }

        // Action Buttons Row
        Row(
          modifier = Modifier.fillMaxWidth(),
          verticalAlignment = Alignment.CenterVertically,
          horizontalArrangement = Arrangement.End,
        ) {
          if (downloadState == UpdateDownloadState.Downloading) {
            TextButton(
              onClick = {
                downloadManager.cancelDownload()
                downloadState = UpdateDownloadState.Idle
                downloadProgress = 0f
                errorMessage = null
              },
              shape = actionShape,
            ) {
              Text(text = "Cancel")
            }
          } else {
            TextButton(
              onClick = onDismiss,
              shape = actionShape,
            ) {
              Text(text = "Next time")
            }
          }

          Spacer(modifier = Modifier.width(8.dp))

          when (downloadState) {
            UpdateDownloadState.Idle -> {
              Button(
                onClick = {
                  val effectiveUrl = apkUrl?.takeIf { it.isNotBlank() }
                    ?: neko.music.app.config.NekoUpdateConfig.releaseApkUrl(version)
                  downloadState = UpdateDownloadState.Downloading
                  downloadProgress = 0f
                  errorMessage = null
                  downloadManager.downloadApk(
                    context = context,
                    apkUrl = effectiveUrl,
                    destinationFile = targetApk,
                    onProgress = { progress -> downloadProgress = progress },
                    onDownloadComplete = {
                      downloadState = UpdateDownloadState.ReadyToInstall
                    },
                    onError = { err ->
                      errorMessage = err
                      downloadState = UpdateDownloadState.Error
                    },
                  )
                },
                shape = actionShape,
              ) {
                Text(text = "Download Update")
              }
            }

            UpdateDownloadState.Downloading -> {
              // Nothing on right side during download, Cancel button is on left
            }

            UpdateDownloadState.ReadyToInstall -> {
              Button(
                onClick = {
                  val launched = installDownloadedApk(context, targetApk)
                  if (!launched) {
                    permissionRequiredMessage = true
                  } else {
                    onDismiss()
                  }
                },
                shape = actionShape,
              ) {
                Text(text = "Install Update")
              }
            }

            UpdateDownloadState.Error -> {
              Button(
                onClick = {
                  val effectiveUrl = apkUrl?.takeIf { it.isNotBlank() }
                    ?: neko.music.app.config.NekoUpdateConfig.releaseApkUrl(version)
                  downloadState = UpdateDownloadState.Downloading
                  downloadProgress = 0f
                  errorMessage = null
                  downloadManager.downloadApk(
                    context = context,
                    apkUrl = effectiveUrl,
                    destinationFile = targetApk,
                    onProgress = { progress -> downloadProgress = progress },
                    onDownloadComplete = {
                      downloadState = UpdateDownloadState.ReadyToInstall
                    },
                    onError = { err ->
                      errorMessage = err
                      downloadState = UpdateDownloadState.Error
                    },
                  )
                },
                shape = actionShape,
              ) {
                Text(text = "Retry")
              }
            }
          }
        }
      }
    }
  }
}
