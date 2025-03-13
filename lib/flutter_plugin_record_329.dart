import 'package:uuid/uuid.dart';

import 'flutter_plugin_record_329_method_channel.dart';
import 'flutter_plugin_record_329_platform_interface.dart';
import 'const/play_state.dart';
import 'const/response.dart';

export 'utils/common_toast.dart';
export 'widgets/custom_overlay.dart';
export 'widgets/voice_widget.dart';

/// Flutter 录音插件主类
/// 提供录音、播放等功能的统一接口
class FlutterPluginRecord329 {
  /// 平台接口实例
  FlutterPluginRecord329Platform get _platform => FlutterPluginRecord329Platform.instance;

  /// 用于生成唯一ID的UUID工具
  static final _uuid = Uuid();

  /// 当前实例的唯一ID
  final String id;

  /// 构造函数
  /// 自动生成唯一ID用于区分不同实例
  FlutterPluginRecord329() : id = _uuid.v4();

  /// 获取平台版本
  Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  /// 获取初始化状态流
  /// 返回一个布尔类型的流，表示初始化是否成功
  Stream<bool> get responseFromInit => _platform.getInitializedStateStream(id);

  /// 获取录音响应流
  /// 返回包含录音状态、路径等信息的RecordResponse流
  Stream<RecordResponse> get response => _platform.getRecordResponseStream(id);

  /// 获取振幅响应流
  /// 用于实时监控录音音量大小
  Stream<RecordResponse> get responseFromAmplitude => _platform.getAmplitudeStream(id);

  /// 获取播放状态流
  /// 监控音频播放状态的变化
  Stream<PlayState> get responsePlayStateController => _platform.getPlayStateStream(id);

  /// 初始化录音功能
  /// 必须在使用其他录音功能前调用
  Future<void> init() async {
    await _platform.initRecorder(id);
  }

  /// 初始化MP3录音功能
  /// 使用MP3格式进行录音
  Future<void> initRecordMp3() async {
    await _platform.initRecordMp3(id);
  }

  /// 开始录音
  /// 使用默认设置开始录音
  Future<void> start() async {
    await _platform.startRecord(id);
  }

  /// 通过指定WAV文件路径开始录音
  /// [wavPath] 指定的WAV文件路径
  Future<void> startByWavPath(String wavPath) async {
    await _platform.startByWavPath(id, wavPath);
  }

  /// 停止录音
  /// 结束当前录音并返回录音文件信息
  Future<void> stop() async {
    await _platform.stopRecord(id);
  }

  /// 播放录音
  /// 播放最近一次录制的音频文件
  Future<void> play() async {
    await _platform.playRecord(id);
  }

  /// 播放指定路径的音频文件
  /// [path] 音频文件路径，可以是本地文件路径或网络URL
  /// [type] 音频文件类型，'url' 表示网络音频，'file' 表示本地文件
  Future<void> playByPath(String path, String type) async {
    await _platform.playByPath(id, path, type);
  }

  /// 暂停或继续播放
  /// 如果当前正在播放则暂停，如果当前已暂停则继续播放
  Future<void> pausePlay() async {
    await _platform.pausePlay(id);
  }

  /// 停止播放
  /// 完全停止当前音频播放
  Future<void> stopPlay() async {
    await _platform.stopPlay(id);
  }

  /// 释放资源
  /// 在不再需要录音功能时调用，释放相关资源
  void dispose() {
    if (_platform is MethodChannelFlutterPluginRecord329) {
      (_platform as MethodChannelFlutterPluginRecord329).dispose(id);
    }
  }
}