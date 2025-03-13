import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// 文件路径获取界面
/// 演示如何获取各种系统目录路径
class PathProviderScreen extends StatefulWidget {
  const PathProviderScreen({super.key});

  @override
  State<PathProviderScreen> createState() => _PathProviderScreenState();
}

class _PathProviderScreenState extends State<PathProviderScreen> {
  /// 临时目录
  Future<Directory?>? _tempDirectory;
  
  /// 应用支持目录
  Future<Directory?>? _appSupportDirectory;
  
  /// 应用库目录
  Future<Directory?>? _appLibraryDirectory;
  
  /// 应用文档目录
  Future<Directory?>? _appDocumentsDirectory;
  
  /// 外部文档目录
  Future<Directory?>? _externalDocumentsDirectory;
  
  /// 外部存储目录列表
  Future<List<Directory>?>? _externalStorageDirectories;
  
  /// 外部缓存目录列表
  Future<List<Directory>?>? _externalCacheDirectories;

  /// 构建单个目录路径显示组件
  Widget _buildDirectory(BuildContext context, AsyncSnapshot<Directory?> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return _buildErrorText('错误: ${snapshot.error}');
      } else if (snapshot.hasData && snapshot.data != null) {
        return _buildPathText('路径: ${snapshot.data!.path}');
      } else {
        return _buildPathText('路径不可用');
      }
    }
    return _buildPathText('加载中...');
  }

  /// 构建多个目录路径显示组件
  Widget _buildDirectories(BuildContext context, AsyncSnapshot<List<Directory>?> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return _buildErrorText('错误: ${snapshot.error}');
      } else if (snapshot.hasData && snapshot.data != null) {
        final String combined = snapshot.data!.map((d) => d.path).join(', ');
        return _buildPathText('路径列表: $combined');
      } else {
        return _buildPathText('路径不可用');
      }
    }
    return _buildPathText('加载中...');
  }

  /// 构建错误文本组件
  Widget _buildErrorText(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  /// 构建路径文本组件
  Widget _buildPathText(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(text),
    );
  }

  /// 构建按钮组件
  Widget _buildButton(String label, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }

  /// 获取临时目录
  void _requestTempDirectory() {
    setState(() {
      _tempDirectory = getTemporaryDirectory();
    });
  }

  /// 获取应用文档目录
  void _requestAppDocumentsDirectory() {
    setState(() {
      _appDocumentsDirectory = getApplicationDocumentsDirectory();
    });
  }

  /// 获取应用支持目录
  void _requestAppSupportDirectory() {
    setState(() {
      _appSupportDirectory = getApplicationSupportDirectory();
    });
  }

  /// 获取应用库目录
  void _requestAppLibraryDirectory() {
    setState(() {
      _appLibraryDirectory = getLibraryDirectory();
    });
  }

  /// 获取外部存储目录
  void _requestExternalStorageDirectory() {
    setState(() {
      _externalDocumentsDirectory = getExternalStorageDirectory();
    });
  }

  /// 获取外部存储目录列表
  void _requestExternalStorageDirectories(StorageDirectory type) {
    setState(() {
      _externalStorageDirectories = getExternalStorageDirectories(type: type);
    });
  }

  /// 获取外部缓存目录列表
  void _requestExternalCacheDirectories() {
    setState(() {
      _externalCacheDirectories = getExternalCacheDirectories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('获取文件路径界面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: <Widget>[
          _buildButton('获取临时目录', _requestTempDirectory),
          FutureBuilder<Directory?>(
            future: _tempDirectory,
            builder: _buildDirectory,
          ),
          _buildButton('获取应用文档目录', _requestAppDocumentsDirectory),
          FutureBuilder<Directory?>(
            future: _appDocumentsDirectory,
            builder: _buildDirectory,
          ),
          _buildButton('获取应用支持目录', _requestAppSupportDirectory),
          FutureBuilder<Directory?>(
            future: _appSupportDirectory,
            builder: _buildDirectory,
          ),
          _buildButton('获取应用库目录', _requestAppLibraryDirectory),
          FutureBuilder<Directory?>(
            future: _appLibraryDirectory,
            builder: _buildDirectory,
          ),
          _buildButton(
            Platform.isIOS
                ? 'iOS不支持外部目录'
                : '获取外部存储目录',
            Platform.isIOS ? null : _requestExternalStorageDirectory,
          ),
          FutureBuilder<Directory?>(
            future: _externalDocumentsDirectory,
            builder: _buildDirectory,
          ),
          _buildButton(
            Platform.isIOS
                ? 'iOS不支持外部目录'
                : '获取外部存储目录列表',
            Platform.isIOS
                ? null
                : () => _requestExternalStorageDirectories(StorageDirectory.music),
          ),
          FutureBuilder<List<Directory>?>(
            future: _externalStorageDirectories,
            builder: _buildDirectories,
          ),
          _buildButton(
            Platform.isIOS
                ? 'iOS不支持外部目录'
                : '获取外部缓存目录列表',
            Platform.isIOS ? null : _requestExternalCacheDirectories,
          ),
          FutureBuilder<List<Directory>?>(
            future: _externalCacheDirectories,
            builder: _buildDirectories,
          ),
        ],
      ),
    );
  }
}