//
//  CSAccessPermissionsManager.m
//
//  Created by Dushu Ou on 2019/1/4.
//  Copyright © 2019 Bigo Inc. All rights reserved.
//

#import "CSAccessPermissionsManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "CSUtils.h"

@implementation CSAccessPermissionsManager

+ (void)requestCameraPermissionCompletionHandler:(PermissionCheckCompletionHandler)completionHandler {
    [self requestPermissionWithType:AVMediaTypeVideo completionHandler:completionHandler];
}

+ (void)requestMicrophonePermissionCompletionHandler:(PermissionCheckCompletionHandler)completionHandler {
    [self requestPermissionWithType:AVMediaTypeAudio completionHandler:completionHandler];
}

+ (void)requestPermissionWithType:(AVMediaType)type completionHandler:(PermissionCheckCompletionHandler)completionHandler {
    MainThreadBegin
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:type];
    if (authStatus == AVAuthorizationStatusNotDetermined) { //用户未明确是否授予权限，则发起权限请求
        [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
            MainThreadBegin
            if (completionHandler) {
                completionHandler(granted);
            }
            MainThreadCommit
        }];
    } else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) { //用户曾经拒绝权限，或无法访问设备时，弹窗引导对权限进行说明，并引导跳转到系统设置页面
        if (type == AVMediaTypeAudio) {
            [self showAccessMicrophoneAlert];
        } else if (type == AVMediaTypeVideo) {
            [self showAccessCameraAlert];
        }
        if (completionHandler) {
            completionHandler(NO);
        }
    } else {
        if (completionHandler) {
            completionHandler(YES);
        }
    }
    MainThreadCommit
}

+ (void)showAccessCameraAlert {
    NSString *title = @"Camera Permission Required";
    NSString *message = @"Please go to 'Settings' > Find our app to enable Camera permission";
    [self showAccessAlertWithTitle:title message:message];
}

+ (void)showAccessMicrophoneAlert {
    NSString *title = @"Microphone Permission Required";
    NSString *message = @"Please go to 'Settings' > Find our app to enable Microphone permission";
    [self showAccessAlertWithTitle:title message:message];
}

+ (void)showAccessPhotoLibraryAlert {
    NSString *title = @"Photos Permission Required";
    NSString *message = @"Please go to 'Settings' > Find our app to enable Photos Permission";
    [self showAccessAlertWithTitle:title message:message];
}

+ (void)showAccessAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *openAccessAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL*url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }];
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:continueAction];
    [alert addAction:openAccessAction];
    [[self bl_findTopMostViewController] presentViewController:alert animated:YES completion:nil];}

+ (BOOL)isCameraPermissionAccessible {
    AVAuthorizationStatus cameraAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return cameraAuthStatus == AVAuthorizationStatusAuthorized;
}

+ (BOOL)isMicPermissionAccessible {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return authStatus == AVAuthorizationStatusAuthorized;
}

/**
 找显示在最前面的控制器
 */
+ (UIViewController *)bl_findTopMostViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self bl_findTopMostViewControllerOfRootViewController:rootViewController];
}

+ (UIViewController *)bl_findTopMostViewControllerOfRootViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController) {
        return [self bl_findTopMostViewControllerOfRootViewController:rootViewController.presentedViewController];
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        return [self bl_findTopMostViewControllerOfRootViewController:[(UITabBarController *)rootViewController selectedViewController]];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        return [self bl_findTopMostViewControllerOfRootViewController:[(UINavigationController *)rootViewController visibleViewController]];
    } else {
        return rootViewController;
    }
}

@end
