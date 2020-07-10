//
//  CSBaseLiveViewController.m
//  video-live
//
//  Created by 林小程 on 2020/7/31.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBaseLiveViewController.h"
#import "CSExampleTokenManager.h"
#import "CSInfoAlert.h"
#import "CSUtils.h"
#import "CSLiveBaseInfoView.h"

static NSString *const kUserIdKey = @"kUserIdKey";

@interface CSBaseLiveViewController ()

@property (nonatomic, strong) CSExampleTokenManager *tokenManager;

@end

@implementation CSBaseLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _myUid = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey] longLongValue];
}

- (void)joinChannelWithCompletion:(void (^ _Nullable)(BOOL))completion {
    //请求token，然后进入频道
    __weak typeof(self) weakSelf = self;
    self.tokenManager = [[CSExampleTokenManager alloc] init];
    [self.tokenManager getTokenWithUid:0 channelName:self.channelName userAccount:self.username completion:^(BOOL success, NSString * _Nonnull token) {
        MainThreadBegin
        typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
        strongSelf->_token = token;
        if (success) {
            // with user account
            [[CStoreMediaEngineCore sharedSingleton] joinChannelWithUserAccount:strongSelf.username token:token channelName:strongSelf.channelName completion:^(BOOL success, CSMErrorCode resCode, NSString * _Nonnull channel, uint64_t uid, NSInteger useTime) {
                MainThreadBegin
                NSLog(@"joinChannel, success:%d, rescode:%d", success, resCode);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) { return; }
                
                if (success) {
                    strongSelf->_myUid = uid;
                    [[NSUserDefaults standardUserDefaults] setObject:@(uid) forKey:kUserIdKey];
                } else {
                    NSString *toast = @"加入频道失败";
                    switch (resCode) {
                        case CSMErrorNotInWhitelist:
                        case CSMErrorInBlacklist:
                        case CSMErrorBlockedByHost:
                            toast = @"无权利加入频道，具体解决办法请咨询频道管理员";
                            break;
                        case CSMErrorRoomInvalid:
                            toast = @"未找到指定的频道";
                            break;
                        case CSMErrorChannelStateInvalid:
                            toast = @"指定的频道名无效";
                            break;
                        case CSMErrorAlreadyInChannel:
                            toast = @"重复加入频道";
                            break;
                        case CSMErrorTokenInvalid:
                            toast = @"Token无效";
                            break;
                        default:
                            break;
                    }
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [CSInfoAlert showInfo:toast];
                    });
                }
                
                if (completion) {
                    completion(success);
                }
                
                [strongSelf cs_addBaseInfoView];
                MainThreadCommit
            }];
        } else {
            [strongSelf.navigationController popViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [CSInfoAlert showInfo:@"获取Token失败"];
            });
            if (completion) {
                completion(success);
            }
        }
        MainThreadCommit
    }];
}

- (void)cs_addBaseInfoView {
    CSLiveBaseInfoView *baseInfoView = [[CSLiveBaseInfoView alloc] init];
    [self.view addSubview:baseInfoView];
    
    baseInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:baseInfoView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:baseInfoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:[UIApplication sharedApplication].statusBarFrame.size.height + 5].active = YES;

    [baseInfoView setMyUid:self.myUid channelName:self.channelName];
}

@end
