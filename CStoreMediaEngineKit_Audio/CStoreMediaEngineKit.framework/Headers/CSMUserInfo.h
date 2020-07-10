//
//  CSMUserInfo.h
//  CStoreMediaEngineKit
//
//  Created by Caimu Yang on 2019/9/3.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 表示一个用户
 */
@interface CSMUserInfo : NSObject <NSCopying>

///用户uid
@property (nonatomic, assign, readonly) uint64_t uid;
///用户账号
@property (nonatomic, copy, readonly) NSString *userAccount;

/**
 初始化CSMUserInfo
 
 @param uid 用户uid
 @param userAccount 用户账号
 */
- (instancetype)initWithUid:(uint64_t)uid userAccount:(NSString *)userAccount;

@end

NS_ASSUME_NONNULL_END
