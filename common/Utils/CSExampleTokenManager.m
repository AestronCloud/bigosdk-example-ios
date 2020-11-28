//
//  CSExampleTokenManager.m
//  CStoreEngineKit
//
//  Created by Caimu Yang on 2019/8/26.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#import "CSExampleTokenManager.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "AppDelegate.h"
#import "CSDataStore.h"

@interface CSExampleTokenManager ()

/**
 缓存userAccount对应的uid，key:userAccount，value：uid
 */
@property (nonatomic, strong) NSCache<NSString *, NSNumber *> *accountToUidCache;

@end

@implementation CSExampleTokenManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _accountToUidCache = [NSCache new];
    }
    return self;
}

- (void)getTokenWithUid:(int64_t)uid
            channelName:(NSString *)channelName
            userAccount:(NSString *)userAccount
             completion:(void (^)(BOOL success, NSString *token))completionBlock {
    //检查缓存，尝试找到userAccount对应的uid
    if (uid == 0) {
        uid = [[self.accountToUidCache objectForKey:userAccount] longLongValue];
    }
    
    //uid为0则先调用registerLocalUserAccount生成uid
    if (uid == 0) {
        __weak typeof(self) weakSelf = self;
        [[CStoreMediaEngineCore sharedSingleton] registerLocalUserAccount:userAccount completion:^(BOOL success, CSMErrorCode resCode, CSMUserInfo * _Nonnull userInfo) {
            typeof(self) strongSelf = weakSelf; if (!strongSelf) return;

            if (success) {
                NSNumber *uidObject = [NSNumber numberWithLongLong:userInfo.uid];
                [strongSelf.accountToUidCache setObject:uidObject forKey:userAccount];
                [strongSelf innerGetTokenWithUid:userInfo.uid channelName:channelName comletion:completionBlock];
            } else {
                if (completionBlock) {
                    completionBlock(NO, nil);
                }
            }
        }];
    } else {
        [self innerGetTokenWithUid:uid channelName:channelName comletion:completionBlock];
    }
}

/**
 调用sdk获取临时token的接口（仅用于demo调用，正式环境中，需要在接入方后台服务器部署Token 生成器生成 Token）
 */
- (void)innerGetTokenWithUid:(uint64_t)uid
                 channelName:(NSString *)channelName
                   comletion:(void (^)(BOOL success, NSString *token))completion {
    SEL selector = @selector(getTokenWithUid:channelName:cer:comletion:);
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[CStoreMediaEngineCore instanceMethodSignatureForSelector:selector]];
    invocation.target = [CStoreMediaEngineCore sharedSingleton];
    invocation.selector = selector;
    [invocation setArgument:&uid atIndex:2];
    [invocation setArgument:&channelName atIndex:3];
    NSString *cer = [CSDataStore sharedInstance].cer;
    [invocation setArgument:&cer atIndex:4];
    [invocation setArgument:&completion atIndex:5];
    [invocation invoke];
}

@end
