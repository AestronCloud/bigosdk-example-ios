//
//  AppDelegate.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, strong)UIWindow *window;
@property(nonatomic, strong, readonly)UINavigationController *globalNavController;

+ (AppDelegate *)sharedInstance;

@end

