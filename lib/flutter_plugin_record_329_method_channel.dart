import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'flutter_plugin_record_329_platform_interface.dart';
import 'const/play_state.dart';
import 'const/response.dart';

/// 基于方法通道的录音插件实现
/// 使用MethodChannel与原生平台通信实现录音功能
class MethodChannelFlutterPluginRecord329 extends FlutterPluginRecord329Platform {
  /// 用于与原生平台交互的方法通道
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_plugin_record_329');

  /// 存储所有实例的初始化状态流控制器
  final Map<String, StreamController<bool>> _initControllers = {};

  /// 存储所有实例的录音响应流控制器
  final Map<String, StreamController<RecordResponse>> _recordResponseControllers = {};

  /// 存储所有实例的振幅响应流控制器
  final Map<String, StreamController<RecordResponse>> _amplitudeControllers = {};

  /// 存储所有实例的播放状态流控制器
  final Map<String, StreamController<PlayState>> _playStateControllers = {};

  /// 构造函数，设置方法调用处理器
  MethodChannelFlutterPluginRecord329() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  /// 获取平台版本
  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// 处理来自原生平台的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    final String id = (call.arguments as Map)['id'];
    switch (call.method) {
      case "onInit":
        print("onInit----${call.arguments}");
        final bool success = call.arguments["result"] == "success";
        _getInitController(id).add(success);
        break;

      case "onStart":
        if (call.arguments["result"] == "success") {
          final RecordResponse res = RecordResponse(
            success: true,
            path: "",
            msg: "onStart",
            key: call.arguments["key"].toString(),
          );
          _getRecordResponseController(id).add(res);
        }
        break;

      case "onStop":
        if (call.arguments["result"] == "success") {
          final RecordResponse res = RecordResponse(
            success: true,
            path: call.arguments["voicePath"].toString(),
            audioTimeLength: double.parse(call.arguments["audioTimeLength"]),
            msg: "onStop",
            key: call.arguments["key"].toString(),
          );
          _getRecordResponseController(id).add(res);
        }
        break;

      case "onPlay":
        final RecordResponse res = RecordResponse(
          success: true,
          path: "",
          msg: "开始播放",
          key: call.arguments["key"].toString(),
        );
        _getRecordResponseController(id).add(res);
        break;

      case "onAmplitude":
        if (call.arguments["result"] == "success") {
          final RecordResponse res = RecordResponse(
            success: true,
            path: "",
            msg: call.arguments["amplitude"].toString(),
            key: call.arguments["key"].toString(),
          );
          _getAmplitudeController(id).add(res);
        }
        break;

      case "onPlayState":
        final PlayState res = PlayState(
          call.arguments["playState"],
          call.arguments["playPath"],
        );
        _getPlayStateController(id).add(res);
        break;

      case "pausePlay":
        final PlayState res = PlayState(
          call.arguments["isPlaying"],
          "",
        );
        _getPlayStateController(id).add(res);
        break;
    }
    return null;
  }

  /// 获取初始化状态流控制器，如果���存在则创建
  StreamController<bool> _getInitController(String id) {
    if (!_initControllers.containsKey(id)) {
      _initControllers[id] = StreamController<bool>.broadcast();
    }
    return _initControllers[id]!;
  }

  /// 获取录音响应流控制器，如果不存在则创建
  StreamController<RecordResponse> _getRecordResponseController(String id) {
    if (!_recordResponseControllers.containsKey(id)) {
      _recordResponseControllers[id] = StreamController<RecordResponse>.broadcast();
    }
    return _recordResponseControllers[id]!;
  }

  /// 获取振幅响应流控制器，如果不存在则创建
  StreamController<RecordResponse> _getAmplitudeController(String id) {
    if (!_amplitudeControllers.containsKey(id)) {
      _amplitudeControllers[id] = StreamController<RecordResponse>.broadcast();
    }
    return _amplitudeControllers[id]!;
  }

  /// 获取播放状态流控制器，如果不存在则创建
  StreamController<PlayState> _getPlayStateController(String id) {
    if (!_playStateControllers.containsKey(id)) {
      _playStateControllers[id] = StreamController<PlayState>.broadcast();
    }
    return _playStateControllers[id]!;
  }

  /// 初始化录音功能
  @override
  Future<void> initRecorder(String id) async {
    await methodChannel.invokeMethod('init', {'init': 'init', 'id': id});
  }

  /// 初始化MP3录音功能
  @override
  Future<void> initRecordMp3(String id) async {
    await methodChannel.invokeMethod('initRecordMp3', {'initRecordMp3': 'initRecordMp3', 'id': id});
  }

  /// 开始录音
  @override
  Future<void> startRecord(String id) async {
    await methodChannel.invokeMethod('start', {'start': 'start', 'id': id});
  }

  /// 使用指定的WAV路径开始录音
  @override
  Future<void> startByWavPath(String id, String wavPath) async {
    await methodChannel.invokeMethod('startByWavPath', {'wavPath': wavPath, 'id': id});
  }

  /// 停止录音
  @override
  Future<void> stopRecord(String id) async {
    await methodChannel.invokeMethod('stop', {'stop': 'stop', 'id': id});
  }

  /// 播放录音
  @override
  Future<void> playRecord(String id) async {
    await methodChannel.invokeMethod('play', {'play': 'play', 'id': id});
  }

  /// 通过指定路径播放音频
  @override
  Future<void> playByPath(String id, String path, String type) async {
    await methodChannel.invokeMethod('playByPath', {
      'play': 'play',
      'path': path,
      'type': type,
      'id': id,
    });
  }

  /// 暂停或继续播放
  @override
  Future<void> pausePlay(String id) async {
    await methodChannel.invokeMethod('pause', {'pause': 'pause', 'id': id});
  }

  /// 停止播放
  @override
  Future<void> stopPlay(String id) async {
    await methodChannel.invokeMethod('stopPlay', {'id': id});
  }

  /// 获取初始化状态流
  @override
  Stream<bool> getInitializedStateStream(String id) {
    return _getInitController(id).stream;
  }

  /// 获取录音响应流
  @override
  Stream<RecordResponse> getRecordResponseStream(String id) {
    return _getRecordResponseController(id).stream;
  }

  /// 获取振幅响应流
  @override
  Stream<RecordResponse> getAmplitudeStream(String id) {
    return _getAmplitudeController(id).stream;
  }

  /// 获取播放状态流
  @override
  Stream<PlayState> getPlayStateStream(String id) {
    return _getPlayStateController(id).stream;
  }

  /// 释放与特定ID关联的资源
  void dispose(String id) {
    if (_initControllers.containsKey(id)) {
      _initControllers[id]!.close();
      _initControllers.remove(id);
    }

    if (_recordResponseControllers.containsKey(id)) {
      _recordResponseControllers[id]!.close();
      _recordResponseControllers.remove(id);
    }

    if (_amplitudeControllers.containsKey(id)) {
      _amplitudeControllers[id]!.close();
      _amplitudeControllers.remove(id);
    }

    if (_playStateControllers.containsKey(id)) {
      _playStateControllers[id]!.close();
      _playStateControllers.remove(id);
    }
  }
}