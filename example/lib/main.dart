import 'package:flutter/material.dart';
import 'package:flutter_plugin_record_329_example/path_provider_screen.dart';
import 'package:flutter_plugin_record_329_example/record_mp3_screen.dart';
import 'package:flutter_plugin_record_329_example/record_screen.dart';
import 'package:flutter_plugin_record_329_example/wechat_record_screen.dart';

/// 应用程序入口
void main() => runApp(const MyApp());

/// 应用程序根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '录音插件示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '录音插件示例'),
      routes: {
        'RecordScreen': (context) => RecordScreen(),
        'RecordMp3Screen': (context) => RecordMp3Screen(),
        'WeChatRecordScreen': (context) => WeChatRecordScreen(),
        'PathProviderScreen': (context) => PathProviderScreen(),
      },
    );
  }
}

/// 主页面组件
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// 主页面状态类
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('录音插件示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildNavigationButton(
              context,
              'RecordScreen',
              '进入语音录制界面',
            ),
            _buildNavigationButton(
              context,
              'RecordMp3Screen',
              '进入录制MP3模式',
            ),
            _buildNavigationButton(
              context,
              'WeChatRecordScreen',
              '进入仿微信录制界面',
            ),
            _buildNavigationButton(
              context,
              'PathProviderScreen',
              '进入文件路径获取界面',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建导航按钮
  Widget _buildNavigationButton(BuildContext context, String route, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(label),
      ),
    );
  }
}
