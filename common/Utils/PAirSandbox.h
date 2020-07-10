//
//  PAirSandbox.h
//  AirSandboxDemo
//
//  Created by gao feng on 2017/7/18.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 沙箱管理器
 */
@interface PAirSandbox : NSObject

+ (instancetype)sharedInstance;

- (void)presentSanboxInVC:(UIViewController *)vc;

@end
