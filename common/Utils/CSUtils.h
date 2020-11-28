//
//  CSUtils.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

/**
 主线程执行辅助宏
 */
#define MainThreadBegin [CSUtils invokeOnMainThread:^{
#define MainThreadCommit }];

/**
 一个像素
 */
#define OnePixel (1.0f / [[UIScreen mainScreen] scale])

/**
 屏幕宽
 */
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

/**
屏幕高
*/
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

//Color(30,30,30,1)
#define ColorWithAlpha(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define Color(r, g, b) ColorWithAlpha(r, g, b, 1)

@interface CSUtils : NSObject

/**
 主线程执行block
 */
+ (void)invokeOnMainThread:(void(^)(void))action;

/**
 移除字符串两端空白字符
 */
+ (NSString *)trimedString:(NSString *)str;

/**
 demo app的版本号，示例：0.0.1(12)
*/
+ (NSString *)demoVersion;

+ (NSString *)libraryPath;
+ (NSString *)docPath;
+ (BOOL)unzip:(NSString *)zipPath to:(NSString *)destDir;

+ (UIEdgeInsets)safeEreaInsetsOfView:(UIView *)view;

+ (void)showAlertWithTitle:(NSString * _Nullable)title
                       msg:(NSString * _Nullable)msg
            fromController:(UIViewController *)fromVC
                sureAction:(void(^)(void))sureAction;

+ (void)showAlertWithTitle:(NSString * _Nullable)title
                       msg:(NSString * _Nullable)msg
            fromController:(UIViewController *)fromVC
                sureAction:(void(^)(void))sureAction
              cancelAction:(void(^)(void))cancelAction;

+ (void)addWhiteFlagOnPixelBuffer:(CVPixelBufferRef)ref;

@end

IB_DESIGNABLE
@interface CSButton : UIButton

@end

NS_ASSUME_NONNULL_END
