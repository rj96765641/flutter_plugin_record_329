
package record.wilson.flutter.com.flutter_plugin_record_329

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import cafe.adriel.androidaudioconverter.AndroidAudioConverter
import cafe.adriel.androidaudioconverter.callback.IConvertCallback
import cafe.adriel.androidaudioconverter.callback.ILoadCallback
import cafe.adriel.androidaudioconverter.model.AudioFormat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import record.wilson.flutter.com.flutter_plugin_record_329.utils.*
import java.io.File
import java.util.*

/** 
 * Flutter录音插件的主类
 * 实现了Flutter插件接口、方法调用处理、Activity感知和权限请求监听
 */
class FlutterPluginRecord329Plugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    // 用于Flutter和原生代码通信的通道
    private lateinit var channel: MethodChannel
    // 存储当前方法调用的结果回调
    private lateinit var _result: Result
    // 存储当前方法调用
    private lateinit var call: MethodCall
    // 存储录音文件的播放路径
    private lateinit var voicePlayPath: String
    // 录音工具类实例
    private var recorderUtil: RecorderUtil? = null
    // 是否录制MP3格式
    private var recordMp3: Boolean = false
    
    // 音频处理器实例，使用volatile确保多线程可见性
    @Volatile
    private var audioHandler: AudioHandler? = null
    
    // Activity实例，用于权限请求等
    private lateinit var activity: Activity
    // 应用上下文
    private lateinit var context: Context

    /**
     * 插件附加到Flutter引擎时调用
     */
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_plugin_record_329")
        channel.setMethodCallHandler(this)
    }

    /**
     * 处理来自Flutter的方法调用
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        _result = result
        this.call = call
        when (call.method) {
            "init" -> init()
            "initRecordMp3" -> initRecordMp3()
            "start" -> start()
            "startByWavPath" -> startByWavPath()
            "stop" -> stop()
            "play" -> play()
            "pause" -> pause()
            "playByPath" -> playByPath()
            "stopPlay" -> stopPlay()
            else -> result.notImplemented()
        }
    }

    /**
     * 初始化WAV转MP3功能
     */
    private fun initWavToMp3() {
        AndroidAudioConverter.load(activity.applicationContext, object : ILoadCallback {
            override fun onSuccess() {
                Log.d("android", "AndroidAudioConverter 初始化成功")
            }

            override fun onFailure(error: Exception) {
                Log.e("android", "AndroidAudioConverter 初始化失败", error)
            }
        })
    }

    /**
     * 初始化录音功能
     */
    private fun initRecord() {
        if (audioHandler != null) {
            audioHandler?.release()
            audioHandler = null
        }
        audioHandler = AudioHandler.createHandler(AudioHandler.Frequency.F_22050)

        val id = call.argument<String>("id")
        val m1 = HashMap<String, String>()
        m1["id"] = id ?: ""
        m1["result"] = "success"
        channel.invokeMethod("onInit", m1)
    }

    /**
     * 停止播放
     */
    private fun stopPlay() {
        recorderUtil?.stopPlay()
    }

    /**
     * 暂停播放
     */
    private fun pause() {
        val isPlaying = recorderUtil?.pausePlay()
        val _id = call.argument<String>("id")
        val m1 = HashMap<String, String>()
        m1["id"] = _id ?: ""
        m1["result"] = "success"
        m1["isPlaying"] = isPlaying.toString()
        channel.invokeMethod("pausePlay", m1)
    }

    /**
     * 播放录音
     */
    private fun play() {
        recorderUtil = RecorderUtil(voicePlayPath)
        recorderUtil?.addPlayStateListener { playState ->
            val _id = call.argument<String>("id")
            val m1 = HashMap<String, String>()
            m1["id"] = _id ?: ""
            m1["playPath"] = voicePlayPath
            m1["playState"] = playState.toString()
            channel.invokeMethod("onPlayState", m1)
        }
        recorderUtil?.playVoice()
        
        val _id = call.argument<String>("id")
        val m1 = HashMap<String, String>()
        m1["id"] = _id ?: ""
        channel.invokeMethod("onPlay", m1)
    }

    /**
     * 通过指定路径播放录音
     */
    private fun playByPath() {
        val path = call.argument<String>("path")
        if (path == null) {
            _result.error("INVALID_PATH", "路径不能为空", null)
            return
        }
        recorderUtil = RecorderUtil(path)
        recorderUtil?.addPlayStateListener { playState ->
            val _id = call.argument<String>("id")
            val m1 = HashMap<String, String>()
            m1["id"] = _id ?: ""
            m1["playPath"] = path
            m1["playState"] = playState.toString()
            channel.invokeMethod("onPlayState", m1)
        }
        recorderUtil?.playVoice()

        val _id = call.argument<String>("id")
        val m1 = HashMap<String, String>()
        m1["id"] = _id ?: ""
        channel.invokeMethod("onPlay", m1)
    }

    /**
     * 停止录音
     */
    @Synchronized
    private fun stop() {
        if (audioHandler?.isRecording == true) {
            audioHandler?.stopRecord()
        }
    }

    /**
     * 开始录音
     */
    @Synchronized
    private fun start() {
        if (checkPermission()) {
            if (audioHandler?.isRecording == true) {
                audioHandler?.stopRecord()
            }
            audioHandler?.startRecord(MessageRecordListener())

            val _id = call.argument<String>("id")
            val m1 = HashMap<String, String>()
            m1["id"] = _id ?: ""
            m1["result"] = "success"
            channel.invokeMethod("onStart", m1)
        }
    }

    /**
     * 使用指定WAV路径开始录音
     */
    @Synchronized
    private fun startByWavPath() {
        if (checkPermission()) {
            val _id = call.argument<String>("id")
            val wavPath = call.argument<String>("wavPath")

            if (audioHandler?.isRecording == true) {
                audioHandler?.stopRecord()
            }
            audioHandler?.startRecord(wavPath?.let { MessageRecordListenerByPath(it) })

            val m1 = HashMap<String, String>()
            m1["id"] = _id ?: ""
            m1["result"] = "success"
            channel.invokeMethod("onStart", m1)
        }
    }

    /**
     * 初始化普通录音
     */
    private fun init() {
        recordMp3 = false
        checkPermission()
    }

    /**
     * 初始化MP3录音
     */
    private fun initRecordMp3() {
        recordMp3 = true
        checkPermission()
        initWavToMp3()
    }

    /**
     * 检查录音所需权限
     */
    private fun checkPermission(): Boolean {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arrayOf(
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.READ_MEDIA_AUDIO,
                Manifest.permission.READ_MEDIA_IMAGES,
                Manifest.permission.READ_MEDIA_VIDEO
            )
        } else {
            arrayOf(
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE
            )
        }

        val notGrantedPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(activity, it) != PackageManager.PERMISSION_GRANTED
        }

        if (notGrantedPermissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(activity, notGrantedPermissions.toTypedArray(), 1)
            return false
        }
        initRecord()
        return true
    }

    /**
     * 自定义路径的录音监听器
     */
    private inner class MessageRecordListenerByPath(private val wavPath: String) : AudioHandler.RecordListener {
        private val fileName: String = UUID.randomUUID().toString()
        private val cacheDirectory: File = FileTool.getIndividualAudioCacheDirectory(activity)

        override fun onStop(recordFile: File?, audioTime: Double?) {
            handleRecordStop(recordFile, audioTime)
        }

        override fun getFilePath(): String = wavPath

        override fun onStart() {
            LogUtils.LOGE("开始录音")
        }

        override fun onVolume(db: Double) {
            handleVolumeChange(db)
        }

        override fun onError(error: Int) {
            LogUtils.LOGE("录音错误: $error")
        }
    }

    /**
     * 默认录音监听器
     */
    private inner class MessageRecordListener : AudioHandler.RecordListener {
        private val fileName: String = UUID.randomUUID().toString()
        private val cacheDirectory: File = FileTool.getIndividualAudioCacheDirectory(activity)

        override fun onStop(recordFile: File?, audioTime: Double?) {
            handleRecordStop(recordFile, audioTime)
        }

        override fun getFilePath(): String {
            val file = File(cacheDirectory, fileName)
            return file.absolutePath
        }

        override fun onStart() {
            LogUtils.LOGE("开始录音")
        }

        override fun onVolume(db: Double) {
            handleVolumeChange(db)
        }

        override fun onError(error: Int) {
            LogUtils.LOGE("录音错误: $error")
        }
    }

    /**
     * 处理录音停止
     */
    private fun handleRecordStop(recordFile: File?, audioTime: Double?) {
        if (recordFile != null) {
            voicePlayPath = recordFile.path
            if (recordMp3) {
                convertToMp3(recordFile, audioTime)
            } else {
                sendStopResult(voicePlayPath, audioTime)
            }
        }
    }

    /**
     * 转换为MP3格式
     */
    private fun convertToMp3(recordFile: File, audioTime: Double?) {
        val callback = object : IConvertCallback {
            override fun onSuccess(convertedFile: File) {
                sendStopResult(convertedFile.path, audioTime)
            }

            override fun onFailure(error: Exception) {
                Log.d("android", "MP3转换失败: $error")
            }
        }

        AndroidAudioConverter.with(activity.applicationContext)
            .setFile(recordFile)
            .setFormat(AudioFormat.MP3)
            .setCallback(callback)
            .convert()
    }

    /**
     * 发送停止录音结果
     */
    private fun sendStopResult(path: String, audioTime: Double?) {
        val _id = call.argument<String>("id")
        val m1 = HashMap<String, String>()
        m1["id"] = _id ?: ""
        m1["voicePath"] = path
        m1["audioTimeLength"] = audioTime.toString()
        m1["result"] = "success"
        activity.runOnUiThread { channel.invokeMethod("onStop", m1) }
    }

    /**
     * 处理音量变化
     */
    private fun handleVolumeChange(db: Double) {
        val _id = call.argument<String>("id")
        val m1 = HashMap<String, Any>()
        m1["id"] = _id ?: ""
        m1["amplitude"] = db / 100
        m1["result"] = "success"
        activity.runOnUiThread { channel.invokeMethod("onAmplitude", m1) }
    }

    /**
     * Activity生命周期相关方法
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        cleanupResources()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        cleanupResources()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        cleanupResources()
    }

    /**
     * 清理资源
     */
    private fun cleanupResources() {
        audioHandler?.release()
        audioHandler = null
        recorderUtil = null
    }

    /**
     * 权限请求结果回调
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == 1) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                initRecord()
                when (call.method) {
                    "start" -> start()
                    "startByWavPath" -> startByWavPath()
                }
            } else {
                _result.error("PERMISSION_DENIED", "录音权限被拒绝", null)
            }
        }
        return true
    }
}
