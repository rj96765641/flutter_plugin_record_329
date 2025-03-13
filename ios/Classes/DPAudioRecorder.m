#import "DPAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "JX_GCDTimerManager.h"

#define MAX_RECORDER_TIME 2100  // 最大录制时间（秒）
#define MIN_RECORDER_TIME 1     // 最小录制时间（秒）
#define TIMER_NAME_PREFIX @"audioTimer_"  // 定时器前缀

@interface DPAudioRecorder () <AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, copy) NSString *recordPath;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSTimeInterval audioTimeLength;
@property (nonatomic, strong) dispatch_source_t amplitudeTimer;

@end

@implementation DPAudioRecorder

#pragma mark - Setup Methods

- (void)setupRecorder {
    [self setupRecorderWithFormat:kAudioFormatLinearPCM];
}

- (void)setupRecorderWithMp3 {
    [self setupRecorderWithFormat:kAudioFormatMPEGLayer3];
}

- (void)setupRecorderWithFormat:(AudioFormatID)formatID {
    // 设置录音文件路径
    NSString *directory = NSTemporaryDirectory();
    self.recordPath = [directory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"recording_%@.%@", 
                       self.instanceId,
                       (formatID == kAudioFormatMPEGLayer3) ? @"mp3" : @"wav"]];
    
    // 录音设置
    NSDictionary *settings = @{
        AVFormatIDKey: @(formatID),
        AVSampleRateKey: @22050.0f,
        AVNumberOfChannelsKey: @1,
        AVLinearPCMBitDepthKey: @16,
        AVLinearPCMIsFloatKey: @NO,
        AVLinearPCMIsBigEndianKey: @NO
    };
    
    NSError *error = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordPath]
                                                    settings:settings
                                                       error:&error];
    
    if (error) {
        [self sendEventWithName:@"onInit" arguments:@{
            @"id": self.instanceId,
            @"result": @"error",
            @"errorMsg": error.localizedDescription
        }];
        return;
    }
    
    self.audioRecorder.delegate = self;
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder prepareToRecord];
    
    [self sendEventWithName:@"onInit" arguments:@{
        @"id": self.instanceId,
        @"result": @"success"
    }];
}

#pragma mark - Recording Methods

- (void)startRecord {
    if (self.isRecording) return;
    
    [self startRecordingWithPath:self.recordPath];
}

- (void)startRecordWithWavPath:(NSString *)wavPath {
    if (self.isRecording) return;
    
    self.recordPath = wavPath;
    [self startRecordingWithPath:wavPath];
}

- (void)startRecordingWithPath:(NSString *)path {
    if ([self.audioRecorder record]) {
        self.isRecording = YES;
        self.audioTimeLength = 0;
        [self startAmplitudeTimer];
        [self startRecordingTimer];
        
        [self sendEventWithName:@"onStart" arguments:@{
            @"id": self.instanceId,
            @"result": @"success"
        }];
    } else {
        [self sendEventWithName:@"onStart" arguments:@{
            @"id": self.instanceId,
            @"result": @"error",
            @"errorMsg": @"录音启动失败"
        }];
    }
}

- (void)stopRecord {
    if (!self.isRecording) return;
    
    [self.audioRecorder stop];
    self.isRecording = NO;
    [self stopAmplitudeTimer];
    [self stopRecordingTimer];
    
    [self sendEventWithName:@"onStop" arguments:@{
        @"id": self.instanceId,
        @"result": @"success",
        @"path": self.recordPath,
        @"audioTimeLength": @(self.audioTimeLength)
    }];
}

#pragma mark - Timer Methods

- (void)startAmplitudeTimer {
    if (self.amplitudeTimer) {
        dispatch_source_cancel(self.amplitudeTimer);
    }
    
    self.amplitudeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.amplitudeTimer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.amplitudeTimer, ^{
        [weakSelf updateAmplitude];
    });
    
    dispatch_resume(self.amplitudeTimer);
}

- (void)stopAmplitudeTimer {
    if (self.amplitudeTimer) {
        dispatch_source_cancel(self.amplitudeTimer);
        self.amplitudeTimer = nil;
    }
}

- (void)startRecordingTimer {
    NSString *timerName = [NSString stringWithFormat:@"%@%@", TIMER_NAME_PREFIX, self.instanceId];
    
    [[JX_GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:timerName
                                                          timeInterval:0.1
                                                                queue:dispatch_get_main_queue()
                                                              repeats:YES
                                                         actionOption:AbandonPreviousAction
                                                              action:^{
        self.audioTimeLength += 0.1;
        if (self.audioTimeLength >= MAX_RECORDER_TIME) {
            [self stopRecord];
        }
    }];
}

- (void)stopRecordingTimer {
    NSString *timerName = [NSString stringWithFormat:@"%@%@", TIMER_NAME_PREFIX, self.instanceId];
    [[JX_GCDTimerManager sharedInstance] cancelTimerWithName:timerName];
}

#pragma mark - Helper Methods

- (void)updateAmplitude {
    [self.audioRecorder updateMeters];
    float power = [self.audioRecorder averagePowerForChannel:0];
    power = pow(10, (0.05 * power));
    
    [self sendEventWithName:@"onAmplitude" arguments:@{
        @"id": self.instanceId,
        @"result": @"success",
        @"amplitude": @(power)
    }];
}

- (void)sendEventWithName:(NSString *)name arguments:(NSDictionary *)arguments {
    if (self.methodChannel) {
        [self.methodChannel invokeMethod:name arguments:arguments];
    }
}

#pragma mark - Cleanup

- (void)cleanup {
    [self stopRecord];
    self.audioRecorder = nil;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (!flag) {
        [self sendEventWithName:@"onStop" arguments:@{
            @"id": self.instanceId,
            @"result": @"error",
            @"errorMsg": @"录音完成但发生错误"
        }];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    [self sendEventWithName:@"onStop" arguments:@{
        @"id": self.instanceId,
        @"result": @"error",
        @"errorMsg": error.localizedDescription
    }];
}

@end 