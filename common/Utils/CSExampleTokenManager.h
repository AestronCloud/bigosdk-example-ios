//
//  CSExampleTokenManager.h
//  CStoreEngineKit
//
//  Created by Caimu Yang on 2019/8/26.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 获取临时token（仅用于demo调用，正式环境中，需要在接入方后台服务器部署Token 生成器生成 Token）
 */
@interface CSExampleTokenManager : NSObject

/**
 获取临时token（仅用于demo调用，正式环境中，需要在接入方后台服务器部署Token 生成器生成 Token）
 
 服务器生成临时token需要uid、channelName，当传入0时，会使用userAccount参数先注册一个账户，拿到uid后再获取token
 
 @param uid 用户uid
 @param channelName 频道名
 @param userAccount 用户账号，uid非0时该参数无效
 @param completion 获取临时token回调
 */
- (void)getTokenWithUid:(int64_t)uid
            channelName:(NSString *)channelName
            userAccount:(NSString *)userAccount
             completion:(void (^)(BOOL success, NSString *token))completion;

@end

NS_ASSUME_NONNULL_END
