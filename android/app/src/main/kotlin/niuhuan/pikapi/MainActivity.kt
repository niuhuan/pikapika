package niuhuan.pikapi

import android.content.ContentValues
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.view.Display
import android.view.KeyEvent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.newSingleThreadContext
import kotlinx.coroutines.sync.Mutex
import mobile.Mobile
import java.util.concurrent.Executors
import java.util.concurrent.LinkedBlockingQueue

class MainActivity : FlutterActivity() {

    // 为什么换成换成线程池而不继续使用携程 : 下载图片速度慢会占满携程造成拥堵, 接口无法请求
    private val pool = Executors.newCachedThreadPool { runnable ->
        Thread(runnable).also { it.isDaemon = true }
    }
    private val uiThreadHandler = Handler(Looper.getMainLooper())
    private val scope = CoroutineScope(newSingleThreadContext("worker-scope"))

    private val notImplementedToken = Any()
    private fun MethodChannel.Result.withCoroutine(exec: () -> Any?) {
        pool.submit {
            try {
                val data = exec()
                uiThreadHandler.post {
                    when (data) {
                        notImplementedToken -> {
                            notImplemented()
                        }
                        is Unit, null -> {
                            success(null)
                        }
                        else -> {
                            success(data)
                        }
                    }
                }
            } catch (e: Exception) {
                uiThreadHandler.post {
                    error("", e.message, "")
                }
            }

        }
    }

    private val resourceQueue: LinkedBlockingQueue<Any?> = LinkedBlockingQueue()
    private var cacheDir: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        cacheDir = context!!.cacheDir.absolutePath
        Mobile.initApplication(context!!.filesDir.absolutePath)
        // Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "method").setMethodCallHandler { call, result ->
            result.withCoroutine {
                when (call.method) {
                    "flatInvoke" -> {
                        Mobile.flatInvoke(
                                call.argument("method")!!,
                                call.argument("params")!!
                        )
                    }
                    "androidSaveFileToImage" -> {
                        saveImage(call.argument("path")!!)
                    }
                    "androidGetModes" -> {
                        modes()
                    }
                    "androidSetMode" -> {
                        setMode(call.argument("mode")!!)
                    }
                    "androidGetVersion" -> Build.VERSION.SDK_INT
//                    "exportComicDownloadAndroidQ" -> {
//                        exportComicDownloadAndroidQ(call.argument("comicId")!!)
//                    }
                    else -> {
                        notImplementedToken
                    }
                }
            }
        }

        //
        val eventMutex = Mutex()
        var eventSink: EventChannel.EventSink? = null
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "flatEvent")
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        events?.let { events ->
                            scope.launch {
                                eventMutex.lock()
                                eventSink = events
                                eventMutex.unlock()
                            }
                        }
                    }

                    override fun onCancel(arguments: Any?) {
                        scope.launch {
                            eventMutex.lock()
                            eventSink = null
                            eventMutex.unlock()
                        }
                    }
                })
        Mobile.eventNotify { message ->
            scope.launch {
                eventMutex.lock()
                try {
                    eventSink?.let {
                        uiThreadHandler.post {
                            it.success(message)
                        }
                    }
                } finally {
                    eventMutex.unlock()
                }
            }
        }

        //
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "volume_button")
                .setStreamHandler(volumeStreamHandler)

    }

    // save_image

    private fun saveImage(path: String) {
        BitmapFactory.decodeFile(path)?.let { bitmap ->
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, System.currentTimeMillis().toString())
                put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) { //this one
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
            }
            contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)?.let { uri ->
                contentResolver.openOutputStream(uri)?.use { fos ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) { //this one
                    contentValues.clear()
                    contentValues.put(MediaStore.Video.Media.IS_PENDING, 0)
                    contentResolver.update(uri, contentValues, null, null)
                }
            }
        }
    }

    // fps mods
    private fun mixDisplay(): Display? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display?.let {
                return it
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            windowManager.defaultDisplay?.let {
                return it
            }
        }
        return null
    }

    private fun modes(): List<String> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            mixDisplay()?.let { display ->
                return display.supportedModes.map { mode ->
                    mode.toString()
                }
            }
        }
        return ArrayList()
    }

    private fun setMode(string: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            mixDisplay()?.let { display ->
                if (string == "") {
                    uiThreadHandler.post {
                        window.attributes = window.attributes.also { attr ->
                            attr.preferredDisplayModeId = 0
                        }
                    }
                    return
                }
                return display.supportedModes.forEach { mode ->
                    if (mode.toString() == string) {
                        uiThreadHandler.post {
                            window.attributes = window.attributes.also { attr ->
                                attr.preferredDisplayModeId = mode.modeId
                            }
                        }
                        return
                    }
                }
            }
        }
    }

    // volume_buttons

    private var volumeEvents: EventChannel.EventSink? = null

    private val volumeStreamHandler = object : EventChannel.StreamHandler {

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            volumeEvents = events
        }

        override fun onCancel(arguments: Any?) {
            volumeEvents = null
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        volumeEvents?.let {
            if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                uiThreadHandler.post {
                    it.success("DOWN")
                }
                return true
            }
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
                uiThreadHandler.post {
                    it.success("UP")
                }
                return true
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    // 安卓11以上使用了 MANAGE_EXTERNAL_STORAGE 权限来管理整个外置存储 （危险权限）

//    private var tmpComicId: String? = null
//    private val exportComicDownloadAndroidQRequestCode = 2
//
//    private fun exportComicDownloadAndroidQ(comicId: String) {
//        val title = Mobile.flatInvoke("specialDownloadTitle", comicId)
//        var fileName = title
//        fileName = fileName.replace('/', '_')
//        fileName = fileName.replace('\\', '_')
//        fileName = fileName.replace('*', '_')
//        fileName = fileName.replace('?', '_')
//        fileName = fileName.replace('<', '_')
//        fileName = fileName.replace('>', '_')
//        fileName = fileName.replace('|', '_')
//        fileName = fileName + "_" + System.currentTimeMillis() + ".zip"
//        tmpComicId = comicId
//        startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).also {
//            it.addCategory(Intent.CATEGORY_OPENABLE)
//            it.type = "application/octet-stream"
//            it.putExtra(Intent.EXTRA_TITLE, fileName)
//        }, exportComicDownloadAndroidQRequestCode)
//        val result = resourceQueue.take()
//        if (result is Throwable) {
//            throw result
//        }
//        return
//    }
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        pool.submit {
//            try {
//                if (resultCode === RESULT_OK && data != null) {
//                    when (requestCode) {
//                        exportComicDownloadAndroidQRequestCode -> {
//                            contentResolver.openOutputStream(data.data!!)?.use { os ->
//                                val path = Mobile.flatInvoke("exportComicDownload", Gson().toJson(HashMap<Any, Any?>().also { map ->
//                                    map["comicId"] = tmpComicId
//                                    map["dir"] = cacheDir
//                                }))
//                                try {
//                                    FileInputStream(path).copyTo(os)
//                                } finally {
//                                    File(path).delete()
//                                }
//                            }
//                            resourceQueue.put("OK")
//                        }
//                        else -> resourceQueue.put(Exception("WTF"))
//                    }
//                } else {
//                    resourceQueue.put(Exception("NOT OK"))
//                }
//            } catch (e: Throwable) {
//                resourceQueue.put(Exception(e))
//            }
//        }
//    }

}
