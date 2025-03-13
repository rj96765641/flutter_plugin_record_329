#import "DPAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface DPAudioPlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, copy) NSString *currentPath;

@end

@implementation DPAudioPlayer

#pragma mark - Playback Methods

- (void)playRecord {
    // 默认播放最后一次录音
    if (self.currentPath) {
        [self playByPath:self.currentPath type:@"file"];
    }
}

- (void)playByPath:(NSString *)path type:(NSString *)type {
    if (self.isPlaying) {
        [self stopPlay];
    }
    
    self.currentPath = path;
    NSURL *audioURL;
    
    if ([type isEqualToString:@"url"]) {
        audioURL = [NSURL URLWithString:path];
    } else {
        audioURL = [NSURL fileURLWithPath:path];
    }
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
    
    if (error) {
        [self sendPlayStateEvent:NO path:path error:error.localizedDescription];
        return;
    }
    
    self.audioPlayer.delegate = self;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if ([self.audioPlayer play]) {
        self.isPlaying = YES;
        [self sendPlayStateEvent:YES path:path error:nil];
    } else {
        [self sendPlayStateEvent:NO path:path error:@"播放启动失败"];
    }
}

- (BOOL)pausePlay {
    if (!self.audioPlayer) return NO;
    
    if (self.isPlaying) {
        [self.audioPlayer pause];
        self.isPlaying = NO;
    } else {
        [self.audioPlayer play];
        self.isPlaying = YES;
    }
    
    [self sendPlayStateEvent:self.isPlaying path:self.currentPath error:nil];
    return self.isPlaying;
}

- (void)stopPlay {
    if (!self.audioPlayer) return;
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    self.isPlaying = NO;
    [self sendPlayStateEvent:NO path:self.currentPath error:nil];
}

#pragma mark - Helper Methods

- (void)sendPlayStateEvent:(BOOL)isPlaying path:(NSString *)path error:(NSString *)error {
    NSMutableDictionary *arguments = [@{
        @"id": self.instanceId,
        @"isPlaying": @(isPlaying),
        @"path": path ?: @""
    } mutableCopy];
    
    if (error) {
        arguments[@"error"] = error;
    }
    
    [self.methodChannel invokeMethod:@"onPlayState" arguments:arguments];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.isPlaying = NO;
    [self sendPlayStateEvent:NO path:self.currentPath error:nil];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    self.isPlaying = NO;
    [self sendPlayStateEvent:NO path:self.currentPath error:error.localizedDescription];
}

#pragma mark - Cleanup

- (void)cleanup {
    [self stopPlay];
}

@end 