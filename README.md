# Flutter 语音录制插件 (支持 Flutter 3.29.0)

一个轻量级的 Flutter 语音录制插件，提供类似微信的语音录制功能，支持 Android 和 iOS 平台。

## ✨ 主要特性

- 🎤 支持 WAV/MP3 格式录制
- 🎵 支持本地和网络音频播放
- 📊 实时音量监测
- ⏱️ 录制时长监听
- 🎯 微信风格录制组件
- 📁 自定义录音文件路径
- ⏯️ 完整的播放控制（播放/暂停/停止）

## 📋 环境要求

- Flutter SDK: >=3.29.0
- Dart SDK: >=3.0.0 <4.0.0
- Android: 4.1+
- iOS: 9.0+

## 📦 安装

```yaml
dependencies:
  flutter_plugin_record_329: ^1.0.1
```

## 🚀 快速开始

### 基础用法

```dart
// 1. 初始化
final recordPlugin = FlutterPluginRecord();
await recordPlugin.init(); // WAV 格式
// 或
await recordPlugin.initRecordMp3(); // MP3 格式

// 2. 开始录制
recordPlugin.start();

// 3. 停止录制
recordPlugin.stop();

// 4. 播放录音
recordPlugin.play();
```

### 状态监听

```dart
// 录制状态监听
recordPlugin.response.listen((data) {
  switch (data.msg) {
    case "onStart": print("开始录制");
    case "onStop": print("录制结束：${data.path}");
  }
});

// 音量监听
recordPlugin.responseFromAmplitude.listen((data) {
  final volume = double.parse(data.msg);
  // 处理音量数据
});
```

## 📱 平台配置

### iOS
```xml
<!-- Info.plist -->
<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风进行录音</string>
```

### Android
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

## 📸 效果展示

<div style="display: flex; justify-content: space-around;">
  <div>
    <p align="center">Android</p>
    <img src="README_images/video2gif_20191118_101627.gif" width="300"/>
  </div>
  <div>
    <p align="center">iOS</p>
    <img src="README_images/ios.gif" width="300"/>
  </div>
</div>

## 📄 许可证
MIT License

## 👨‍💻 贡献者

感谢 [肖中旺](https://github.com/xzw421771880) 对 iOS 在线 WAV 播放的支持。

## 🔗 相关项目

- [Flutter 腾讯云点播播放器](https://github.com/yxwandroid/flutter_tencentplayer_plus)
- [Flutter 二维码扫描](https://github.com/yxwandroid/flutter_plugin_qrcode)
- [Flutter 抖音开放平台 SDK](https://github.com/yxwandroid/flutter_plugin_douyin_open)
- [Flutter 高德地图](https://github.com/yxwandroid/flutter_amap_location)
- [Flutter 模板工程](https://github.com/yxwandroid/flutter_app_redux)

## 📱 获取更多资讯

<img src="README_images/f53502b3.png" width="200" align="center" />

