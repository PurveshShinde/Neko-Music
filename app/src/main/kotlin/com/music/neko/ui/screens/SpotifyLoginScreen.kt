/** vivimusic Project (C) 2026 Licensed under GPL-3.0 | See git history for contributors */
package neko.music.app.ui.screens

import android.annotation.SuppressLint
import android.graphics.Color as AndroidColor
import android.webkit.CookieManager
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.viewinterop.AndroidView
import androidx.navigation.NavController
import kotlinx.coroutines.delay
import neko.music.app.LocalPlayerAwareWindowInsets
import neko.music.app.R
import neko.music.app.spotify.SpotifyAuth
import neko.music.app.ui.component.IconButton
import neko.music.app.ui.utils.backToMain

private const val SPOTIFY_LOGIN_USER_AGENT =
    "Mozilla/5.0 (Linux; Android 14; SM-S921U; Build/UP1A.231005.007) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Mobile Safari/537.36"

private val SPOTIFY_DOMAINS = listOf(
    "https://open.spotify.com",
    "https://accounts.spotify.com",
    "https://spotify.com",
    "https://.spotify.com",
)

private fun findCookie(cookieManager: CookieManager, cookieName: String): String? {
    for (url in SPOTIFY_DOMAINS) {
        val raw = cookieManager.getCookie(url) ?: continue
        for (part in raw.split(";")) {
            val pieces = part.split("=", limit = 2)
            if (pieces.size == 2 && pieces[0].trim().equals(cookieName, ignoreCase = true)) {
                val value = pieces[1].trim()
                if (value.isNotEmpty()) return value
            }
        }
    }
    return null
}

@SuppressLint("ClickableViewAccessibility", "SetJavaScriptEnabled")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SpotifyLoginScreen(
    navController: NavController,
    onCookiesCaptured: (spDc: String, spKey: String) -> Unit,
) {
    var webViewRef by remember { mutableStateOf<WebView?>(null) }
    var captured by remember { mutableStateOf(false) }

    fun tryCaptureCookies(cookieManager: CookieManager): Boolean {
        if (captured) return true
        cookieManager.flush()
        val spDc = findCookie(cookieManager, "sp_dc")
        if (!spDc.isNullOrBlank()) {
            captured = true
            val spKey = findCookie(cookieManager, "sp_key").orEmpty()
            onCookiesCaptured(spDc, spKey)
            navController.navigateUp()
            return true
        }
        return false
    }

    // Active polling while on the screen: catches background XHR/fetch cookie updates
    // (such as submitting 2FA/login OTP codes) without needing full-page navigation
    LaunchedEffect(captured) {
        val cookieManager = CookieManager.getInstance()
        while (!captured) {
            if (tryCaptureCookies(cookieManager)) break
            delay(500)
        }
    }

    DisposableEffect(Unit) {
        onDispose {
            webViewRef?.stopLoading()
            webViewRef?.loadUrl("about:blank")
            webViewRef?.destroy()
            webViewRef = null
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        AndroidView(
            modifier = Modifier
                .windowInsetsPadding(LocalPlayerAwareWindowInsets.current)
                .fillMaxSize(),
            factory = { context ->
                val cookieManager = CookieManager.getInstance()
                cookieManager.setAcceptCookie(true)

                WebView(context).apply {
                    setBackgroundColor(AndroidColor.BLACK)
                    layoutParams = android.view.ViewGroup.LayoutParams(
                        android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                        android.view.ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    settings.javaScriptEnabled = true
                    settings.domStorageEnabled = true
                    settings.databaseEnabled = true
                    settings.javaScriptCanOpenWindowsAutomatically = true
                    settings.setSupportZoom(true)
                    settings.builtInZoomControls = true
                    settings.displayZoomControls = false
                    settings.userAgentString = SPOTIFY_LOGIN_USER_AGENT
                    settings.mixedContentMode = android.webkit.WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
                    cookieManager.setAcceptThirdPartyCookies(this, true)

                    setOnTouchListener { v, event ->
                        when (event.action) {
                            android.view.MotionEvent.ACTION_DOWN,
                            android.view.MotionEvent.ACTION_MOVE -> {
                                v.parent.requestDisallowInterceptTouchEvent(true)
                            }
                            android.view.MotionEvent.ACTION_UP,
                            android.view.MotionEvent.ACTION_CANCEL -> {
                                v.parent.requestDisallowInterceptTouchEvent(false)
                            }
                        }
                        false
                    }

                    webViewClient = object : WebViewClient() {
                        override fun shouldOverrideUrlLoading(
                            view: WebView,
                            request: WebResourceRequest,
                        ): Boolean {
                            if (tryCaptureCookies(cookieManager)) return true
                            return false
                        }

                        override fun onPageStarted(
                            view: WebView,
                            url: String?,
                            favicon: android.graphics.Bitmap?,
                        ) {
                            tryCaptureCookies(cookieManager)
                        }

                        override fun onPageFinished(view: WebView, url: String?) {
                            tryCaptureCookies(cookieManager)
                        }

                        override fun doUpdateVisitedHistory(
                            view: WebView,
                            url: String?,
                            isReload: Boolean,
                        ) {
                            super.doUpdateVisitedHistory(view, url, isReload)
                            tryCaptureCookies(cookieManager)
                        }
                    }

                    webChromeClient = android.webkit.WebChromeClient()
                    webViewRef = this
                    loadUrl(SpotifyAuth.LOGIN_URL)
                }
            },
            update = { view -> webViewRef = view }
        )

        TopAppBar(
            title = { Text(stringResource(R.string.spotify_login_title)) },
            navigationIcon = {
                IconButton(
                    onClick = navController::navigateUp,
                    onLongClick = navController::backToMain,
                ) {
                    Icon(
                        painterResource(R.drawable.arrow_back),
                        contentDescription = null,
                    )
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = Color.Black,
                titleContentColor = Color.White,
                navigationIconContentColor = Color.White,
            )
        )
    }

    BackHandler(enabled = webViewRef?.canGoBack() == true) {
        webViewRef?.goBack()
    }
}
