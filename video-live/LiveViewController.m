//
//  CSLiveViewController.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSLiveViewController.h"
#import "CSUtils.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSAccessPermissionsManager.h"
#import "CSExampleTokenManager.h"
#import "CSInfoAlert.h"
#import "CSLiveDebugView.h"

static NSString *const kUserIdKey = @"kUserIdKey";

@interface CSLiveViewController () <
CSLiveDebugViewDataSource,
CStoreMediaEngineCoreDelegate
>

@property (weak, nonatomic) IBOutlet GLKView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *beautyBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *lockRoomBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBlockList;
@property (weak, nonatomic) IBOutlet UIButton *removeBlockList;
@property (weak, nonatomic) IBOutlet UIButton *addWhiteList;
@property (weak, nonatomic) IBOutlet UIButton *removeWhiteList;


@property (nonatomic, strong) CStoreMediaEngineCore *mediaEngine;
@property (nonatomic, strong) CSExampleTokenManager *tokenManager;
@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, CSMChannelMicUser *> *micUsers;
@property (nonatomic, assign) uint64_t myUid;
@property (nonatomic, assign) BOOL isBeautyOpened;
@property (nonatomic, assign) BOOL isAudioMuted;
@property (nonatomic, assign) BOOL isVideoMuted;
@property (nonatomic, assign) BOOL isLocked;

@end

@implementation CSLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置debug页面
    [self setupMSDebugView];
    
    //设置用户角色、渲染视图
    self.mediaEngine = [CStoreMediaEngineCore sharedSingleton];
    self.mediaEngine.delegate = self;
    [self.mediaEngine setClientRole:self.clientRole];
    [self.mediaEngine attachRendererView:self.videoView];
    
    if (self.clientRole == CSMClientRoleBroadcaster) { //主播需要请求摄像头和麦克风权限
        [CSAccessPermissionsManager requestCameraPermissionCompletionHandler:^(BOOL granted) {
            MainThreadBegin
            if (granted) {
                [self.mediaEngine startPreview];
                
                // 设置预览画面
                CSMVideoRenderer *videoRenderer = [[CSMVideoRenderer alloc] init];
                videoRenderer.renderFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                videoRenderer.uid = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey] longLongValue];
                videoRenderer.seatNum = 1;
                [self.mediaEngine setVideoRenderers:@[videoRenderer]];
                
            }
            [CSAccessPermissionsManager requestMicrophonePermissionCompletionHandler:^(BOOL granted) {
                
            }];
            MainThreadCommit
        }];
    }
    
    //请求token，然后进入频道
    __weak typeof(self) weakSelf = self;
    self.tokenManager = [[CSExampleTokenManager alloc] init];
    [self.tokenManager getTokenWithUid:0 channelName:self.channelName userAccount:self.username completion:^(BOOL success, NSString * _Nonnull token) {
        MainThreadBegin
        typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
        strongSelf.token = token;
        if (success) {
            // with user account
            [strongSelf.mediaEngine joinChannelWithUserAccount:strongSelf.username token:token channelName:strongSelf.channelName completion:^(BOOL success, CSMErrorCode resCode, NSString * _Nonnull channel, uint64_t uid, NSInteger useTime) {
                MainThreadBegin
                NSLog(@"joinChannel, success:%d, rescode:%d", success, resCode);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) { return; }
                
                if (success) {
                    strongSelf.myUid = uid;
                    [[NSUserDefaults standardUserDefaults] setObject:@(uid) forKey:kUserIdKey];
                } else {
                    NSString *toast = [NSString stringWithFormat:@"enter room fail:%d", resCode];
                    switch (resCode) {
                        case CSMErrorNotInWhitelist:
                            toast = @"locked room";
                            break;
                        case CSMErrorInBlacklist:
                            toast = @"you are in block list";
                            break;
                        default:
                            break;
                    }
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [CSInfoAlert showInfo:toast];
                    });
                }
                MainThreadCommit
            }];
        }
        MainThreadCommit
    }];
    [self refreshToolView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupMSDebugView {
    CSLiveDebugView *view = [[CSLiveDebugView alloc] initWithFrame:self.view.bounds vc:self];
    view.dataSource = (id<CSLiveDebugViewDataSource>)self;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:view];
}

//退房
- (void)leaveRoom {
    [self.mediaEngine leaveChannel];
    self.mediaEngine.delegate = nil;
    self.mediaEngine = nil;
}

//更新功能按钮
- (void)refreshToolView {
    BOOL isBroadcaster = self.clientRole == CSMClientRoleBroadcaster;
    self.beautyBtn.hidden = !isBroadcaster;
    self.switchCameraBtn.hidden = !isBroadcaster;
    self.muteAudioBtn.hidden = !isBroadcaster;
    self.muteVideoBtn.hidden = !isBroadcaster;
    self.lockRoomBtn.hidden = !isBroadcaster;
    
    self.addWhiteList.hidden = self.removeWhiteList.hidden = !isBroadcaster || !self.isLocked;
    self.addBlockList.hidden = self.removeBlockList.hidden = !isBroadcaster || self.isLocked;
}

#pragma mark - Action
- (IBAction)actionDidTapQuit:(UIButton *)sender {
    [self leaveRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDidTapBueaty:(UIButton *)sender {
    self.isBeautyOpened = !self.isBeautyOpened;
    [self.mediaEngine enableBeautyMode:self.isBeautyOpened];
    self.beautyBtn.selected = self.isBeautyOpened;
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

- (IBAction)actionDidTapChangeRole:(UIButton *)sender {
    CSMClientRole clientRole = self.clientRole == CSMClientRoleBroadcaster ? CSMClientRoleAudience : CSMClientRoleBroadcaster;
    [self.mediaEngine setClientRole:clientRole];
    self.clientRole = clientRole;
    [self refreshToolView];
}

- (IBAction)actionDidTapLockRoom:(UIButton *)sender {
    self.lockRoomBtn.enabled = NO;
     __weak typeof(self) weakSelf = self;
    if (self.isLocked) {
        [self.mediaEngine switchToPublicRoom:nil blockTime:0 appendBlackUidList:nil completion:^(BOOL success, CSMErrorCode resCode) {
            MainThreadBegin
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            
            NSLog(@"switchToPublicRoom, success:%d, code:%d", success, resCode);
            if (success) {
                strongSelf.isLocked = NO;
                strongSelf.lockRoomBtn.enabled = YES;
                strongSelf.lockRoomBtn.selected = NO;
                [strongSelf refreshToolView];
            } else {
                [CSInfoAlert showInfo:[NSString stringWithFormat:@"unlock fail:%d", resCode]];
            }
            MainThreadCommit
        }];
    } else {
        [self.mediaEngine switchToPrivacyRoom:0 accessToken:self.token whiteUidList:@[ @(self.myUid) ] completion:^(BOOL success, CSMErrorCode resCode) {
            MainThreadBegin
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            
            NSLog(@"switchToPrivacyRoom, success:%d, code:%d", success, resCode);
            if (success) {
                strongSelf.isLocked = YES;
                strongSelf.lockRoomBtn.enabled = YES;
                strongSelf.lockRoomBtn.selected = YES;
                [strongSelf refreshToolView];
            } else {
                [CSInfoAlert showInfo:[NSString stringWithFormat:@"lock fail:%d", resCode]];
            }
            MainThreadCommit
        }];
    }
}

- (IBAction)actionDidTapAddBlockUid:(id)sender {
    [self cs_showPrivacyTextFieldAlertWithText:@"Add uid to block list:" sureAction:^(uint64_t uid) {
        [self.mediaEngine updateBlackUidList:0 accessToken:@"" appendList:@[ @(uid) ] removeList:nil completion:^(BOOL success, CSMErrorCode resCode) {
            MainThreadBegin
            NSLog(@"addBlockUid, success:%d, code:%d", success, resCode);
            if (success) {
                [CSInfoAlert showInfo:@"add block list success"];
            } else {
                [CSInfoAlert showInfo:[NSString stringWithFormat:@"add block list fail:%d", resCode]];
            }
            MainThreadCommit
        }];
    }];
}

- (IBAction)actionDidTapRemoveBlockUid:(id)sender {
    [self cs_showPrivacyTextFieldAlertWithText:@"Remove uid from block list:" sureAction:^(uint64_t uid) {
        [self.mediaEngine updateBlackUidList:0 accessToken:@"" appendList:nil removeList:@[ @(uid) ] completion:^(BOOL success, CSMErrorCode resCode) {
            MainThreadBegin
            NSLog(@"removeBlockUid, success:%d, code:%d", success, resCode);
            if (success) {
                [CSInfoAlert showInfo:@"remove block list success"];
            } else {
                [CSInfoAlert showInfo:[NSString stringWithFormat:@"remove block list fail:%d", resCode]];
            }
            MainThreadCommit
        }];
    }];
}
- (IBAction)actionDidTapAddWhiteUid:(id)sender {
    [self cs_showPrivacyTextFieldAlertWithText:@"Add uid to white list:" sureAction:^(uint64_t uid) {
        [self.mediaEngine updateWhiteUidList:0 accessToken:@"" appendList:@[ @(uid) ] removeList:nil completion:^(BOOL success, CSMErrorCode resCode) {
            MainThreadBegin
            NSLog(@"addWhiteUid, success:%d, code:%d", success, resCode);
            if (success) {
                [CSInfoAlert showInfo:@"add white list success"];
            } else {
                [CSInfoAlert showInfo:[NSString stringWithFormat:@"add white list fail:%d", resCode]];
            }
            MainThreadCommit
        }];
    }];
}

- (IBAction)actionDidTapRemoveWhiteUid:(id)sender {
    [self cs_showPrivacyTextFieldAlertWithText:@"Remove uid from white list:" sureAction:^(uint64_t uid) {
        [self.mediaEngine updateWhiteUidList:0 accessToken:@"" appendList:nil removeList:@[ @(uid) ] completion:^(BOOL success, CSMErrorCode resCode) {
            MainThreadBegin
            NSLog(@"removeWhiteUid, success:%d, code:%d", success, resCode);
            if (success) {
                [CSInfoAlert showInfo:@"remove white list success"];
            } else {
                [CSInfoAlert showInfo:[NSString stringWithFormat:@"remove white list fail:%d", resCode]];
            }
            MainThreadCommit
        }];
    }];
}

#pragma mark - Privacy Helper
- (void)cs_showPrivacyTextFieldAlertWithText:(NSString *)text sureAction:(void(^)(uint64_t uid))sureAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"uid";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *uidStr = [CSUtils trimedString:alert.textFields[0].text];
        if (sureAction && uidStr.length > 0) {
            NSScanner *scanner = [NSScanner scannerWithString:uidStr];
            uint64_t uid = 0;
            [scanner scanUnsignedLongLong:&uid];
            if (uid > 0) {
                sureAction(uid);
            }
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - BLLiveDebugViewDataSource
- (NSString *)mssdkDebugInfoForLiveDebugView:(CSLiveDebugView *)liveDebugView {
    return [self.mediaEngine mssdkDebugInfo];
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
    
    self.micUsers[@(user.uid)] = user;
    [self updateRenderView];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userOffline:(CSMChannelMicUser *)user reason:(int)reason {
    MainThreadBegin
    [CSInfoAlert showInfo:[NSString stringWithFormat:@"user %llu offline", user.uid]];
    
    NSLog(@"UserOffline %@", user);
    if ([self.micUsers.allKeys containsObject:@(user.uid)]) {
        self.micUsers[@(user.uid)] = nil;
    }
    [self updateRenderView];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didClientRoleChanged:(CSMClientRole)oldRole newRole:(CSMClientRole)newRole clientRoleInfo:(CSMChannelMicUser *)clientRoleInfo channelName:(NSString *)channelName {
    NSLog(@"didClientRoleChanged newRole:%d oldRole:%d channelName:%@ %@", newRole, oldRole, channelName, clientRoleInfo);
    if (newRole == CSMClientRoleBroadcaster) {
        self.micUsers[@(clientRoleInfo.uid)] = clientRoleInfo;
    } else if (newRole == CSMClientRoleAudience) {
        self.micUsers[@(self.myUid)] = nil;
    }
    [self updateRenderView];
}

- (void)updateRenderView {
    MainThreadBegin
    //更新麦上用户渲染区域，把GLKView切分为最多两列的分格视图
    int onMicUserCount = (int)self.micUsers.allKeys.count;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    int totalColumn = (onMicUserCount <= 2) ? 1 : 2;
    int totalRow = (onMicUserCount <= 2) ? onMicUserCount : (onMicUserCount+1) / 2;
    CGFloat micW = width / totalColumn;
    CGFloat micH = height / totalRow;
    
    NSMutableArray<CSMVideoRenderer *> *renderers = [NSMutableArray array];
    [self.micUsers.allValues enumerateObjectsUsingBlock:^(CSMChannelMicUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CSMVideoRenderer *videoRenderer = [[CSMVideoRenderer alloc] init];
        NSUInteger row = idx / totalColumn;
        NSUInteger col = idx % totalColumn;
        videoRenderer.renderFrame = CGRectMake(col * micW, row * micH, micW, micH);
        videoRenderer.uid = obj.uid;
        videoRenderer.seatNum = obj.seatNum;
        [renderers addObject:videoRenderer];
        NSLog(@"videoRenderer.frame:%lu, %@", (unsigned long)idx, [NSValue valueWithCGRect:videoRenderer.renderFrame]);
    }];
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

#pragma mark - Getter
- (NSMutableDictionary *)micUsers {
    if (!_micUsers) {
        _micUsers = [NSMutableDictionary dictionary];
    }
    return _micUsers;
}

@end
