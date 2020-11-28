//
//  CSBaseLiveViewController.h
//  video-live
//
//  Created by 林小程 on 2020/7/31.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSExampleTokenManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSBaseLiveViewController : UIViewController

//打开页面前设置以下三个进房基本属性
@property (nonatomic, assign) CSMClientRole clientRole;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, assign, readonly) uint64_t myUid;

@property (nonatomic, strong) CSExampleTokenManager *tokenManager;

- (void)joinChannelWithCompletion:(void(^ _Nullable)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
