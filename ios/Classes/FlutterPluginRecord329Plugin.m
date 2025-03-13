#import "FlutterPluginRecord329Plugin.h"
#import "DPAudioRecorder.h"
#import "DPAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

/// 插件主类，负责处理与 Flutter 端的通信
@interface FlutterPluginRecord329Plugin()

/// 存储所有录音实例，key 为实例 ID
@property (nonatomic, strong) NSMutableDictionary<NSString *, DPAudioRecorder *> *recorders;
/// 存储所有播放器实例，key 为实例 ID
@property (nonatomic, strong) NSMutableDictionary<NSString *, DPAudioPlayer *> *players;
/// 方法通道
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@end

@implementation FlutterPluginRecord329Plugin

#pragma mark - Plugin Registration

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"flutter_plugin_record_329"
                                   binaryMessenger:[registrar messenger]];
    FlutterPluginRecord329Plugin* instance = [[FlutterPluginRecord329Plugin alloc] init];
    instance.methodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _recorders = [NSMutableDictionary dictionary];
        _players = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Method Call Handler

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // 获取实例 ID
    NSString *instanceId = call.arguments[@"id"];
    if (!instanceId) {
        result([FlutterError errorWithCode:@"NO_ID" 
                                 message:@"未提供实例 ID"
                                 details:nil]);
        return;
    }
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([[UIDevice currentDevice] systemVersion]);
    }
    else if ([@"init" isEqualToString:call.method]) {
        [self initRecorder:instanceId result:result];
    }
    else if ([@"initRecordMp3" isEqualToString:call.method]) {
        [self initRecordMp3:instanceId result:result];
    }
    else if ([@"start" isEqualToString:call.method]) {
        [self startRecord:instanceId result:result];
    }
    else if ([@"startByWavPath" isEqualToString:call.method]) {
        NSString *wavPath = call.arguments[@"wavPath"];
        [self startByWavPath:instanceId wavPath:wavPath result:result];
    }
    else if ([@"stop" isEqualToString:call.method]) {
        [self stopRecord:instanceId result:result];
    }
    else if ([@"play" isEqualToString:call.method]) {
        [self playRecord:instanceId result:result];
    }
    else if ([@"playByPath" isEqualToString:call.method]) {
        NSString *path = call.arguments[@"path"];
        NSString *type = call.arguments[@"type"];
        [self playByPath:instanceId path:path type:type result:result];
    }
    else if ([@"pause" isEqualToString:call.method]) {
        [self pausePlay:instanceId result:result];
    }
    else if ([@"stopPlay" isEqualToString:call.method]) {
        [self stopPlay:instanceId result:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Permission Check

/// 检查麦克风权限
- (void)checkPermission:(void(^)(BOOL granted))completion {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
                  mode:AVAudioSessionModeDefault
               options:AVAudioSessionCategoryOptionDefaultToSpeaker
                 error:nil];
    [session setActive:YES error:nil];
    
    [session requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(granted);
        });
    }];
}

#pragma mark - Recorder Methods

/// 初始化录音器
- (void)initRecorder:(NSString *)instanceId result:(FlutterResult)result {
    [self checkPermission:^(BOOL granted) {
        if (granted) {
            DPAudioRecorder *recorder = [[DPAudioRecorder alloc] init];
            recorder.instanceId = instanceId;
            recorder.methodChannel = self.methodChannel;
            [recorder setupRecorder];
            self.recorders[instanceId] = recorder;
            result(@{@"result": @"success"});
        } else {
            result([FlutterError errorWithCode:@"PERMISSION_DENIED"
                                     message:@"麦克风权限被拒绝"
                                     details:nil]);
        }
    }];
}

/// 初始化 MP3 录音器
- (void)initRecordMp3:(NSString *)instanceId result:(FlutterResult)result {
    [self checkPermission:^(BOOL granted) {
        if (granted) {
            DPAudioRecorder *recorder = [[DPAudioRecorder alloc] init];
            recorder.instanceId = instanceId;
            recorder.methodChannel = self.methodChannel;
            [recorder setupRecorderWithMp3];
            self.recorders[instanceId] = recorder;
            result(@{@"result": @"success"});
        } else {
            result([FlutterError errorWithCode:@"PERMISSION_DENIED"
                                     message:@"麦克风权限被拒绝"
                                     details:nil]);
        }
    }];
}

#pragma mark - Recording Methods

/// 开始录音
- (void)startRecord:(NSString *)instanceId result:(FlutterResult)result {
    DPAudioRecorder *recorder = self.recorders[instanceId];
    if (!recorder) {
        result([FlutterError errorWithCode:@"NOT_INITIALIZED"
                                 message:@"录音器未初始化"
                                 details:nil]);
        return;
    }
    
    [recorder startRecord];
    result(@{@"result": @"success"});
}

/// 使用指定路径开始录音
- (void)startByWavPath:(NSString *)instanceId wavPath:(NSString *)wavPath result:(FlutterResult)result {
    DPAudioRecorder *recorder = self.recorders[instanceId];
    if (!recorder) {
        result([FlutterError errorWithCode:@"NOT_INITIALIZED"
                                 message:@"录音器未初始化"
                                 details:nil]);
        return;
    }
    
    [recorder startRecordWithWavPath:wavPath];
    result(@{@"result": @"success"});
}

/// 停止录音
- (void)stopRecord:(NSString *)instanceId result:(FlutterResult)result {
    DPAudioRecorder *recorder = self.recorders[instanceId];
    if (!recorder) {
        result([FlutterError errorWithCode:@"NOT_INITIALIZED"
                                 message:@"录音器未初始化"
                                 details:nil]);
        return;
    }
    
    [recorder stopRecord];
    result(@{@"result": @"success"});
}

#pragma mark - Playback Methods

/// 播放录音
- (void)playRecord:(NSString *)instanceId result:(FlutterResult)result {
    DPAudioPlayer *player = [self getOrCreatePlayerForId:instanceId];
    [player playRecord];
    result(@{@"result": @"success"});
}

/// 通过指定路径播放
- (void)playByPath:(NSString *)instanceId path:(NSString *)path type:(NSString *)type result:(FlutterResult)result {
    DPAudioPlayer *player = [self getOrCreatePlayerForId:instanceId];
    [player playByPath:path type:type];
    result(@{@"result": @"success"});
}

/// 暂停播放
- (void)pausePlay:(NSString *)instanceId result:(FlutterResult)result {
    DPAudioPlayer *player = self.players[instanceId];
    if (!player) {
        result([FlutterError errorWithCode:@"NO_PLAYER"
                                 message:@"播放器未初始化"
                                 details:nil]);
        return;
    }
    
    BOOL isPlaying = [player pausePlay];
    result(@{@"isPlaying": @(isPlaying)});
}

/// 停止播放
- (void)stopPlay:(NSString *)instanceId result:(FlutterResult)result {
    DPAudioPlayer *player = self.players[instanceId];
    if (!player) {
        result([FlutterError errorWithCode:@"NO_PLAYER"
                                 message:@"播放器未初始化"
                                 details:nil]);
        return;
    }
    
    [player stopPlay];
    result(@{@"result": @"success"});
}

#pragma mark - Helper Methods

/// 获取或创建播放器实例
- (DPAudioPlayer *)getOrCreatePlayerForId:(NSString *)instanceId {
    DPAudioPlayer *player = self.players[instanceId];
    if (!player) {
        player = [[DPAudioPlayer alloc] init];
        player.instanceId = instanceId;
        player.methodChannel = self.methodChannel;
        self.players[instanceId] = player;
    }
    return player;
}

#pragma mark - Cleanup

/// 清理指定实例的资源
- (void)cleanupInstance:(NSString *)instanceId {
    DPAudioRecorder *recorder = self.recorders[instanceId];
    if (recorder) {
        [recorder cleanup];
        [self.recorders removeObjectForKey:instanceId];
    }
    
    DPAudioPlayer *player = self.players[instanceId];
    if (player) {
        [player cleanup];
        [self.players removeObjectForKey:instanceId];
    }
}

- (void)dealloc {
    // 清理所有实例
    for (NSString *instanceId in self.recorders.allKeys) {
        [self cleanupInstance:instanceId];
    }
}

@end