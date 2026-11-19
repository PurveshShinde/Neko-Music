@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package neko.music.app.ui.screens.settings

import neko.music.app.R

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import neko.music.app.BuildConfig
import neko.music.app.LocalPlayerAwareWindowInsets
import neko.music.app.ui.component.IconButton
import neko.music.app.ui.component.Material3SettingsGroup
import neko.music.app.ui.component.Material3SettingsItem
import neko.music.app.ui.utils.backToMain
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(
  navController: NavController,
  scrollBehavior: TopAppBarScrollBehavior,
  onBack: (() -> Unit)? = null,
  highlightKey: String? = null
) {
  val uriHandler = LocalUriHandler.current
  val context = LocalContext.current

  Scaffold(
    modifier = Modifier.fillMaxSize(),
    containerColor = MaterialTheme.colorScheme.surface,
    contentWindowInsets = WindowInsets(0, 0, 0, 0),
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = stringResource(R.string.about),
            fontWeight = FontWeight.Bold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
          )
        },
        navigationIcon = {
          IconButton(
            onClick = { onBack?.invoke() ?: navController.navigateUp() },
            onLongClick = navController::backToMain,
          ) {
            Icon(painterResource(R.drawable.arrow_back), contentDescription = null)
          }
        },
        windowInsets = TopAppBarDefaults.windowInsets,
        colors =
          TopAppBarDefaults.topAppBarColors(
            containerColor = MaterialTheme.colorScheme.surface,
            scrolledContainerColor = MaterialTheme.colorScheme.surfaceContainer,
          ),
        scrollBehavior = scrollBehavior,
      )
    },
  ) { innerPadding ->
    LazyColumn(
      modifier =
        Modifier.fillMaxSize()
          .windowInsetsPadding(
            LocalPlayerAwareWindowInsets.current.only(
              WindowInsetsSides.Horizontal,
            ),
          ),
      contentPadding =
        PaddingValues(
          start = 16.dp,
          top = innerPadding.calculateTopPadding() + 8.dp,
          end = 16.dp,
          bottom =
            androidx.compose.foundation.layout.WindowInsets.systemBars
              .asPaddingValues()
              .calculateBottomPadding() + 32.dp,
        ),
      verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
      item { AboutAppCard() }

      // 1. DEVELOPER
      item {
        Material3SettingsGroup(
          title = "Developer",
          items =
            listOf(
              Material3SettingsItem(
                icon = painterResource(R.drawable.github),
                title = { Text("GitHub Profile") },
                description = { Text("@PurveshShinde") },
                onClick = { uriHandler.openUri(neko.music.app.config.NekoUpdateConfig.DEVELOPER_GITHUB_PROFILE_URL) }
              ),
              Material3SettingsItem(
                icon = painterResource(R.drawable.website),
                title = { Text("Developer Website") },
                description = { Text("purveshshinde.vercel.app") },
                onClick = { uriHandler.openUri(neko.music.app.config.NekoUpdateConfig.DEVELOPER_WEBSITE_URL) }
              )
            )
        )
      }

      // 2. PROJECT
      item {
        Material3SettingsGroup(
          title = "Project",
          items =
            listOf(
              Material3SettingsItem(
                icon = painterResource(R.drawable.github),
                title = { Text("GitHub Repository") },
                description = { Text("PurveshShinde/Neko-Music") },
                onClick = { uriHandler.openUri(neko.music.app.config.NekoUpdateConfig.REPOSITORY_URL) }
              ),
              Material3SettingsItem(
                icon = painterResource(R.drawable.star),
                title = { Text("Star Neko Music") },
                description = { Text("Support the development of Neko Music by starring the repository.") },
                onClick = { uriHandler.openUri(neko.music.app.config.NekoUpdateConfig.REPOSITORY_URL) }
              )
            )
        )
      }

      // 3. SUPPORT
      item {
        Material3SettingsGroup(
          title = "Support",
          items =
            listOf(
              Material3SettingsItem(
                icon = painterResource(R.drawable.favorite),
                title = { Text("Coming Soon") },
                description = { Text("Support options will be available soon") },
                onClick = null
              )
            )
        )
      }

      // 4. COMMUNITY
      item {
        Material3SettingsGroup(
          title = "Community",
          items =
            listOf(
              Material3SettingsItem(
                icon = painterResource(R.drawable.group),
                title = { Text("Coming Soon") },
                description = { Text("Community channels will be announced soon") },
                onClick = null
              )
            )
        )
      }

    }
  }
}

@Composable
private fun AboutAppCard() {
  Column(
    modifier = Modifier.fillMaxWidth().padding(vertical = 28.dp, horizontal = 20.dp),
    horizontalAlignment = Alignment.CenterHorizontally,
    verticalArrangement = Arrangement.spacedBy(8.dp),
  ) {
    val isDark = MaterialTheme.colorScheme.surface.luminance() < 0.5f

    var isEasterEggActive by remember { mutableStateOf(false) }
    val rotation by
      animateFloatAsState(
        targetValue = if (isEasterEggActive) 180f else 0f,
        animationSpec =
          spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessLow),
        label = "flip"
      )

    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by
      animateFloatAsState(
        targetValue = if (isPressed) 0.85f else 1f,
        animationSpec =
          spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
          ),
        label = "scale"
      )

    Box(
      modifier =
        Modifier.size(100.dp)
          .graphicsLayer {
            rotationY = rotation
            scaleX = scale
            scaleY = scale
            cameraDistance = 12f * density
          }
          .clip(CircleShape)
          .clickable(
            interactionSource = interactionSource,
            indication = null,
            onClick = { isEasterEggActive = !isEasterEggActive }
          ),
      contentAlignment = Alignment.Center
    ) {
      if (rotation <= 90f) {
        Image(
          painter = painterResource(R.drawable.ic_launcher_nobg),
          contentDescription = null,
          modifier = Modifier.fillMaxSize()
        )
      } else {
        coil3.compose.AsyncImage(
          model = "https://avatars.githubusercontent.com/PurveshShinde",
          contentDescription = null,
          modifier =
            Modifier.fillMaxSize().graphicsLayer { rotationY = 180f }, // Un-flip the backside image
          contentScale = androidx.compose.ui.layout.ContentScale.Crop
        )
      }
    }

    Spacer(Modifier.height(4.dp))

    Text(
      text = if (rotation <= 90f) "Neko Music" else "Developed by Purvesh Shinde",
      style = MaterialTheme.typography.titleLarge,
      fontWeight = FontWeight.Bold,
      color = MaterialTheme.colorScheme.onSurface,
    )
    Row(
      horizontalArrangement = Arrangement.spacedBy(6.dp),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Surface(
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.10f),
      ) {
        Text(
          text = BuildConfig.VERSION_NAME,
          style = MaterialTheme.typography.labelSmall,
          color = MaterialTheme.colorScheme.primary,
          fontWeight = FontWeight.Medium,
          modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
        )
      }
      if (BuildConfig.DEBUG) {
        Surface(
          shape = RoundedCornerShape(8.dp),
          color = MaterialTheme.colorScheme.error.copy(alpha = 0.10f),
        ) {
          Text(
            text = "DEBUG",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.error,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
          )
        }
      } else {
        Surface(
          shape = RoundedCornerShape(8.dp),
          color = MaterialTheme.colorScheme.secondary.copy(alpha = 0.10f),
        ) {
          Text(
            text = BuildConfig.ARCHITECTURE.uppercase(),
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.secondary,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
          )
        }
      }
    }
  }
}
