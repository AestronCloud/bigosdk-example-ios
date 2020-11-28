//
//  CSVideoChatViewController.m
//  video-1v1
//
//  Created by 林小程 on 2020/7/22.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSVideoChatViewController.h"
#import "CSUtils.h"
#import "CSAccessPermissionsManager.h"
#import "CSInfoAlert.h"
#import "CSLiveDebugView.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSBeautyViewController.h"
#import "CSBeautyStickerViewController.h"
#import "CSBeautyManager.h"
#import "CSVideoChatMiniWindow.h"
#import "CSDataStore.h"

@interface CSVideoChatViewController ()
<
CSLiveDebugViewDataSource,
CStoreMediaEngineCoreDelegate,
CSVideoChatMiniWindowProtocol
>

@property (weak, nonatomic) IBOutlet GLKView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *endCallBtn;
@property (weak, nonatomic) IBOutlet CSVideoChatMiniWindow *miniVideoWindow;
@property (weak, nonatomic) IBOutlet UIButton *stickerBtn;
@property (strong, nonatomic) IBOutletCollection(UIStackView) NSArray *bottomFunEreas;
@property (weak, nonatomic) IBOutlet UIStackView *previewFunStackView;
@property (weak, nonatomic) IBOutlet CSButton *beginCallBtn;
@property (weak, nonatomic) IBOutlet UIButton *quitPreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *stickerPreviewStickerBtn;

@property (nonatomic, strong) CStoreMediaEngineCore *mediaEngine;

@property (nonatomic, assign) BOOL myselfPreferSmall;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *micUsers;

@property (nonatomic, assign) BOOL isAudioMuted;
@property (nonatomic, assign) BOOL isVideoMuted;

@property (nonatomic, strong) CSMVideoRenderer *bigVideoRender;
@property (nonatomic, strong) CSMVideoRenderer *miniVideoRender;

@end

@implementation CSVideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if AdvancedBeauty
    self.stickerBtn.hidden = NO;
    self.stickerPreviewStickerBtn.hidden = NO;
#else
    self.stickerBtn.hidden = YES;
    self.stickerPreviewStickerBtn.hidden = YES;
#endif
    
    self.miniVideoWindow.delegate = self;
    self.myselfPreferSmall = YES;
    
    //设置debug页面
    [self setupMSDebugView];
    
    //设置用户角色、渲染视图
    self.mediaEngine = [CStoreMediaEngineCore sharedSingleton];
    self.mediaEngine.delegate = self;
    [self.mediaEngine setChannelProfile:CSMChannelProfile1v1Call];
    [self.mediaEngine attachRendererView:self.videoView];
    if ([CSDataStore sharedInstance].maxResolutionType > 0 || [CSDataStore sharedInstance].maxFrameRate > 0) {
        [self.mediaEngine setAllVideoMaxEncodeParamsWithMaxResolution:[CSDataStore sharedInstance].maxResolutionType maxFrameRate:[CSDataStore sharedInstance].maxFrameRate];
    }
    
    //请求设备权限
    __weak typeof(self) weakSelf = self;
    [CSAccessPermissionsManager requestCameraPermissionCompletionHandler:^(BOOL granted) {
        MainThreadBegin
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        if (granted) {
            if (strongSelf.micUsers.count != 0) { //如果请求权限后，已经有人上下麦，则不再显示预览页面
                return;
            }
            
            // 设置预览画面
            [strongSelf.view setNeedsLayout];
            [strongSelf.view layoutIfNeeded];
            CSMVideoRenderer *videoRenderer = [[CSMVideoRenderer alloc] init];
            videoRenderer.renderFrame = CGRectMake(0, 0, strongSelf.videoView.frame.size.width, strongSelf.videoView.frame.size.height);
            videoRenderer.uid = 0; //预览时需要把uid设为0，开播后触发didClientRoleChanged回调再刷新
            videoRenderer.seatNum = 1;
            NSLog(@"videoRenderer.frame:%lu, %@", (unsigned long)videoRenderer.seatNum, [NSValue valueWithCGRect:videoRenderer.renderFrame]);
            [strongSelf.mediaEngine setVideoRenderers:@ [videoRenderer ]];
            
            //初始化美颜
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[CSBeautyManager sharedInstance] prepare];
            });
        }
        [CSAccessPermissionsManager requestMicrophonePermissionCompletionHandler:^(BOOL granted) {
            
        }];
        MainThreadCommit
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

//退房
- (void)leaveRoom {
    [[CSBeautyManager sharedInstance] unprepare];
    [self.mediaEngine leaveChannel];
    self.mediaEngine.delegate = nil;
    self.mediaEngine = nil;
}

#pragma mark - CStoreMediaEngineCoreDelegate
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine connectionChangedToState:(CSMConnectionStateType)state {
    MainThreadBegin
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"connection changed to state %d", state]];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine firstRemoteVideoFrameOfUid:(uint64_t)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    MainThreadBegin
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"first remote video frame of uid %llu size %@", uid, NSStringFromCGSize(size)]];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userJoined:(CSMChannelMicUser *)user elapsed:(NSInteger)elapsed {
    MainThreadBegin
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"user %llu join", user.uid]];
    
    [self cs_tryRefreshMicWithAddUid:user.uid delUid:0];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userOffline:(CSMChannelMicUser *)user reason:(int)reason {
    MainThreadBegin
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"user %llu offline", user.uid]];
    
    NSLog(@"UserOffline %@", user);
    [self cs_tryRefreshMicWithAddUid:0 delUid:user.uid];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didClientRoleChanged:(CSMClientRole)oldRole newRole:(CSMClientRole)newRole clientRoleInfo:(CSMChannelMicUser *)clientRoleInfo channelName:(NSString *)channelName {
    NSLog(@"didClientRoleChanged newRole:%d oldRole:%d channelName:%@ %@", newRole, oldRole, channelName, clientRoleInfo);
    
    if (newRole == CSMClientRoleBroadcaster) {
        [self cs_tryRefreshMicWithAddUid:clientRoleInfo.uid delUid:0];
    } else if (newRole == CSMClientRoleAudience) {
        [self cs_tryRefreshMicWithAddUid:0 delUid:clientRoleInfo.uid];
    }
}

- (void)updateRenderView {
    MainThreadBegin
    NSMutableArray<CSMVideoRenderer *> *renderers = [NSMutableArray array];
    int seatNum = 1;
    CGFloat videoW = CGRectGetWidth(self.videoView.frame);
    CGFloat videoH = CGRectGetHeight(self.videoView.frame);
    uint64_t bigVideoUid = self.micUsers.firstObject.longLongValue;
    if (bigVideoUid != 0) {
        CSMVideoRenderer *videoRenderer = [[CSMVideoRenderer alloc] init];
        videoRenderer.renderFrame = CGRectMake(0, 0, videoW, videoH);
        videoRenderer.uid = bigVideoUid;
        videoRenderer.seatNum = seatNum;
        seatNum++;
        NSLog(@"videoRenderer.frame:%lu, %@", (unsigned long)videoRenderer.seatNum, [NSValue valueWithCGRect:videoRenderer.renderFrame]);
        [renderers addObject:videoRenderer];
        self.bigVideoRender = videoRenderer;
    }
    uint64_t smallVideoUid = self.micUsers.count >= 2 ? self.micUsers[1].longLongValue : 0;
    if (smallVideoUid != 0) {
        CSMVideoRenderer *videoRenderer = [[CSMVideoRenderer alloc] init];
        CGFloat smallVideoW = videoW / 3;
        CGFloat smallVideoH = smallVideoW * (videoH / videoW);
        videoRenderer.renderFrame = CGRectMake(videoW - smallVideoW, 80, smallVideoW, smallVideoH);
        videoRenderer.uid = smallVideoUid;
        videoRenderer.seatNum = seatNum;
        NSLog(@"videoRenderer.frame:%lu, %@", (unsigned long)videoRenderer.seatNum, [NSValue valueWithCGRect:videoRenderer.renderFrame]);
        [renderers addObject:videoRenderer];
        self.miniVideoRender = videoRenderer;
        self.miniVideoWindow.hidden = NO;
        self.miniVideoWindow.frame = [self.view convertRect:videoRenderer.renderFrame fromView:self.videoView];
    } else {
        self.miniVideoRender = nil;
        self.miniVideoWindow.hidden = YES;
    }
    
    [self.mediaEngine setVideoRenderers:renderers];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine reportStatWithType:(CSMStatReportType)type statDict:(NSDictionary<NSString *, NSString *> *)statDict {
    NSLog(@"reportStatWithType:%d statDict:%@", type, statDict);
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine reportLbsUriResult:(int)uri cost:(int)cost success:(BOOL)success {
    NSLog(@"reportLbsUriResultWithUri:%d cost:%d success:%@", uri, cost, @(success));
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine kicked:(CSMKickReason)reason {
    MainThreadBegin
    [self leaveRoom];
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"you are kicked:%d", reason]];
    [self.navigationController popViewControllerAnimated:YES];
    MainThreadCommit
}

#pragma mark - CSVideoChatMiniWindowProtocol
- (void)miniWindow:(CSVideoChatMiniWindow *)miniWindow preferChangeFrameWithOffsetX:(CGFloat)offsetX OffsetY:(CGFloat)offsetY {
    //更新小窗视频渲染区域
    if (self.miniVideoRender) {
        CGRect preferFrame = CGRectOffset(self.miniVideoWindow.frame, offsetX, offsetY);
        if (CGRectGetMinX(preferFrame) < 0) { //调整不超出屏幕左侧
            preferFrame = CGRectOffset(preferFrame, 0 - CGRectGetMinX(preferFrame), 0);
        }
        if (CGRectGetMinY(preferFrame) < 0) { //调整不超出屏幕顶部
            preferFrame = CGRectOffset(preferFrame, 0, 0 - CGRectGetMinY(preferFrame));
        }
        if (CGRectGetMaxX(preferFrame) > CGRectGetMaxX(self.miniVideoWindow.superview.bounds)) {  //调整不超出屏幕右侧
            preferFrame = CGRectOffset(preferFrame, -(CGRectGetMaxX(preferFrame) - CGRectGetMaxX(self.miniVideoWindow.superview.bounds)) , 0);
        }
        if (CGRectGetMaxY(preferFrame) > CGRectGetMaxY(self.miniVideoWindow.superview.bounds)) {  //调整不超出屏幕底部
            preferFrame = CGRectOffset(preferFrame, 0, -(CGRectGetMaxY(preferFrame) - CGRectGetMaxY(self.miniVideoWindow.superview.bounds)));
        }
        self.miniVideoRender.renderFrame = preferFrame;
        self.miniVideoWindow.frame = preferFrame;

        if (self.bigVideoRender) {
            [self.mediaEngine setVideoRenderers:@[ self.bigVideoRender, self.miniVideoRender ]];
        } else {
            [self.mediaEngine setVideoRenderers:@[ self.miniVideoRender ]];
        }
    }
}

#pragma mark - CSLiveDebugViewDataSource
- (NSString *)mssdkDebugInfoForLiveDebugView:(CSLiveDebugView *)liveDebugView {
    return [self.mediaEngine mssdkDebugInfo];
}

#pragma mark - Action
- (IBAction)actionDidTapBeginCall:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    //防止快速点击进入1v1视频导致重复joinchannel
    if (!self.beginCallBtn.enabled) {
        return;
    }
    
    self.beginCallBtn.enabled = NO;
    [self joinChannelWithCompletion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        if (success) {
            strongSelf.previewFunStackView.hidden = YES;
            strongSelf.quitPreviewButton.hidden = YES;
            for (UIView *v in strongSelf.bottomFunEreas) {
                v.hidden = NO;
            }
        } else {
            //只在加入频道失败时重新打开按钮响应，加入频道成功的话，该按钮被隐藏，没必要再响应事件
            strongSelf.beginCallBtn.enabled = NO;
        }
    }];
}

- (IBAction)actionDidTapChangeMiniVideo:(id)sender {
    self.myselfPreferSmall = !self.myselfPreferSmall;
    
    if (self.micUsers.count >= 2) {
        BOOL needChange = self.myselfPreferSmall ? self.micUsers[1].longLongValue != self.myUid : self.micUsers[0].longLongValue != self.myUid;
        if (needChange) {
            uint64_t firstUid = self.micUsers[0].longLongValue;
            self.micUsers[0] = self.micUsers[1];
            self.micUsers[1] = @(firstUid);
            [self updateRenderView];
        }
    }
}

- (IBAction)actionDidTapBueaty:(UIButton *)sender {
    [self cs_hideBottomFunAreas:YES];
    __weak typeof(self) weakSelf = self;
    [CSBeautyViewController showInVC:self dismissBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf cs_hideBottomFunAreas:NO];
    }];
}

- (IBAction)actionDidTapSwitchCamera:(UIButton *)sender {
    [self.mediaEngine switchCamera];
}

- (IBAction)actionDidTapMuteAudio:(UIButton *)sender {
    self.isAudioMuted = !self.isAudioMuted;
    [self.mediaEngine muteLocalAudioStream:self.isAudioMuted];
    self.muteAudioBtn.selected = self.isAudioMuted;
}

- (IBAction)actionDidTapMuteVideo:(UIButton *)sender {
    self.isVideoMuted = !self.isVideoMuted;
    [self.mediaEngine muteLocalVideoStream:self.isVideoMuted];
    self.muteVideoBtn.selected = self.isVideoMuted;
}

- (IBAction)actionDidTapEndCall:(id)sender {
    [self leaveRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDidTapQuitPreview:(UIButton *)sender {
    [self leaveRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDidTapSticker:(id)sender {
    [self cs_hideBottomFunAreas:YES];
    __weak typeof(self) weakSelf = self;
    [CSBeautyStickerViewController showInVC:self dismissBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf cs_hideBottomFunAreas:NO];
    }];
}

#pragma mark - Getter
- (NSMutableArray<NSNumber *> *)micUsers {
    if (!_micUsers) {
        _micUsers = [NSMutableArray array];
    }
    return _micUsers;
}

#pragma mark - Private
- (void)cs_tryRefreshMicWithAddUid:(uint64_t)addUid delUid:(uint64_t)delUid {
    if (addUid != 0) {
        if (self.micUsers.count >= 2 || [self.micUsers containsObject:@(addUid)]) {
            return;
        }
        
        BOOL onMicBigVideo = ((addUid == self.myUid) ^ self.myselfPreferSmall);
        if (onMicBigVideo) {
            [self.micUsers insertObject:@(addUid) atIndex:0];
        } else {
            [self.micUsers addObject:@(addUid)];
        }
        
        [self updateRenderView];
    }
    
    if (delUid != 0) {
        [self.micUsers removeObject:@(delUid)];
        
        [self updateRenderView];
    }
}

- (void)cs_hideBottomFunAreas:(BOOL)hide {
    for (UIView *v in self.bottomFunEreas) {
        v.alpha = (hide ? 0 : 1);
    }
}

@end
