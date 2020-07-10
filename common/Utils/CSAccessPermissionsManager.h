//
//  CSAccessPermissionsManager.h
//
//  Created by Dushu Ou on 2019/1/4.
//  Copyright © 2019 Bigo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PermissionCheckCompletionHandler)(BOOL granted);

NS_ASSUME_NONNULL_BEGIN

/**
管理各类权限申请
 */
@interface CSAccessPermissionsManager : NSObject

/**
 请求摄像头权限
 */
+ (void)requestCameraPermissionCompletionHandler:(PermissionCheckCompletionHandler)completionHandler;

/**
 请求麦克风
 */
+ (void)requestMicrophonePermissionCompletionHandler:(PermissionCheckCompletionHandler)completionHandler;

/**
 是否有权限访问摄像头
 */
+ (BOOL)isCameraPermissionAccessible;

/**
 是否有权限访问麦克风
 */
+ (BOOL)isMicPermissionAccessible;

@end

NS_ASSUME_NONNULL_END
