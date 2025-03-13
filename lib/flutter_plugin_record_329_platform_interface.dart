import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:async';

import 'const/play_state.dart';
import 'const/response.dart';
import 'flutter_plugin_record_329_method_channel.dart';

/// 录音插件的平台接口抽象类
/// 定义了录音插件在各平台必须实现的方法和功能
abstract class FlutterPluginRecord329Platform extends PlatformInterface {
  /// 构造函数，初始化平台接口
  FlutterPluginRecord329Platform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPluginRecord329Platform _instance = MethodChannelFlutterPluginRecord329();

  /// [FlutterPluginRecord329Platform]的默认实例
  ///
  /// 默认为[MethodChannelFlutterPluginRecord329]实现
  static FlutterPluginRecord329Platform get instance => _instance;

  /// 平台特定的实现应该在注册时设置这个实例
  static set instance(FlutterPluginRecord329Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 获取平台版本
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() 尚未实现.');
  }

  /// 初始化录音功能
  Future<void> initRecorder(String id) {
    throw UnimplementedError('initRecorder() 尚未实现.');
  }

  /// 初始化MP3录音功能
  Future<void> initRecordMp3(String id) {
    throw UnimplementedError('initRecordMp3() 尚未实现.');
  }

  /// 开始录音
  Future<void> startRecord(String id) {
    throw UnimplementedError('startRecord() 尚未实现.');
  }

  /// 使用指定的WAV路径开始录音
  Future<void> startByWavPath(String id, String wavPath) {
    throw UnimplementedError('startByWavPath() 尚未实现.');
  }

  /// 停止录音
  Future<void> stopRecord(String id) {
    throw UnimplementedError('stopRecord() 尚未实现.');
  }

  /// 播放录音
  Future<void> playRecord(String id) {
    throw UnimplementedError('playRecord() 尚未实现.');
  }

  /// 通过指定路径播放音频
  Future<void> playByPath(String id, String path, String type) {
    throw UnimplementedError('playByPath() 尚未实现.');
  }

  /// 暂停或继续播放
  Future<void> pausePlay(String id) {
    throw UnimplementedError('pausePlay() 尚未实现.');
  }

  /// 停止播放
  Future<void> stopPlay(String id) {
    throw UnimplementedError('stopPlay() 尚未实现.');
  }

  /// 获取初始化状态流
  Stream<bool> getInitializedStateStream(String id) {
    throw UnimplementedError('getInitializedStateStream() 尚未实现.');
  }

  /// 获取录音响应流
  Stream<RecordResponse> getRecordResponseStream(String id) {
    throw UnimplementedError('getRecordResponseStream() 尚未实现.');
  }

  /// 获取振幅响应流
  Stream<RecordResponse> getAmplitudeStream(String id) {
    throw UnimplementedError('getAmplitudeStream() 尚未实现.');
  }

  /// 获取播放状态流
  Stream<PlayState> getPlayStateStream(String id) {
    throw UnimplementedError('getPlayStateStream() 尚未实现.');
  }
}