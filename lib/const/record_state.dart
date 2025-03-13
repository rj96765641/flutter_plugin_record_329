/// 录音状态常量类
/// 定义了与原生平台交互的方法名常量
class RecordState {
  /// 发送到原生端的方法名
  static const String init = 'init';
  static const String start = 'start';
  static const String startByWavPath = 'startByWavPath';
  static const String stop = 'stop';
  static const String play = 'play';
  static const String playByPath = 'playByPath';

  /// 原生端的回调方法名
  static const String onInit = 'onInit';
  static const String onStart = 'onStart';
  static const String onStop = 'onStop';
  static const String onPlay = 'onPlay';
  static const String onAmplitude = 'onAmplitude';
  static const String onPlayState = 'onPlayState';
}
