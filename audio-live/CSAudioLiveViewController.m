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

@interface CSAudioLiveViewController ()
<
CStoreMediaEngineCoreDelegate,
CSLiveDebugViewDataSource
>

@property (strong, nonatomic) IBOutletCollection(CSAudioLiveSeatCell) NSArray *guestSeatCells;
@property (weak, nonatomic) IBOutlet UIButton *onMicBtn;

@property (nonatomic, strong) CStoreMediaEngineCore *mediaEngine;

@end

@implementation CSAudioLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMSDebugView];
    
    self.onMicBtn.selected = self.clientRole == CSMClientRoleAudience;

    self.mediaEngine = [CStoreMediaEngineCore sharedSingleton];
    self.mediaEngine.delegate = self;
    [self.mediaEngine setClientRole:self.clientRole];

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
    return [self.mediaEngine mssdkDebugInfo];
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
    for (CSAudioLiveSeatCell *cell in self.guestSeatCells) {
        uint64_t cellUid = cell.onMicUid;
        BOOL speaking = cellUid != 0 && [uids containsObject:@(cellUid)];
        [cell setUid:cellUid speaking:speaking];
    }
    MainThreadCommit
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

#pragma mark - Private
- (void)cs_refreshSeatCellWithAddUid:(uint64_t)addUid delUid:(uint64_t)delUid {
    if (addUid != 0) {
        __block NSInteger firstEmptyMic = NSNotFound;
        NSInteger indexOfNewUser = [self.guestSeatCells indexOfObjectPassingTest:^BOOL(CSAudioLiveSeatCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.onMicUid == 0 && firstEmptyMic == NSNotFound) {
                firstEmptyMic = idx;
            }
            
            return obj.onMicUid != 0 && obj.onMicUid == addUid;
        }];
        
        if (indexOfNewUser == NSNotFound && firstEmptyMic != NSNotFound) {
            [((CSAudioLiveSeatCell *)self.guestSeatCells[firstEmptyMic]) setOnMicUid:addUid myUid:self.myUid];
        }
    }
    
    if (delUid != 0) {
        for (CSAudioLiveSeatCell *cell in self.guestSeatCells) {
            if (cell.onMicUid != 0 && cell.onMicUid == delUid) {
                [cell setOnMicUid:0 myUid:self.myUid];
            }
        }
    }
}

@end
