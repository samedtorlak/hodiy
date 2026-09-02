package com.msela.hodiy

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.msela.hodiy/updater",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVersionName" -> {
                    val versionName =
                        packageManager.getPackageInfo(packageName, 0).versionName
                    result.success(versionName)
                }
                "getFilesDirPath" -> result.success(filesDir.absolutePath)
                "installApk" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("missing_path", "APK path is required", null)
                    } else {
                        try {
                            val uri = FileProvider.getUriForFile(
                                this,
                                "$packageName.fileprovider",
                                File(path),
                            )
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(
                                    uri,
                                    "application/vnd.android.package-archive",
                                )
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("install_failed", error.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
