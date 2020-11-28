//
//  CSAudioLiveViewController.m
//  audio-live
//
//  Created by 林小程 on 2020/7/23.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSAudioLiveViewController.h"
#import "CSInfoAlert.h"
#import "CSAccessPermissionsManager.h"
#import "CSUtils.h"
#import "CSAudioLiveSeatCell.h"
#import "CSLiveDebugView.h"
#import "CSMusicViewController.h"

#define MicSeatNumbers 16
#define CellSpace 8
@interface CSAudioLiveViewController ()
<
CStoreMediaEngineCoreDelegate,
CSLiveDebugViewDataSource,
CSMusicViewControllerDelegate,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
CSAudioLiveSeatCellDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *onMicBtn;
@property (weak, nonatomic) IBOutlet UIButton *setIsCallModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *earBackBtn;

@property (nonatomic, strong) CStoreMediaEngineCore *mediaEngine;

@property (nonatomic, assign) BOOL isUseCallMode;
@property (nonatomic, assign) BOOL isEarBacking;

@property (nonatomic, strong)CSMusicViewController *musicViewController;

@property(nonatomic, strong)NSMutableArray<NSNumber *> *micSeats;
@property(nonatomic, strong)NSArray<NSNumber *>*speakingUids;
@property(nonatomic, strong)NSMutableArray<NSNumber *> *mutedUids;

@end

@implementation CSAudioLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.micSeats = [NSMutableArray array];
    for (int i = 0; i < MicSeatNumbers; i++) {
        [self.micSeats addObject:@(0)];
    }
    self.mutedUids = [NSMutableArray array];
    
    [self setupMSDebugView];
    
    self.onMicBtn.selected = self.clientRole == CSMClientRoleAudience;

    self.mediaEngine = [CStoreMediaEngineCore sharedSingleton];
    self.mediaEngine.delegate = self;
    [self.mediaEngine setClientRole:self.clientRole];

    [self.mediaEngine setAudioProfile:BigoAudioProfileSettable scenario:BigoAudioScenarioChatRoomEntertainment];
    [CSAccessPermissionsManager requestMicrophonePermissionCompletionHandler:^(BOOL granted) {
    }];
    
    [self joinChannelWithCompletion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)setupMSDebugView {
    CSLiveDebugView *view = [[CSLiveDebugView alloc] initWithFrame:self.view.bounds vc:self];
    view.dataSource = self;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:view];
}

#pragma mark - CSLiveDebugViewDataSource
- (NSString *)mssdkDebugInfoForLiveDebugView:(CSLiveDebugView *)liveDebugView {
    return [NSString stringWithFormat:@"%@\n%@", [self.mediaEngine mssdkDebugInfo], self.micSeats];
}

#pragma mark - CStoreMediaEngineCoreDelegate
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userJoined:(CSMChannelMicUser *)user elapsed:(NSInteger)elapsed {
    MainThreadBegin
    [self cs_refreshSeatCellWithAddUid:user.uid delUid:0];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userOffline:(CSMChannelMicUser *)user reason:(int)reason {
    MainThreadBegin
    [self cs_refreshSeatCellWithAddUid:0 delUid:user.uid];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didClientRoleChanged:(CSMClientRole)oldRole newRole:(CSMClientRole)newRole clientRoleInfo:(CSMChannelMicUser *)clientRoleInfo channelName:(NSString *)channelName {
    NSLog(@"didClientRoleChanged newRole:%d oldRole:%d channelName:%@ %@", newRole, oldRole, channelName, clientRoleInfo);
    
    MainThreadBegin
    if (newRole == CSMClientRoleBroadcaster) {
        [self cs_refreshSeatCellWithAddUid:clientRoleInfo.uid delUid:0];
    } else if (newRole == CSMClientRoleAudience) {
        [self cs_refreshSeatCellWithAddUid:0 delUid:self.myUid];
    }
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine speakerChanged:(NSArray<NSNumber *> *)uids {
    MainThreadBegin
    NSLog(@"speakingchange:%@", [uids componentsJoinedByString:@","]);
    self.speakingUids = uids;
    [self.collectionView reloadData];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine localAudioEffectStateChange:(BigoAudioMixingStateCode)state soundId:(NSInteger)soundId reason:(NSUInteger)reason {
    [self.musicViewController localAudioEffectStateChange:state soundId:soundId reason:reason];
}
    
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine localAudioMixingStateDidChanged:(BigoAudioMixingStateCode)state  reason:(NSUInteger)reason {
    [self.musicViewController localAudioMixingStateDidChanged:state reason:reason];
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine reportAudioVolumeIndicationOfSpeakers:(NSArray*)uid volume:(NSArray*)volume vad:(NSArray*)vad channelId:(NSArray<NSString *>*)channelId totalVolume:(NSUInteger)totalVolume{
    [self.musicViewController reportAudioVolumeIndicationOfSpeakers:uid volume:volume vad:vad channelId:channelId totalVolume:totalVolume];
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine activeSpeaker:(int64_t)uid{
    [self.musicViewController activeSpeaker:uid];
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine usingCallMode:(BOOL)usingCallMode {
    MainThreadBegin
    NSString *info;
    if (usingCallMode) {
        info = @"已切换为跟随系统通话音量";
    } else {
        info = @"已切换为跟随系统媒体音量";
    }
    [CSInfoAlert showInfo:info inView:self.view vertical:0.7];
    MainThreadCommit
}

- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didAudioMuted:(BOOL)muted byUid:(uint64_t)uid {
    MainThreadBegin
    if (muted) {
        [self.mutedUids addObject:@(uid)];
    } else {
        [self.mutedUids removeObject:@(uid)];
    }
    [self.collectionView reloadData];
    MainThreadCommit
}

#pragma mark - CSMusicViewControllerDelegate
- (void)didTapBgOfMusicViewController:(CSMusicViewController *)controller {
    [self.musicViewController.view removeFromSuperview];
}

#pragma mark - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MicSeatNumbers;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor((ScreenWidth - CellSpace * 5) / 4);
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return CellSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return CellSpace;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, CellSpace, 0, CellSpace);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSAudioLiveSeatCell *cell = (CSAudioLiveSeatCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CSAudioLiveSeatCell class]) forIndexPath:indexPath];
    uint64_t uid = self.micSeats[indexPath.item].unsignedLongLongValue;
    BOOL speaking = uid != 0 && [self.speakingUids containsObject:@(uid)];
    BOOL muted = uid != 0 && [self.mutedUids containsObject:@(uid)];
    [cell setOnMicUid:uid myUid:self.myUid speaking:speaking mute:muted];
    cell.delegate = self;
    return cell;
}

#pragma mark - Action
- (IBAction)actionDidTapChangeRole:(id)sender {
    if (self.clientRole == CSMClientRoleBroadcaster) {
        self.clientRole = CSMClientRoleAudience;
    } else if (self.clientRole == CSMClientRoleAudience) {
        self.clientRole = CSMClientRoleBroadcaster;
    }
    
    self.onMicBtn.selected = self.clientRole == CSMClientRoleAudience;
    
    [self.mediaEngine setClientRole:self.clientRole];
}

- (IBAction)actionDidTapEndLive:(id)sender {
    [self.mediaEngine leaveChannel];
    self.mediaEngine.delegate = nil;
    self.mediaEngine = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDidTapVolumeMode:(UIButton *)sender {
    self.isUseCallMode = !self.isUseCallMode;
}

- (IBAction)actionDidTapEarBack:(UIButton *)sender {
    self.isEarBacking = !self.isEarBacking;
    [self.mediaEngine enableInEarMonitoring:self.isEarBacking];
    self.earBackBtn.selected = self.isEarBacking;
}

- (IBAction)actionDidTapMusic:(UIButton *)sender {
    if (!self.musicViewController) {
        self.musicViewController = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([CSMusicViewController class])];
        self.musicViewController.delegate = self;
    }
    
    if ([self.musicViewController.view superview]) {
        [self.musicViewController.view removeFromSuperview];
    } else {
        [self.view addSubview:self.musicViewController.view];
    }
}

#pragma mark - CSAudioLiveSeatCellDelegate
- (void)actionDidTapMuteOfAudioLiveSeatCell:(CSAudioLiveSeatCell *)cell {
    MainThreadBegin
    if (cell.onMicUid > 0) {
        BOOL toMute;
        if ([self.mutedUids containsObject:@(cell.onMicUid)]) {
            toMute = NO;
            [self.mutedUids removeObject:@(cell.onMicUid)];
        } else {
            toMute = YES;
            [self.mutedUids addObject:@(cell.onMicUid)];
        }
        if (self.myUid == cell.onMicUid) {
            [[CStoreMediaEngineCore sharedSingleton] muteLocalAudioStream:toMute];
        } else {
            [[CStoreMediaEngineCore sharedSingleton] muteRemoteAudioStream:cell.onMicUid mute:toMute];
        }
    }
    [self.collectionView reloadData];
    MainThreadCommit
}

#pragma mark - Getter && Setter
- (void)setIsUseCallMode:(BOOL)isUseCallMode {
    _isUseCallMode = isUseCallMode;
    [_mediaEngine setIsUseCallMode:isUseCallMode];
    self.setIsCallModeBtn.selected  = isUseCallMode;
}

#pragma mark - Private
- (void)cs_refreshSeatCellWithAddUid:(uint64_t)addUid delUid:(uint64_t)delUid {
    MainThreadBegin
    if (addUid != 0) {
        __block NSInteger firstEmptyMic = NSNotFound; //第一个空麦位
        //找到addUid是否已经在麦上
        NSInteger indexOfNewUser = [self.micSeats indexOfObjectPassingTest:^BOOL(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            uint64_t existUid = obj.unsignedLongLongValue;
            if (existUid == 0 && firstEmptyMic == NSNotFound) {
                firstEmptyMic = idx;
            }
            
            return existUid != 0 && existUid == addUid;
        }];
        
        if (indexOfNewUser == NSNotFound && firstEmptyMic != NSNotFound) {
            self.micSeats[firstEmptyMic] = @(addUid);
        }
    }
    
    if (delUid != 0) {
        NSInteger indexOfExist = [self.micSeats indexOfObjectPassingTest:^BOOL(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            uint64_t existUid = obj.unsignedLongLongValue;
            return existUid != 0 && existUid == delUid;
        }];
        if (indexOfExist != NSNotFound) {
            self.micSeats[indexOfExist] = @(0);
        }
    }
    
    [self.collectionView reloadData];
    MainThreadCommit
}

@end
