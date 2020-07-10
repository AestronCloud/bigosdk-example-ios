//
//  AppDelegate.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "AppDelegate.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSMainViewController.h"
#import "CSUtils.h"
#import "CSDataStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [CStoreMediaEngineCore launchWithAppId:AppId];
    
    CSMainViewController *mainVC = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:@"CSMainViewController"];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    navVC.navigationBar.hidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[CStoreMediaEngineCore sharedSingleton] onApplicationWillResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[CStoreMediaEngineCore sharedSingleton] onApplicationDidEnterBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[CStoreMediaEngineCore sharedSingleton] onApplicationDidBecomeActive];
}

@end
