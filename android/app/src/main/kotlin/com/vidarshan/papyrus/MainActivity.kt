package com.vidarshan.papyrus

import android.content.ContentUris
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "papyrus/device_pdfs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // READ_EXTERNAL_STORAGE is only declared up to API 32 (see
                    // AndroidManifest.xml); requesting it on 13+ can never
                    // succeed since the OS won't even show a prompt for a
                    // permission the app doesn't declare at that SDK level.
                    "needsLegacyStoragePermission" ->
                        result.success(Build.VERSION.SDK_INT <= Build.VERSION_CODES.S_V2)
                    "listPdfs" -> result.success(listPdfs())
                    "readBytes" -> {
                        val uri = call.argument<String>("uri")
                        if (uri == null) {
                            result.error("INVALID_ARGUMENT", "uri is required", null)
                        } else {
                            try {
                                result.success(readBytes(uri))
                            } catch (e: Exception) {
                                result.error("READ_FAILED", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun listPdfs(): List<Map<String, Any?>> {
        val pdfs = mutableListOf<Map<String, Any?>>()
        val collection = MediaStore.Files.getContentUri("external")
        val projection = arrayOf(
            MediaStore.Files.FileColumns._ID,
            MediaStore.Files.FileColumns.DISPLAY_NAME,
            MediaStore.Files.FileColumns.SIZE,
            MediaStore.Files.FileColumns.DATE_MODIFIED,
        )
        val selection = "${MediaStore.Files.FileColumns.MIME_TYPE} = ?"
        val selectionArgs = arrayOf("application/pdf")
        val sortOrder = "${MediaStore.Files.FileColumns.DATE_MODIFIED} DESC"

        contentResolver.query(collection, projection, selection, selectionArgs, sortOrder)?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns._ID)
            val nameCol = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DISPLAY_NAME)
            val sizeCol = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.SIZE)
            val dateCol = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DATE_MODIFIED)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idCol)
                val uri = ContentUris.withAppendedId(collection, id)
                pdfs.add(
                    mapOf(
                        "uri" to uri.toString(),
                        "name" to cursor.getString(nameCol),
                        "size" to cursor.getLong(sizeCol),
                        "dateModified" to cursor.getLong(dateCol) * 1000L,
                    )
                )
            }
        }
        return pdfs
    }

    private fun readBytes(uriString: String): ByteArray {
        val uri = Uri.parse(uriString)
        return contentResolver.openInputStream(uri)?.use { it.readBytes() }
            ?: throw IllegalStateException("Could not open $uriString")
    }
}
