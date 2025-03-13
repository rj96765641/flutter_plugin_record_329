#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPAudioPlayer : NSObject

/// 实例ID
@property (nonatomic, copy) NSString *instanceId;
/// 方法通道
@property (nonatomic, weak) FlutterMethodChannel *methodChannel;

/// 播放录音文件
- (void)playRecord;
/// 通过路径播放
- (void)playByPath:(NSString *)path type:(NSString *)type;
/// 暂停/继续播放
- (BOOL)pausePlay;
/// 停止播放
- (void)stopPlay;
/// 清理资源
- (void)cleanup;

@end

NS_ASSUME_NONNULL_END 