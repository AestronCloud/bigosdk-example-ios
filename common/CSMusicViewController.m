//
//  CSMusicViewController.m
//  video-live
//
//  Created by 林小程 on 2020/10/21.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSMusicViewController.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSUtils.h"

@interface CSMusicViewController ()

@property (nonatomic, strong) IBOutlet UISlider *audioMixingSlider; // 音乐文件播放进度
@property (nonatomic, strong) IBOutlet UISlider *guideVoiceSlider;  // 导唱播放进度
@property (nonatomic, strong) IBOutlet UISlider *audioEffectSlider; // 音效文件播放进度

@property (nonatomic, assign) int BLRoomMusicPlayStatus;
@property (nonatomic, assign) int BLGuideMusicPlayStatus;
@property (nonatomic, assign) int BLAudioEffectPlayStatus;
@property (nonatomic, assign) int musicFileLength;
@property (nonatomic, assign) int guideFileLength;
@property (nonatomic, assign) int effectFileLength;

@end

@implementation CSMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)actionDidTapBg:(UIControl *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapBgOfMusicViewController:)]) {
        [self.delegate didTapBgOfMusicViewController:self];
    }
}

- (IBAction)actionDidTapAudioPlayBtn:(id)sender {
    if (self.BLRoomMusicPlayStatus == 0) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"m4a"];
        [[CStoreMediaEngineCore sharedSingleton] startAudioMixing:filePath loopback:false replace:false cycle:1];
        self.BLRoomMusicPlayStatus = 1;
        self.musicFileLength =  [[CStoreMediaEngineCore sharedSingleton] getAudioMixingDuration];;
    } else if (self.BLRoomMusicPlayStatus == 2){
        [[CStoreMediaEngineCore sharedSingleton] resumeAudioMixing];
        self.BLRoomMusicPlayStatus = 1;
    }
}

- (IBAction)actionDidTapAudioPauseBtn:(id)sender {
    if (self.BLRoomMusicPlayStatus == 1) {
        [[CStoreMediaEngineCore sharedSingleton] pauseAudioMixing];
        self.BLRoomMusicPlayStatus = 2;
    }
}

- (IBAction)actionDidTapAudioStopBtn:(id)sender {
    [[CStoreMediaEngineCore sharedSingleton] stopAudioMixing];
    self.BLRoomMusicPlayStatus = 0;
    [self.audioMixingSlider setValue:0];
}

- (IBAction)actionDidAudioMixingSlidingValueChange:(UISlider *)sender {
    float progress = self.musicFileLength * sender.value / 100.0;
    if (self.BLRoomMusicPlayStatus == 1)
        [[CStoreMediaEngineCore sharedSingleton] setAudioMixingPosition:progress];
}

- (IBAction)actionDidTapGuidePlayBtn:(id)sender {
    int soundID = 0;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"song_yijianmei" ofType:@"mp3"];
    if (self.BLGuideMusicPlayStatus == 0) {
        [[CStoreMediaEngineCore sharedSingleton] playEffect:soundID filePath:filePath loopCount:0 pitch:1.0 pan:0.0 gain:100 publish:TRUE progress:TRUE];
        self.BLGuideMusicPlayStatus = 1;
        self.guideFileLength = [[CStoreMediaEngineCore sharedSingleton] getEffectFileDuration:soundID];
    } else if (self.BLGuideMusicPlayStatus == 2){
        [[CStoreMediaEngineCore sharedSingleton] resumeEffect:soundID];
        self.BLGuideMusicPlayStatus = 1;
    }
}

- (IBAction)actionDidTapGuidePauseBtn:(id)sender {
    int soundID = 0;
    if (self.BLGuideMusicPlayStatus == 1) {
        [[CStoreMediaEngineCore sharedSingleton] pauseEffect:soundID];
        self.BLGuideMusicPlayStatus = 2;
    }
}

- (IBAction)actionDidTapGuideStopBtn:(id)sender {
    int soundID = 0;
    [[CStoreMediaEngineCore sharedSingleton] stopEffect:soundID];
    self.BLGuideMusicPlayStatus = 0;
    [self.guideVoiceSlider setValue:0];
}

- (IBAction)actionDidGuideSlidingValueChange:(UISlider *)sender {
    float progress =  self.guideFileLength * sender.value / 100.0;
    int soundId = 0;
    if (self.BLGuideMusicPlayStatus == 1)
        [[CStoreMediaEngineCore sharedSingleton] setCurrentEffectFilePlayPosition:soundId currentPositon:progress];
}

- (IBAction)actionDidTapAudioEffectPlayBtn:(id)sender {
    int soundID = 1;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"effect1" ofType:@"wav"];
    if (self.BLAudioEffectPlayStatus == 0) {
        [[CStoreMediaEngineCore sharedSingleton] playEffect:soundID filePath:filePath loopCount:0 pitch:1.0 pan:0.0 gain:100 publish:TRUE progress:TRUE];
        self.BLAudioEffectPlayStatus = 1;
        self.effectFileLength = [[CStoreMediaEngineCore sharedSingleton] getEffectFileDuration:soundID];
    } else if (self.BLAudioEffectPlayStatus == 2){
        [[CStoreMediaEngineCore sharedSingleton] resumeEffect:soundID];
        self.BLAudioEffectPlayStatus = 1;
    }
}

- (IBAction)actionDidTapAudioEffectPauseBtn:(id)sender {
    int soundID = 1;
    if (self.BLAudioEffectPlayStatus == 1) {
        [[CStoreMediaEngineCore sharedSingleton] pauseEffect:soundID];
        self.BLAudioEffectPlayStatus = 2;
    }
}

- (IBAction)actionDidTapAudioEffectStopBtn:(id)sender {
    int soundID = 1;
    [[CStoreMediaEngineCore sharedSingleton] stopEffect:soundID];
    self.BLAudioEffectPlayStatus = 0;
    [self.audioEffectSlider setValue:0];
}

- (IBAction)actionDidAudioEffectSlidingValueChange:(UISlider *)sender {
    float progress =  self.effectFileLength * sender.value / 100.0;
    int soundId = 1;
    if (self.BLAudioEffectPlayStatus == 1) {
        [[CStoreMediaEngineCore sharedSingleton] setCurrentEffectFilePlayPosition:soundId currentPositon:progress];
    }
}

- (void)localAudioEffectStateChange:(BigoAudioMixingStateCode)state soundId:(NSInteger)soundId reason:(NSUInteger)reason {
    if(state == BigoAudioMixingStatePlaying){
        if(soundId == 0) {
            self.BLGuideMusicPlayStatus = 1;
        }else if(soundId == 1) {
            self.BLAudioEffectPlayStatus = 1;
        }
    }else if(state == BigoAudioMixingStatePaused) {
        if(soundId == 0) {
           self.BLGuideMusicPlayStatus = 2;
        }else if(soundId == 1) {
           self.BLAudioEffectPlayStatus = 2;
        }
    }else if(state == BigoAudioMixingStateStopped) {
        if(soundId == 0) {
           self.BLGuideMusicPlayStatus = 0;
            MainThreadBegin
            [self.guideVoiceSlider setValue:0];
            MainThreadCommit
        }else if(soundId == 1) {
           self.BLAudioEffectPlayStatus = 0;
            MainThreadBegin
            [self.audioEffectSlider setValue:0];
            MainThreadCommit
        }
    }else if(state == BigoAudioMixingStateProgress) {
        if(soundId == 0) {
            float pos = 100.0 * reason /self.guideFileLength;
            MainThreadBegin
            [self.guideVoiceSlider setValue:pos];
            MainThreadCommit
        }else if(soundId == 1) {
            float pos = 100.0 * reason /self.effectFileLength;
            MainThreadBegin
            [self.audioEffectSlider setValue:pos];
            MainThreadCommit
        }
    }else if(state == BigoAudioMixingStateFailed){
        if(soundId == 0) {
           self.BLGuideMusicPlayStatus = 0;
            MainThreadBegin
            [self.guideVoiceSlider setValue:0];
            MainThreadCommit
        }else if(soundId == 1) {
            self.BLAudioEffectPlayStatus = 0;
            MainThreadBegin
            [self.audioEffectSlider setValue:0];
            MainThreadCommit
        }
    }
}

- (void)localAudioMixingStateDidChanged:(BigoAudioMixingStateCode)state  reason:(NSUInteger)reason {
    if(state == BigoAudioMixingStatePlaying){
        self.BLRoomMusicPlayStatus = 1;
    }else if(state == BigoAudioMixingStatePaused) {
        self.BLRoomMusicPlayStatus = 2;
    }else if(state == BigoAudioMixingStateStopped) {
        self.BLRoomMusicPlayStatus = 0;
        MainThreadBegin
        [self.audioMixingSlider setValue:0];
        MainThreadCommit
    }else if(state == BigoAudioMixingStateProgress) {
        float pos = 100.0 * reason /self.musicFileLength;
        MainThreadBegin
        [self.audioMixingSlider setValue:pos];
        MainThreadCommit
    }else if(state == BigoAudioMixingStateFailed){
        self.BLRoomMusicPlayStatus = 0;
        MainThreadBegin
        [self.audioMixingSlider setValue:0];
        MainThreadCommit
    }
}

- (void)reportAudioVolumeIndicationOfSpeakers:(NSArray*)uid volume:(NSArray*)volume vad:(NSArray*)vad channelId:(NSArray<NSString *>*)channelId totalVolume:(NSUInteger)totalVolume{

}

- (void)activeSpeaker:(int64_t)uid{

}


@end
