//
//  CSAudioCallChatViewController.m
//  video-call-1v1
//
//  Created by 林小程 on 2020/7/23.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSAudioCallChatViewController.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSInfoAlert.h"
#import "CSAccessPermissionsManager.h"
#import "CSUtils.h"
#import "CSLiveDebugView.h"

@interface CSAudioCallChatViewController ()
<
CSLiveDebugViewDataSource,
CStoreMediaEngineCoreDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *muteAudioBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;

@property (nonatomic, strong) CStoreMediaEngineCore *mediaEngine;

@property (nonatomic, assign)BOOL isMute;
@property (nonatomic, assign)BOOL isSpeakerOn;

@end

@implementation CSAudioCallChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置debug页面
    [self setupMSDebugView];
    
    [CSAccessPermissionsManager requestMicrophonePermissionCompletionHandler:^(BOOL granted) {
    }];
    
    self.mediaEngine = [CStoreMediaEngineCore sharedSingleton];
    self.mediaEngine.delegate = self;
    [self.mediaEngine setChannelProfile:CSMChannelProfile1v1Call];
    [self.mediaEngine setIsTelephoneReceiverMode:YES];
   
    __weak typeof(self) weakSelf = self;
    [self joinChannelWithCompletion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        strongSelf.isSpeakerOn = YES;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)setupMSDebugView {
    CSLiveDebugView *view = [[CSLiveDebugView alloc] initWithFrame:self.view.bounds vc:self];
    view.dataSource = (id<CSLiveDebugViewDataSource>)self;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:view];
}

#pragma mark - CStoreMediaEngineCoreDelegate
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userJoined:(CSMChannelMicUser *)user elapsed:(NSInteger)elapsed {
    MainThreadBegin
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"user %llu join", user.uid]];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userOffline:(CSMChannelMicUser *)user reason:(int)reason {
    MainThreadBegin
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"user %llu offline", user.uid]];
    MainThreadCommit
}

#pragma mark - CSLiveDebugViewDataSource
- (NSString *)mssdkDebugInfoForLiveDebugView:(CSLiveDebugView *)liveDebugView {
    return [self.mediaEngine mssdkDebugInfo];
}

#pragma mark - Action
- (IBAction)actionDidTapMuteAudioBtn:(id)sender {
    self.isMute = !self.isMute;
}

- (IBAction)actionDidTapEndCallBtn:(id)sender {
    [self.mediaEngine leaveChannel];
    self.mediaEngine.delegate = nil;
    self.mediaEngine = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDidTapSpeakerBtn:(id)sender {
    self.isSpeakerOn = !self.isSpeakerOn;
}

#pragma mark - Setter
- (void)setIsMute:(BOOL)isMute {
    _isMute = isMute;
    self.muteAudioBtn.selected = _isMute;
    [self.mediaEngine muteLocalAudioStream:_isMute];
}

- (void)setIsSpeakerOn:(BOOL)isSpeakerOn {
    _isSpeakerOn = isSpeakerOn;
    self.speakerBtn.selected = !_isSpeakerOn;
    [self.mediaEngine setEnableSpeakerphone:_isSpeakerOn];
}

@end
