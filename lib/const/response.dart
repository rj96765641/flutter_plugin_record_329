/// 录音响应类
/// 用于封装录音操作的结果信息
class RecordResponse {
  /// 操作是否成功
  final bool? success;
  
  /// 音频文件路径
  final String? path;
  
  /// 响应消息
  final String? msg;
  
  /// 唯一标识符
  final String? key;
  
  /// 音频时长（秒）
  final double? audioTimeLength;

  /// 构造函数
  /// [success] 操作是否成功
  /// [path] 音频文件路径
  /// [msg] 响应消息
  /// [key] 唯一标识符
  /// [audioTimeLength] 音频时长（秒）
  const RecordResponse({
    this.success,
    this.path,
    this.msg,
    this.key,
    this.audioTimeLength,
  });
//  RecordResponse({this.success, this.path,this.msg,this.key});

}
