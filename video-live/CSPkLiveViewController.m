//
//  CSPkLiveViewController.m
//  video-live
//
//  Created by 林小程 on 2020/9/14.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSPkLiveViewController.h"
#import "CSUtils.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSAccessPermissionsManager.h"
#import "CSInfoAlert.h"
#import "CSLiveDebugView.h"
#import "CSTranscodingInfoManager.h"
#import "CSCaptureDeviceCamera.h"
#import "CSTestArgSettingManager.h"
#import "CSDataStore.h"
#import <CStoreMediaEngineKit/CSMVideoCanvas.h>

@interface CSPkLiveViewController ()
<
CSLiveDebugViewDataSource,
CStoreMediaEngineCoreDelegate,
CSCaptureDeviceDataOutputPixelBufferDelegate
>

@property (weak, nonatomic) IBOutlet GLKView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *pkBtn;
@property (weak, nonatomic) IBOutlet UIButton *addRtmpUrlBtn;
@property (weak, nonatomic) IBOutlet UIButton *removeRtmpUrlBtn;

@property (nonatomic, strong) CStoreMediaEngineCore *mediaEngine;

@property (nonatomic, assign) BOOL isAudioMuted;
@property (nonatomic, assign) BOOL isVideoMuted;

@property (nonatomic, strong) NSMutableSet<NSString *> *rtmpUrls;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, CSMChannelMicUser *> *micUsers;

@property (nonatomic, strong) CSCaptureDeviceCamera *captureDevice;

@property(nonatomic, assign)BOOL customCapture;

@property(nonatomic, strong)CSMVideoCanvas *previewCanvas;
@property(nonatomic, strong)NSMutableDictionary<NSNumber *, CSMVideoCanvas *> *remoteCanvas;

@property(nonatomic, strong)CSMLocalVideoStats *localVideoStas;
@property(nonatomic, strong)CSMLocalAudioStats *localAudioStats;

@end

@implementation CSPkLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _remoteCanvas = [NSMutableDictionary dictionary];
    _rtmpUrls = [NSMutableSet set];
    
    //设置debug页面
    [self setupMSDebugView];
        
    //设置用户角色、渲染视图
    self.mediaEngine = [CStoreMediaEngineCore sharedSingleton];
    self.mediaEngine.delegate = self;
    if (self.customCapture) {
        [self.mediaEngine enableCustomVideoCapture:YES];
    }
    
    [self.mediaEngine enableMultiViewRender:TestArg.multiViewRenderMode];
    [self.mediaEngine setClientRole:CSMClientRoleBroadcaster];
    if (!TestArg.multiViewRenderMode) {
        [self.mediaEngine attachRendererView:self.videoView];
    }
    
    //主播需要请求摄像头和麦克风权限
    __weak typeof(self) weakSelf = self;
    [CSAccessPermissionsManager requestCameraPermissionCompletionHandler:^(BOOL granted) {
        MainThreadBegin
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        if (granted) {
            [strongSelf.mediaEngine startPreview];
            
            if (strongSelf.micUsers.count != 0) { //如果请求权限后，已经有人上下麦，则不再显示预览页面
                return;
            }
            
            if (TestArg.multiViewRenderMode) {
                CSMVideoCanvas *localCanvas = [[CSMVideoCanvas alloc] init];
                localCanvas.uid = 0; //预览时需要把uid设为0，开播后触发didClientRoleChanged回调再刷新
                localCanvas.view = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
                [(UIControl *)localCanvas.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toastIsInMultiViewRenderMode)]];
                [strongSelf.view addSubview:localCanvas.view];
                [strongSelf.view sendSubviewToBack:localCanvas.view];
                strongSelf.previewCanvas = localCanvas;
                [strongSelf.mediaEngine setupLocalVideo:localCanvas];
            } else {
                // 设置预览画面
                CSMVideoRenderer *videoRenderer = [[CSMVideoRenderer alloc] init];
                videoRenderer.renderFrame = CGRectMake(0, 0, strongSelf.view.frame.size.width, strongSelf.view.frame.size.height);
                videoRenderer.uid = strongSelf.myUid;
                videoRenderer.seatNum = 1;
                [strongSelf.mediaEngine setVideoRenderers:@[videoRenderer]];
            }
        }
        [CSAccessPermissionsManager requestMicrophonePermissionCompletionHandler:^(BOOL granted) {
            
        }];
        MainThreadCommit
    }];
    
    [self joinChannelWithCompletion:^(BOOL success) {
        if (TestArg.autoRtmpUrl.length > 0) {
            int result = [self.mediaEngine setLiveTranscoding:[[CSTranscodingInfoManager sharedInstance] transcodingInPk:YES withUids:@[ @(self.myUid) ]]];
            if (result == 0) {
                [CSInfoAlert showInfo:@"已启动合流"];
            } else if(result == -5) {
                [CSInfoAlert showInfo:@"视频布局参数无效"];
            }
        }
    }];
}

- (void)toastIsInMultiViewRenderMode {
    [CSInfoAlert showInfo:@"正处于多View绘制模式"];
}

//退房
- (void)leaveRoom {
    for (NSString *url in self.rtmpUrls) {
        [self.mediaEngine removePublishStreamUrl:url];
    }
    [self.mediaEngine leaveChannel];
    self.mediaEngine.delegate = nil;
    self.mediaEngine = nil;
}

- (void)setupMSDebugView {
    CSLiveDebugView *view = [[CSLiveDebugView alloc] initWithFrame:self.view.bounds vc:self];
    view.dataSource = (id<CSLiveDebugViewDataSource>)self;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:view];
}

#pragma mark - Action
- (IBAction)actionDidTapQuit:(UIButton *)sender {
    [self leaveRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDidTapSwitchCamera:(UIButton *)sender {
    if (self.customCapture) {
        [self.captureDevice switchCameraPosition];
    } else {
        [self.mediaEngine switchCamera];
    }
}

- (IBAction)actionDidTapMuteAudio:(UIButton *)sender {
    self.isAudioMuted = !self.isAudioMuted;
}

- (IBAction)actionDidTapMuteVideo:(UIButton *)sender {
    self.isVideoMuted = !self.isVideoMuted;
}

- (IBAction)actionDidTapPk:(id)sender {
    BOOL isPking = self.pkBtn.selected;
    if (!isPking) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入PK信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"要PK的频道名";
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        __weak typeof(alert) weakAlert = alert;
        __weak typeof(self) weakSelf = self;
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakAlert) alert = weakAlert;
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || !alert) { return; }

            NSString *pkChannel = alert.textFields.firstObject.text;
            [self.tokenManager getTokenWithUid:0 channelName:pkChannel userAccount:self.username completion:^(BOOL success, NSString * _Nonnull token) {
                MainThreadBegin
                if (success) {
                    __strong typeof(weakSelf) self = weakSelf;
                    if (!self) { return; }
                    
                    [self.mediaEngine joinPkChannelWithToken:token channelName:pkChannel myUid:self.myUid completion:^(BOOL success, CSMErrorCode resCode, NSString * _Nonnull channel, uint64_t uid, NSInteger useTime) {
                        MainThreadBegin
                        __strong typeof(weakSelf) self = weakSelf;
                        if (!self) { return; }
                        
                        if (success) {
                            [CSInfoAlert showInfo:@"加入PK成功"];
                            self.pkBtn.selected = YES;
                        } else {
                            [CSInfoAlert showInfo:[NSString stringWithFormat:@"加入PK失败:%d", resCode]];
                        }
                        MainThreadCommit
                    }];
                }
                MainThreadCommit
            }];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.mediaEngine leavePkChannel];
        self.pkBtn.selected = NO;
    }
}

- (IBAction)actionDidTapAddRtmpUrl:(UIButton *)sender {
    [self cse_setPublishStreamUrlWithAddOrRemove:YES];
}

- (IBAction)actionDidTapRemoveRtmUrl:(UIButton *)sender {
    [self cse_setPublishStreamUrlWithAddOrRemove:NO];
}

- (void)cse_setPublishStreamUrlWithAddOrRemove:(BOOL)addOrRemove {
    NSString *exitstUrl = [[self.rtmpUrls allObjects] componentsJoinedByString:@","];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:addOrRemove ? @"增加旁路推流url" : @"删除旁路推流url" message:[NSString stringWithFormat:@"当前已设置的url:%@", exitstUrl] preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"rtmp://";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    __weak typeof(alert) weakAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        NSString *url = weakAlert.textFields.firstObject.text;
        if (url.length == 0) {
            [CSInfoAlert showInfo:@"url不能为空"];
            return;
        }
        
        if (addOrRemove) {
            [self.mediaEngine addPublishStreamUrl:url];
        } else {
            [self.mediaEngine removePublishStreamUrl:url];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)actionDidTapStartTranscoding:(UIButton *)sender {
    NSMutableArray<NSNumber *> *uids = [NSMutableArray array];
    [[self csm_sortedMicUsers] enumerateObjectsUsingBlock:^(CSMChannelMicUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uids addObject:@(obj.uid)];
    }];
    
    NSUInteger supportOnMicCount = [[CSTranscodingInfoManager sharedInstance] transcodingUserCountInPk:YES];
    if (supportOnMicCount < uids.count) {
        NSString *msg = [NSString stringWithFormat:@"当前只支持%lu人合流，请先在合流设置页面Transcoding Users一行增加更多用户的布局参数", (unsigned long)supportOnMicCount];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"合流设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController pushViewController:[CSModiTranscodingFormController formControllerWithPkOrMic:YES] animated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        int result = [self.mediaEngine setLiveTranscoding:[[CSTranscodingInfoManager sharedInstance] transcodingInPk:YES withUids:uids]];
        if (result == 0) {
            [CSInfoAlert showInfo:@"已启动合流"];
        } else if(result == -5) {
            [CSInfoAlert showInfo:@"视频布局参数无效"];
        }
    }
}

- (IBAction)actionDidTapStopTranscoding:(UIButton *)sender {
    [self.mediaEngine stopLiveTranscoding];
    [CSInfoAlert showInfo:@"已停止合流"];
}

- (IBAction)actionDidTapTranscodingSetting:(UIButton *)sender {
    [self.navigationController pushViewController:[CSModiTranscodingFormController formControllerWithPkOrMic:YES] animated:YES];
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine localVideoStats:(CSMLocalVideoStats *)stats {
    MainThreadBegin
    self.localVideoStas = stats;
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine localAudioStats:(CSMLocalAudioStats *)stats {
    MainThreadBegin
    self.localAudioStats = stats;
    MainThreadCommit
}

#pragma mark - BLLiveDebugViewDataSource
- (NSString *)mssdkDebugInfoForLiveDebugView:(CSLiveDebugView *)liveDebugView {
    return [NSString stringWithFormat:@"%@\nlocalVideoStas:%@\nlocalAudioStats:%@", [self.mediaEngine mssdkDebugInfo], self.localVideoStas ?: @"", self.localAudioStats ?: @""];
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
    [self.remoteCanvas[@(user.uid)].view removeFromSuperview];
    self.remoteCanvas[@(user.uid)] = nil;
    [self updateRenderView];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didClientRoleChanged:(CSMClientRole)oldRole newRole:(CSMClientRole)newRole clientRoleInfo:(CSMChannelMicUser *)clientRoleInfo channelName:(NSString *)channelName {
    NSLog(@"didClientRoleChanged newRole:%d oldRole:%d channelName:%@ %@", newRole, oldRole, channelName, clientRoleInfo);
    if (newRole == CSMClientRoleBroadcaster) {
        self.micUsers[@(clientRoleInfo.uid)] = clientRoleInfo;
        
        //重新上麦后，会重新打开视频和音频，刷新一下UI
        self.isAudioMuted = NO;
        self.muteAudioBtn.selected = NO;
        self.isVideoMuted = NO;
        self.muteVideoBtn.selected = NO;
    } else if (newRole == CSMClientRoleAudience) {
        MainThreadBegin
        self.micUsers[@(self.myUid)] = nil;
        [self.previewCanvas.view removeFromSuperview];
        self.previewCanvas = nil;
        MainThreadCommit
    }
    [self updateRenderView];
}

- (CGRect)frameOfUserAtIndex:(NSUInteger)index totalMicUsersCount:(NSUInteger)total {
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    CGRect result = CGRectZero;
    CGFloat width = self.videoView.frame.size.width;
    CGFloat height = self.videoView.frame.size.height;
    if (total >= 2) {
        CGFloat videoH = width / 2 * (height / width);
        if (index == 0) {
            result = CGRectMake(0, 0, width / 2, videoH);
        } else if(index == 1) {
            result = CGRectMake(width / 2, 0, width / 2, videoH);
        }
    } else if (self.micUsers.count == 1) {
        result = CGRectMake(0, 0, width, height);
    }
    return result;
}

- (CSMVideoCanvas *)csm_createCanvasOfUid:(uint64_t)uid atIndex:(uint64_t)index totalCount:(NSUInteger)totalCount curCanvas:(CSMVideoCanvas *)curCanvas {
    CGRect frame = [self frameOfUserAtIndex:index totalMicUsersCount:totalCount];
    if (curCanvas) {
        curCanvas.uid = uid;
        curCanvas.view.frame = frame;
        return curCanvas;
    } else {
        UIControl *view = [[UIControl alloc] initWithFrame:frame];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toastIsInMultiViewRenderMode)]];
        CSMVideoCanvas *canvas = [[CSMVideoCanvas alloc] init];
        canvas.uid = uid;
        canvas.view = view;
        [self.view addSubview:view];
        [self.view sendSubviewToBack:view];
        return canvas;
    }
}

- (NSArray<CSMChannelMicUser *> *)csm_sortedMicUsers {
    //PK只支持两个人
    NSMutableArray<CSMChannelMicUser *> *mutableMicUsers = [[[self.micUsers.allValues subarrayWithRange:NSMakeRange(0, MIN(2, self.micUsers.count))] sortedArrayUsingComparator:^NSComparisonResult(CSMChannelMicUser * obj1, CSMChannelMicUser *obj2) {
        return [@(obj1.uid) compare:@(obj2.uid)];
    }] mutableCopy];
    
    //把自己的视频放在屏幕左边
    NSUInteger index = [mutableMicUsers indexOfObjectPassingTest:^BOOL(CSMChannelMicUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.uid == self.myUid;
    }];
    if (index != NSNotFound) {
        CSMChannelMicUser *myMicInfo = mutableMicUsers[index];
        [mutableMicUsers removeObjectAtIndex:index];
        [mutableMicUsers insertObject:myMicInfo atIndex:0];
    }
    return mutableMicUsers;
}

- (void)updateRenderView {
    MainThreadBegin
    NSArray<CSMChannelMicUser *> *users = [self csm_sortedMicUsers];
    NSUInteger count = users.count;
    if (TestArg.multiViewRenderMode) {
        [users enumerateObjectsUsingBlock:^(CSMChannelMicUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.uid == self.myUid) {
                self.previewCanvas = [self csm_createCanvasOfUid:obj.uid atIndex:idx totalCount:count curCanvas:self.previewCanvas];
                [self.mediaEngine setupLocalVideo:self.previewCanvas];
            } else {
                CSMVideoCanvas *canvas = self.remoteCanvas[@(obj.uid)];
                canvas = [self csm_createCanvasOfUid:obj.uid atIndex:idx totalCount:count curCanvas:canvas];
                [self.mediaEngine setupRemoteVideo:canvas];
                self.remoteCanvas[@(obj.uid)] = canvas;
            }
        }];
    } else {
        NSMutableArray<CSMVideoRenderer *> *renderers = [NSMutableArray array];
        [users enumerateObjectsUsingBlock:^(CSMChannelMicUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CSMVideoRenderer *renderer = [[CSMVideoRenderer alloc] init];
            renderer.renderFrame = [self frameOfUserAtIndex:idx totalMicUsersCount:count];
            renderer.uid = users[idx].uid;
            renderer.seatNum = obj.seatNum;
            [renderers addObject:renderer];
        }];
        [self.mediaEngine setVideoRenderers:renderers];
    }
    
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

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine rtmpStreamingChangedToState:(NSString *)url state:(CSMRtmpStreamingState)state errorCode:(CSMRtmpStreamingErrorCode)errorCode {
    MainThreadBegin
    switch (state) {
        case CSMRtmpStreamingStateIdle: {
            [CSInfoAlert showInfo:[NSString stringWithFormat:@"已删除旁路推流url:%@", url]];
            if (url.length > 0) {
                [self.rtmpUrls removeObject:url];
            }
            break;
        }
        case CSMRtmpStreamingStateConnecting: {
            [CSInfoAlert showInfo:[NSString stringWithFormat:@"正在连接旁路推流url:%@", url]];
            if (url.length > 0) {
                [self.rtmpUrls addObject:url];
            }
            break;
            break;
        }
        case CSMRtmpStreamingStateRunning: {
            [CSInfoAlert showInfo:[NSString stringWithFormat:@"正在推流到url:%@", url]];
            if (url.length > 0) {
                [self.rtmpUrls addObject:url];
            }
            break;
        }
        case CSMRtmpStreamingStateFailure: {
            if (url.length > 0) {
                [self.rtmpUrls removeObject:url];
            }
            switch (errorCode) {
                case CSMRtmpStreamingErrorCodeOK: {
                    break;
                }
                case CSMRtmpStreamingErrorCodeInvalidParameters: {
                    [CSInfoAlert showInfo:@"rtmp链接格式无效"];
                    break;
                }
                case CSMRtmpStreamingErrorCodeInternalServerError: {
                    [CSInfoAlert showInfo:@"旁路推流失败：服务器内部错误"];
                    break;
                }
                case CSMRtmpStreamingErrorCodeStreamNotExist: {
                    [CSInfoAlert showInfo:@"rtmp链接不存在"];
                    break;
                }
                case CSMRtmpStreamingErrorCodeConnectRtmpFail: {
                    [CSInfoAlert showInfo:@"rtmp连接失败"];
                    break;
                }   
                case CSMRtmpStreamingErrorCodeRtmpTimeout: {
                    [CSInfoAlert showInfo:@"rtmp收包超时"];
                    break;
                }
                case CSMRtmpStreamingErrorCodeOccupiedByOtherChannel: {
                    [CSInfoAlert showInfo:@"该rtmp链接已被其它频道使用"];
                    break;
                }
            }
            break;
        }
    }
    MainThreadCommit
}

- (void)onStartCustomCaptureVideoWithMediaEngine:(CStoreMediaEngineCore *)mediaEngine {
    if (self.customCapture) {
        [self.captureDevice startCapture];
    }
}

- (void)onStopCustomCaptureVideoWithMediaEngine:(CStoreMediaEngineCore *)mediaEngine {
    if (self.customCapture) {
        [self.captureDevice stopCapture];
    }
}

- (void)mediaEngineTranscodingUpdated:(CStoreMediaEngineCore *_Nonnull)mediaEngine {
    MainThreadBegin
    [CSInfoAlert showInfo:@"合流参数已更新" vertical:0.8];
    if (TestArg.autoRtmpUrl.length > 0) {
        [self.mediaEngine addPublishStreamUrl:TestArg.autoRtmpUrl];
    }
    MainThreadCommit
}

#pragma mark - CSCaptureDeviceDataOutputPixelBufferDelegate
- (void)captureDevice:(CSCaptureDeviceCamera *)device didCapturedData:(CMSampleBufferRef)data {
    CVPixelBufferRef ref = CMSampleBufferGetImageBuffer(data);
    
    [self.mediaEngine sendCustomVideoCapturePixelBuffer:ref];
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine shouldChangeCustomCaptureResolutionToWidth:(int)width height:(int)height {
    [self.captureDevice changeCaptureResolutionToWidth:width height:height];
}


- (CSCaptureDeviceCamera *)captureDevice {
    if (!_captureDevice) {
        _captureDevice = [[CSCaptureDeviceCamera alloc] initWithPixelFormatType:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];

        _captureDevice.delegate = self;
    }
    return _captureDevice;
}

- (BOOL)customCapture {
    return TestArg.customVideoCapture;
}


#pragma mark - Getter & Setter
- (void)setIsAudioMuted:(BOOL)isAudioMuted {
    _isAudioMuted = isAudioMuted;
    [self.mediaEngine muteLocalAudioStream:_isAudioMuted];
    self.muteAudioBtn.selected = _isAudioMuted;
}

- (void)setIsVideoMuted:(BOOL)isVideoMuted {
    _isVideoMuted = isVideoMuted;
    [self.mediaEngine muteLocalVideoStream:_isVideoMuted];
    self.muteVideoBtn.selected = _isVideoMuted;
}

- (NSMutableDictionary *)micUsers {
    if (!_micUsers) {
        _micUsers = [NSMutableDictionary dictionary];
    }
    return _micUsers;
}

@end
