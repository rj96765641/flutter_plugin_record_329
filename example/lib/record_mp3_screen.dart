import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_record_329/flutter_plugin_record_329.dart';
import 'package:path_provider/path_provider.dart';

/// MP3录音界面
/// 演示MP3格式的录音和播放功能
class RecordMp3Screen extends StatefulWidget {
  const RecordMp3Screen({super.key});

  @override
  State<RecordMp3Screen> createState() => _RecordMp3ScreenState();
}

class _RecordMp3ScreenState extends State<RecordMp3Screen> {
  /// 录音插件实例
  final FlutterPluginRecord329 _recordPlugin = FlutterPluginRecord329();
  
  /// 当前录音文件路径
  String _filePath = '';

  @override
  void initState() {
    super.initState();
    _initializeListeners();
  }

  /// 初始化所有监听器
  void _initializeListeners() {
    // 初始化状态监听
    _recordPlugin.responseFromInit.listen((bool success) {
      debugPrint(success ? '初始化成功' : '初始化失败');
    });

    // 录音状态监听
    _recordPlugin.response.listen((data) {
      if (data.msg == 'onStop') {
        debugPrint('录音结束，文件路径: ${data.path}');
        debugPrint('录音时长: ${data.audioTimeLength}秒');
        if (data.path != null) {
          setState(() => _filePath = data.path!);
        }
      } else if (data.msg == 'onStart') {
        debugPrint('开始录音');
      } else {
        debugPrint('录音状态: ${data.msg}');
      }
    });

    // 音量监听
    _recordPlugin.responseFromAmplitude.listen((data) {
      if (data.msg != null) {
        final double amplitude = double.parse(data.msg!);
        debugPrint('当前音量: $amplitude');
      }
    });

    // 播放状态监听
    _recordPlugin.responsePlayStateController.listen((data) {
      debugPrint('播放路径: ${data.playPath}');
      debugPrint('播放状态: ${data.playState}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MP3录音示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildButton('初始化MP3录音', _initRecordMp3),
              _buildButton('开始录制', _start),
              _buildButton('指定路径录制MP3', _requestAppDocumentsDirectory),
              _buildButton('停止录制', _stop),
              _buildButton('播放录音', _play),
              _buildButton('播放本地录音', () => _playByPath(_filePath, 'file')),
              _buildButton('播放网络音频', () => _playByPath(
                'https://test-1259809289.cos.ap-nanjing.myqcloud.com/temp.mp3',
                'url',
              )),
              _buildButton('暂停/继续播放', _pause),
              _buildButton('停止播放', _stopPlay),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建按钮组件
  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }

  /// 获取应用文档目录并开始录音
  Future<void> _requestAppDocumentsDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String timestamp = DateUtil.getNowDateMs().toString();
    
    // 根据平台生成不同的文件路径
    final String filePath = Platform.isIOS
        ? '${appDir.path}/$timestamp.MP3'  // iOS 需要 .MP3 后缀
        : '${appDir.path}/$timestamp';      // Android 不需要后缀
    
    debugPrint('录音文件路径: $filePath');
    await _startByWavPath(filePath);
  }

  /// 初始化MP3录音功能
  Future<void> _initRecordMp3() async {
    await _recordPlugin.initRecordMp3();
  }

  /// 开始录音
  Future<void> _start() async {
    await _recordPlugin.start();
  }

  /// 在指定路径开始录音
  Future<void> _startByWavPath(String wavPath) async {
    await _recordPlugin.startByWavPath(wavPath);
  }

  /// 停止录音
  Future<void> _stop() async {
    await _recordPlugin.stop();
  }

  /// 播放录音
  Future<void> _play() async {
    await _recordPlugin.play();
  }

  /// 播放指定路径的音频文件
  /// [path] 音频文件路径
  /// [type] 音频类型：'url' 表示网络音频，'file' 表示本地文件
  Future<void> _playByPath(String path, String type) async {
    await _recordPlugin.playByPath(path, type);
  }

  /// 暂停或继续播放
  Future<void> _pause() async {
    await _recordPlugin.pausePlay();
  }

  /// 停止播放
  Future<void> _stopPlay() async {
    await _recordPlugin.stopPlay();
  }

  @override
  void dispose() {
    _recordPlugin.dispose();
    super.dispose();
  }
}
