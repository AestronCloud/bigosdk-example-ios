//
//  CSDataStore.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/27.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const AppId;
FOUNDATION_EXPORT NSString * const Cer;

typedef NS_ENUM(NSUInteger, CSApp) {
    CSAppUnkown,
    CSAppVideoLive,
    CSAppAudioLive,
    CSAppVideoCall1V1,
    CSAppAudioCall1V1,
    CSAppVideoLiveBasicBeauty,
    CSAppVideoCall1V1BasicBeauty,
};

@interface CSDataStore : NSObject

@property(nonatomic, strong)NSString *lastUserName;
@property(nonatomic, strong)NSString *lastChannelName;

+ (instancetype)sharedInstance;

- (CSApp)app;
- (NSString *)welcomeText;
- (NSString *)powerByText;

@end

NS_ASSUME_NONNULL_END
