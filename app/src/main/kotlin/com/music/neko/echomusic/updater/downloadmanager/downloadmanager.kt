package neko.music.app.echomusic.updater.downloadmanager

import android.content.Context
import android.os.Environment
import neko.music.app.R
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.*

class CustomDownloadManager {
  private var downloadJob: Job? = null
  private var isPaused = false

  fun downloadApk(
    context: Context,
    apkUrl: String,
    destinationFile: File,
    onProgress: (Float) -> Unit,
    onDownloadComplete: (File) -> Unit,
    onError: (String) -> Unit,
  ) {
    downloadJob?.cancel()
    isPaused = false

    downloadJob =
      CoroutineScope(Dispatchers.IO).launch {
        var tempFile: File? = null
        try {
          val url = URL(apkUrl)
          val connection = url.openConnection() as HttpURLConnection
          connection.requestMethod = "GET"
          connection.connectTimeout = 15000
          connection.readTimeout = 15000
          connection.connect()

          if (connection.responseCode != HttpURLConnection.HTTP_OK) {
            withContext(Dispatchers.Main) {
              onError("Server returned HTTP ${connection.responseCode}")
            }
            return@launch
          }

          val fileLength = connection.contentLength.toLong()
          val inputStream = connection.inputStream

          val downloadDir = destinationFile.parentFile ?: neko.music.app.echomusic.updater.getDownloadedApksDir(context)
          if (!downloadDir.exists()) {
            downloadDir.mkdirs()
          }

          tempFile = File(downloadDir, "${destinationFile.name}.tmp")
          if (tempFile.exists()) {
            tempFile.delete()
          }

          val outputStream = FileOutputStream(tempFile)
          val buffer = ByteArray(8192)
          var bytesRead: Int
          var totalBytesRead: Long = 0

          while (inputStream.read(buffer).also { bytesRead = it } != -1) {
            if (isPaused) {
              outputStream.close()
              inputStream.close()
              connection.disconnect()
              tempFile.delete()
              return@launch
            }

            outputStream.write(buffer, 0, bytesRead)
            totalBytesRead += bytesRead

            if (fileLength > 0) {
              val progress = (totalBytesRead.toFloat() / fileLength.toFloat()).coerceIn(0f, 1f)
              withContext(Dispatchers.Main) { onProgress(progress) }
            }
          }

          outputStream.flush()
          outputStream.close()
          inputStream.close()
          connection.disconnect()

          // Verify download completeness if Content-Length was provided
          if (fileLength > 0 && totalBytesRead != fileLength) {
            tempFile.delete()
            withContext(Dispatchers.Main) {
              onError("Download was incomplete ($totalBytesRead of $fileLength bytes received).")
            }
            return@launch
          }

          if (totalBytesRead == 0L || !tempFile.exists() || tempFile.length() == 0L) {
            tempFile.delete()
            withContext(Dispatchers.Main) {
              onError("Downloaded update package is empty.")
            }
            return@launch
          }

          if (destinationFile.exists()) {
            destinationFile.delete()
          }

          // Robust staging: Attempt atomic rename with copy-and-replace fallback
          var stagedSuccessfully = false
          val renamed = tempFile.renameTo(destinationFile)
          if (renamed && destinationFile.exists() && destinationFile.length() == totalBytesRead) {
            stagedSuccessfully = true
          } else {
            try {
              tempFile.inputStream().use { input ->
                destinationFile.outputStream().use { output ->
                  input.copyTo(output)
                }
              }
              if (destinationFile.exists() && destinationFile.length() == tempFile.length()) {
                tempFile.delete()
                stagedSuccessfully = true
              } else {
                destinationFile.delete()
              }
            } catch (e: Exception) {
              destinationFile.delete()
            }
          }

          if (!stagedSuccessfully || !destinationFile.exists()) {
            tempFile.delete()
            withContext(Dispatchers.Main) {
              onError("Failed to stage downloaded APK for installation.")
            }
            return@launch
          }

          // Verify package integrity and cryptographic signature matching the installed application
          if (!neko.music.app.echomusic.updater.isApkValid(context, destinationFile)) {
            destinationFile.delete()
            withContext(Dispatchers.Main) {
              onError("Downloaded update package failed integrity or signature verification.")
            }
            return@launch
          }

          withContext(Dispatchers.Main) { onDownloadComplete(destinationFile) }
        } catch (e: CancellationException) {
          tempFile?.delete()
          // Do not convert intentional cancellation into a download error
          throw e
        } catch (e: Exception) {
          tempFile?.delete()
          withContext(Dispatchers.Main) {
            onError(e.message ?: context.getString(R.string.download_failed))
          }
        }
      }
  }

  fun downloadApk(
    context: Context,
    apkUrl: String,
    onProgress: (Float) -> Unit,
    onDownloadComplete: (File) -> Unit,
    onError: (String) -> Unit,
  ) {
    val downloadDir = neko.music.app.echomusic.updater.getDownloadedApksDir(context)
    val defaultFile = File(downloadDir, "nekomusic-update.apk")
    downloadApk(context, apkUrl, defaultFile, onProgress, onDownloadComplete, onError)
  }

  fun pauseDownload() {
    isPaused = true
    downloadJob?.cancel()
  }

  fun cancelDownload() {
    isPaused = true
    downloadJob?.cancel()
    downloadJob = null
  }
}
