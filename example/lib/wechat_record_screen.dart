import 'package:flutter/material.dart';

import 'package:flutter_plugin_record_329/flutter_plugin_record_329.dart';
/// 仿微信语音录制界面
/// 演示自定义悬浮窗和语音录制功能
class WeChatRecordScreen extends StatefulWidget {
  const WeChatRecordScreen({super.key});

  @override
  State<WeChatRecordScreen> createState() => _WeChatRecordScreenState();
}

class _WeChatRecordScreenState extends State<WeChatRecordScreen> {
  /// 悬浮窗显示的文本
  String _toastText = '悬浮框';
  
  /// 悬浮窗实例
  OverlayEntry? _overlayEntry;

  /// 显示悬浮窗
  void _showOverlay(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).size.height * 0.5 - 80,
          left: MediaQuery.of(context).size.width * 0.5 - 80,
          child: Material(
            child: Center(
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF77797A),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _toastText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  /// 开始录音
  void _startRecord() {
    debugPrint('开始录制');
  }

  /// 停止录音
  /// [path] 录音文件路径
  /// [audioTimeLength] 录音时长（秒）
  void _stopRecord(String path, double audioTimeLength) {
    debugPrint('结束录制');
    debugPrint('音频文件位置: $path');
    debugPrint('音频录制时长: $audioTimeLength秒');
  }

  /// 隐藏悬浮窗
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 更新悬浮窗文本
  void _updateOverlayText() {
    setState(() {
      _toastText = '111';
      _overlayEntry?.markNeedsBuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('仿微信发送语音'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildButton('显示悬浮窗', () => _showOverlay(context)),
            _buildButton('隐藏悬浮窗', _hideOverlay),
            _buildButton('更新悬浮窗文本', _updateOverlayText),
            const SizedBox(height: 20),
            VoiceWidget(
              startRecord: _startRecord,
              stopRecord: _stopRecord,
              height: 40.0,
            ),
          ],
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

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }
}
