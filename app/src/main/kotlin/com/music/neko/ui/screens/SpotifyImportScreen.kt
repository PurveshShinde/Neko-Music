@file:OptIn(ExperimentalMaterial3Api::class)

package neko.music.app.ui.screens

import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import coil3.compose.AsyncImage
import neko.music.app.LocalPlayerAwareWindowInsets
import neko.music.app.R
import neko.music.app.spotifyimport.SpotifyImportProgressUi
import neko.music.app.spotifyimport.SpotifyImportSourceType
import neko.music.app.spotifyimport.SpotifyImportSourceUi
import neko.music.app.spotifyimport.SpotifyImportSummaryUi
import neko.music.app.spotifyimport.SpotifyImportUiState
import neko.music.app.spotifyimport.SpotifyImportViewModel
import neko.music.app.ui.component.DefaultDialog
import neko.music.app.ui.component.IconButton
import neko.music.app.ui.component.Material3SettingsGroup
import neko.music.app.ui.component.Material3SettingsItem
import neko.music.app.ui.utils.backToMain

@Composable
fun SpotifyImportScreen(
  navController: NavController,
  spotifyImportViewModel: SpotifyImportViewModel = hiltViewModel(),
) {
  val state by spotifyImportViewModel.uiState.collectAsStateWithLifecycle()
  val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()

  var showSpotifySources by remember { mutableStateOf(false) }
  var showAddByLink by remember { mutableStateOf(false) }

  LaunchedEffect(Unit) {
    if (!state.isAuthenticated) {
      spotifyImportViewModel.restoreSession()
    }
  }

  Scaffold(
    modifier = Modifier.fillMaxSize().nestedScroll(scrollBehavior.nestedScrollConnection),
    topBar = {
      TopAppBar(
        title = { Text(stringResource(R.string.spotify_account)) },
        navigationIcon = {
          IconButton(onClick = navController::navigateUp, onLongClick = navController::backToMain) {
            Icon(painterResource(R.drawable.arrow_back), null)
          }
        },
        scrollBehavior = scrollBehavior
      )
    }
  ) { innerPadding ->
    LazyColumn(
      modifier =
        Modifier.fillMaxSize()
          .windowInsetsPadding(
            LocalPlayerAwareWindowInsets.current.only(
              WindowInsetsSides.Horizontal + WindowInsetsSides.Bottom
            )
          ),
      contentPadding =
        PaddingValues(
          top = innerPadding.calculateTopPadding(),
          bottom = innerPadding.calculateBottomPadding() + 32.dp,
          start = 16.dp,
          end = 16.dp
        ),
      verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      item {
        Spacer(modifier = Modifier.height(16.dp))

        // Account section
        Material3SettingsGroup(
          title = stringResource(R.string.spotify_account),
          items = listOf(
            if (state.isAuthenticated) {
              Material3SettingsItem(
                customIcon = if (!state.accountAvatarUrl.isNullOrBlank()) {
                  {
                    AsyncImage(
                      model = state.accountAvatarUrl,
                      contentDescription = null,
                      modifier = Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(12.dp)),
                      contentScale = ContentScale.Crop,
                    )
                  }
                } else null,
                icon = if (state.accountAvatarUrl.isNullOrBlank()) painterResource(R.drawable.ic_spotify) else null,
                title = {
                  Text(
                    text = state.accountName.ifBlank { stringResource(R.string.spotify_account) },
                    color = MaterialTheme.colorScheme.primary,
                    style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.Bold),
                  )
                },
                description = {
                  Text(
                    text = if (state.isLoading) stringResource(R.string.spotify_loading_library)
                    else if (state.accountName.isNotBlank()) stringResource(R.string.spotify_connected_as, state.accountName)
                    else stringResource(R.string.spotify_account),
                  )
                },
                trailingContent = {
                  OutlinedButton(
                    onClick = { spotifyImportViewModel.logout() },
                    colors = ButtonDefaults.outlinedButtonColors(
                      containerColor = MaterialTheme.colorScheme.surfaceContainer,
                      contentColor = MaterialTheme.colorScheme.onSurface,
                    ),
                  ) {
                    Text(stringResource(R.string.action_logout))
                  }
                },
                onClick = null,
              )
            } else {
              Material3SettingsItem(
                title = { Text(stringResource(R.string.spotify_connect)) },
                description = { Text(stringResource(R.string.spotify_not_connected)) },
                icon = painterResource(R.drawable.ic_spotify),
                onClick = { navController.navigate("settings/spotify_login") },
              )
            }
          ),
        )
      }

      if (state.isAuthenticated) {
        item {
          Material3SettingsGroup(
            title = stringResource(R.string.playlists),
            items = listOf(
              Material3SettingsItem(
                title = { Text(stringResource(R.string.spotify_select_sources)) },
                description = {
                  Text(
                    if (state.hasSources) stringResource(R.string.spotify_available_count, state.sources.size)
                    else stringResource(R.string.spotify_no_sources)
                  )
                },
                trailingContent = {
                  if (state.hasSources) {
                    Badge(
                      containerColor = MaterialTheme.colorScheme.primaryContainer,
                      contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
                    ) {
                      Text(
                        text = state.sources.size.toString(),
                        modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
                        style = MaterialTheme.typography.labelLarge,
                      )
                    }
                  }
                },
                icon = painterResource(R.drawable.playlist_play),
                enabled = state.hasSources && state.progress == null && !state.isLoading,
                onClick = { showSpotifySources = true },
              ),
              Material3SettingsItem(
                title = { Text(stringResource(R.string.spotify_import_by_link)) },
                description = { Text(stringResource(R.string.spotify_import_by_link_desc)) },
                icon = painterResource(R.drawable.link),
                enabled = !state.isLoading && state.progress == null,
                onClick = { showAddByLink = true },
              ),
              Material3SettingsItem(
                title = { Text(stringResource(R.string.spotify_refresh)) },
                description = { Text(stringResource(R.string.spotify_import_desc)) },
                icon = painterResource(R.drawable.sync),
                enabled = !state.isLoading && state.progress == null,
                onClick = { spotifyImportViewModel.loadSources() },
              ),
            ),
          )
        }

        item {
          Row(
            modifier = Modifier.padding(top = 8.dp, start = 8.dp, end = 8.dp),
            verticalAlignment = Alignment.Top,
          ) {
            Icon(
              painter = painterResource(R.drawable.info),
              contentDescription = null,
              tint = MaterialTheme.colorScheme.onSurfaceVariant,
              modifier = Modifier.padding(end = 8.dp).size(20.dp),
            )
            Text(
              text = stringResource(R.string.spotify_import_desc),
              style = MaterialTheme.typography.bodyMedium,
              color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
          }
        }
      }
    }
  }

  SpotifyImportDialogs(
    state = state,
    viewModel = spotifyImportViewModel,
    showAddByLink = showAddByLink,
    showSpotifySources = showSpotifySources,
    onDismissAddByLink = { showAddByLink = false },
    onDismissSources = { showSpotifySources = false },
  )
}

@Composable
private fun SpotifyImportDialogs(
  state: SpotifyImportUiState,
  viewModel: SpotifyImportViewModel,
  showAddByLink: Boolean,
  showSpotifySources: Boolean,
  onDismissAddByLink: () -> Unit,
  onDismissSources: () -> Unit,
) {
  if (showAddByLink) {
    SpotifyAddByLinkDialog(
      enabled = !state.isLoading && state.progress == null,
      onDismiss = onDismissAddByLink,
      onAdd = { link ->
        onDismissAddByLink()
        viewModel.addPlaylistByUrl(link)
      },
    )
  }

  if (showSpotifySources && state.isAuthenticated) {
    SpotifySourcePickerSheet(
      state = state,
      onDismiss = onDismissSources,
      onToggleSource = viewModel::toggleSource,
      onSelectAll = viewModel::selectAllSources,
      onClearSelection = viewModel::clearSelection,
      onImport = {
        onDismissSources()
        viewModel.importSelectedSources()
      },
    )
  }

  state.errorMessage?.let { error ->
    SpotifyErrorDialog(
      message = error,
      onDismiss = { viewModel.dismissError() },
    )
  }

  state.summary?.let { summary ->
    SpotifyImportSummaryDialog(
      summary = summary,
      onDismiss = { viewModel.dismissSummary() },
    )
  }

  state.progress?.let { progress ->
    SpotifyImportProgressDialog(
      progress = progress,
      onCancel = { viewModel.cancelImport() },
    )
  }
}

@Composable
private fun SpotifyImportProgressDialog(
  progress: SpotifyImportProgressUi,
  onCancel: () -> Unit,
) {
  DefaultDialog(
    onDismiss = onCancel,
    title = { Text(stringResource(R.string.spotify_import_in_progress)) },
    buttons = { TextButton(onClick = onCancel) { Text(stringResource(android.R.string.cancel)) } },
  ) {
    Column(
      modifier = Modifier.fillMaxWidth(),
      verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
      Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(4.dp),
      ) {
        Text(
          text = if (progress.totalSources > 1) {
            "${progress.sourceTitle} (${progress.completedSources}/${progress.totalSources})"
          } else {
            progress.sourceTitle
          },
          style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
          color = MaterialTheme.colorScheme.onSurface,
          maxLines = 1,
          overflow = TextOverflow.Ellipsis,
        )
        Text(
          text = stringResource(
            R.string.spotify_importing_tracks,
            progress.matchedTracks,
            progress.totalTracks,
          ),
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          maxLines = 1,
          overflow = TextOverflow.Ellipsis,
        )
      }
      LinearProgressIndicator(
        progress = { progress.percent.toFloat() / 100f },
        modifier = Modifier.fillMaxWidth().clip(CircleShape),
      )
    }
  }
}

@Composable
private fun SpotifyAddByLinkDialog(
  enabled: Boolean,
  onDismiss: () -> Unit,
  onAdd: (String) -> Unit,
) {
  var link by remember { mutableStateOf(androidx.compose.ui.text.input.TextFieldValue("")) }

  neko.music.app.ui.component.TextFieldDialog(
    icon = { Icon(painter = painterResource(R.drawable.link), contentDescription = null) },
    title = {
      Column {
        Text(text = stringResource(R.string.spotify_import_by_link))
        Text(
          text = stringResource(R.string.spotify_import_by_link_desc),
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          modifier = Modifier.padding(top = 4.dp),
        )
      }
    },
    initialTextFieldValue = link,
    autoFocus = true,
    placeholder = { Text(stringResource(R.string.spotify_import_by_link_hint)) },
    onDismiss = onDismiss,
    onDone = { finalUrl ->
      if (enabled && finalUrl.isNotBlank()) {
        onAdd(finalUrl)
      }
    },
  )
}

@Composable
private fun SpotifySourcePickerSheet(
  state: SpotifyImportUiState,
  onDismiss: () -> Unit,
  onToggleSource: (String) -> Unit,
  onSelectAll: () -> Unit,
  onClearSelection: () -> Unit,
  onImport: () -> Unit,
) {
  val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

  ModalBottomSheet(
    modifier = Modifier.fillMaxHeight(),
    onDismissRequest = onDismiss,
    sheetState = sheetState,
    shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
    containerColor = MaterialTheme.colorScheme.surface,
  ) {
    Column(
      modifier =
        Modifier.fillMaxWidth().fillMaxHeight().padding(horizontal = 20.dp).padding(bottom = 20.dp),
      verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
      ) {
        Column(modifier = Modifier.weight(1f)) {
          Text(
            text = stringResource(R.string.spotify_select_sources),
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
          )
          Text(
            text = stringResource(R.string.spotify_selected_count, state.selectedSourceIds.size),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
          )
        }
        TextButton(
          onClick = onClearSelection,
        ) {
          Text(stringResource(R.string.spotify_clear_selection))
        }
        TextButton(
          onClick = onSelectAll,
        ) {
          Text(stringResource(R.string.spotify_select_all))
        }
      }

      LazyColumn(
        modifier = Modifier.fillMaxWidth().weight(1f),
        verticalArrangement = Arrangement.spacedBy(8.dp),
        contentPadding = PaddingValues(bottom = 6.dp),
      ) {
        items(
          items = state.sources,
          key = { it.id },
          contentType = { it.type },
        ) { source ->
          SpotifySourceRow(
            source = source,
            selected = source.id in state.selectedSourceIds,
            onClick = { onToggleSource(source.id) },
          )
        }
      }

      Button(
        onClick = onImport,
        modifier = Modifier.fillMaxWidth().heightIn(min = 52.dp),
        enabled = state.canImport,
        shape = RoundedCornerShape(16.dp),
      ) {
        Text(stringResource(R.string.spotify_import_selected))
      }
    }
  }
}

@Composable
private fun SpotifySourceRow(
  source: SpotifyImportSourceUi,
  selected: Boolean,
  onClick: () -> Unit,
) {
  val subtitle =
    when {
      source.subtitle.isNotBlank() -> source.subtitle
      source.type == SpotifyImportSourceType.LIKED_SONGS ->
        stringResource(R.string.spotify_liked_songs_desc)
      else -> stringResource(R.string.spotify_account)
    }

  Surface(
    modifier = Modifier.fillMaxWidth(),
    shape = MaterialTheme.shapes.large,
    color =
      if (selected) {
        MaterialTheme.colorScheme.secondaryContainer
      } else {
        MaterialTheme.colorScheme.surfaceContainerLow
      },
    onClick = onClick,
  ) {
    Row(
      modifier =
        Modifier.fillMaxWidth().heightIn(min = 76.dp).padding(horizontal = 14.dp, vertical = 12.dp),
      verticalAlignment = Alignment.CenterVertically,
      horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
      SpotifySourceThumbnail(source)
      Column(
        modifier = Modifier.weight(1f),
        verticalArrangement = Arrangement.spacedBy(2.dp),
      ) {
        Text(
          text = source.title,
          style = MaterialTheme.typography.bodyLarge,
          fontWeight = FontWeight.Bold,
          maxLines = 1,
          overflow = TextOverflow.Ellipsis,
        )
        Text(
          text =
            source.trackCount?.let { stringResource(R.string.spotify_track_count, it) } ?: subtitle,
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          maxLines = 1,
          overflow = TextOverflow.Ellipsis,
        )
      }
      Checkbox(
        checked = selected,
        onCheckedChange = { onClick() },
      )
    }
  }
}

@Composable
private fun SpotifySourceThumbnail(source: SpotifyImportSourceUi) {
  Box(
    modifier =
      Modifier.size(48.dp)
        .clip(MaterialTheme.shapes.medium)
        .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.12f)),
    contentAlignment = Alignment.Center,
  ) {
    if (!source.thumbnailUrl.isNullOrBlank()) {
      AsyncImage(
        model = source.thumbnailUrl,
        contentDescription = null,
        modifier = Modifier.fillMaxSize(),
      )
    } else {
      Icon(
        painter =
          painterResource(
            if (source.type == SpotifyImportSourceType.LIKED_SONGS) {
              R.drawable.favorite
            } else {
              R.drawable.playlist_play
            },
          ),
        contentDescription = null,
        tint = MaterialTheme.colorScheme.primary,
        modifier = Modifier.size(24.dp),
      )
    }
  }
}

@Composable
private fun SpotifyErrorDialog(
  message: String,
  onDismiss: () -> Unit,
) {
  DefaultDialog(
    onDismiss = onDismiss,
    title = { Text(stringResource(R.string.import_failed)) },
    buttons = { TextButton(onClick = onDismiss) { Text(stringResource(android.R.string.ok)) } },
  ) {
    Text(
      text = message,
      style = MaterialTheme.typography.bodyMedium,
      color = MaterialTheme.colorScheme.onSurfaceVariant,
    )
  }
}

@Composable
private fun SpotifyImportSummaryDialog(
  summary: SpotifyImportSummaryUi,
  onDismiss: () -> Unit,
) {
  DefaultDialog(
    onDismiss = onDismiss,
    title = { Text(stringResource(R.string.spotify_import_complete)) },
    buttons = { TextButton(onClick = onDismiss) { Text(stringResource(android.R.string.ok)) } },
  ) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
      Text(
        text =
          stringResource(
            R.string.spotify_import_summary,
            summary.sourceCount,
            summary.importedTracks,
            summary.failedTracks,
          ),
        style = MaterialTheme.typography.bodyLarge,
        fontWeight = FontWeight.SemiBold,
      )
      summary.sources.forEach { source ->
        Text(
          text =
            stringResource(
              R.string.spotify_source_summary,
              source.title,
              source.importedTracks,
              source.totalTracks,
            ),
          style = MaterialTheme.typography.bodyMedium,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          maxLines = 2,
          overflow = TextOverflow.Ellipsis,
        )
      }
    }
  }
}
