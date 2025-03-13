#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPAudioRecorder : NSObject

/// 实例ID
@property (nonatomic, copy) NSString *instanceId;
/// 方法通道
@property (nonatomic, weak) FlutterMethodChannel *methodChannel;
/// 录音文件路径
@property (nonatomic, copy, readonly) NSString *recordPath;

/// 设置录音器
- (void)setupRecorder;
/// 设置MP3录音器
- (void)setupRecorderWithMp3;
/// 开始录音
- (void)startRecord;
/// 使用指定路径开始录音
- (void)startRecordWithWavPath:(NSString *)wavPath;
/// 停止录音
- (void)stopRecord;
/// 清理资源
- (void)cleanup;

@end

NS_ASSUME_NONNULL_END 