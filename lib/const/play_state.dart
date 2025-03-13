/// 音频播放状态类
/// 用于表示音频播放的当前状态和播放路径
class PlayState {
  /// 播放状态
  final String playState;
  
  /// 音频文件路径
  final String playPath;

  /// 构造函数
  /// [playState] 播放状态
  /// [playPath] 音频文件路径
  const PlayState(this.playState, this.playPath);
}
