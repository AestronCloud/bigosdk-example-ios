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
#import "KSCrash/KSCrash.h"
#import "KSCrash/KSCrashPendingCrash.h"
#import "CSUtils.h"
#import "CSDataStore.h"
#import "CSTranscodingInfoManager.h"
#import "CSTestArgSettingManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)sharedInstance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[CSTestArgSettingManager sharedInstance] prepare];

    [CStoreMediaEngineCore launchWithAppId:[CSDataStore sharedInstance].appId];
#ifdef DEBUGLOG_ENABLE
    [self enabelCrashCollect];
#endif
    
    CSMainViewController *mainVC = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:@"CSMainViewController"];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    _globalNavController = navVC;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
    [[CSTranscodingInfoManager sharedInstance] prepare];
    
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

#pragma mark - Crash
#ifdef DEBUGLOG_ENABLE
- (void)enabelCrashCollect {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                KSCrash *ksCrash = [KSCrash sharedInstance];
                // ksCrash.deleteBehaviorAfterSendAll = KSCDeleteOnSucess; // no need to set, delete manually
                ksCrash.monitoring = KSCrashMonitorTypeProductionSafeMinimal; // default
                ksCrash.demangleLanguages = KSCrashDemangleLanguageNone;
                ksCrash.addConsoleLogToReport = YES;
                //                ksCrash.printPreviousLog = YES;
                [ksCrash install];
                
                // 全局忽略SIGPIPE信号量
                struct sigaction sa;
                sa.sa_handler = SIG_IGN;
                sigaction(SIGPIPE, &sa, 0);
                
                [self storeLastCrashLog];
            });
        } @catch (NSException *exception) {
            NSLog(@"EnableCrashReporter Or ReportCrashLogToServer Error:%@", exception);
        }
    });
}

- (void)storeLastCrashLog {
    NSArray<NSDictionary*> *allReports = [[KSCrashPendingCrash sharedInstance] allReports];
    for (NSDictionary *dict in allReports) { // 每一条崩溃都需要上报海度
        NSString *report = dict[kKSCrashReport];
        NSDate *crashDate = [self getCrashDate:report] ?: [NSDate date];
        
        [self dateFormater].dateFormat = @"yyyyMMddHHmmssSSS";
        
        NSString *fileName = [NSString stringWithFormat:@"crash_%@", [[self dateFormater] stringFromDate:crashDate]];
        NSString *filePath = [[CSUtils docPath] stringByAppendingPathComponent:fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [report writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

- (NSDateFormatter *)dateFormater {
    static dispatch_once_t onceToken;
    static NSDateFormatter *f;
    dispatch_once(&onceToken, ^{
        f = [[NSDateFormatter alloc] init];
        f.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        f.timeZone = NSTimeZone.systemTimeZone;
    });
    return f;
}
                                       
- (NSDate *)getCrashDate:(NSString *)message
{
    @try {
        NSArray *lines = [message componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSRange range = [line rangeOfString:@"Date/Time:"];
            if (range.location != NSNotFound) {
                NSString *regularExpression = @"[0-9]";
                NSRange crashTimestampRange = [line rangeOfString:regularExpression options:NSRegularExpressionSearch];
                if (crashTimestampRange.location != NSNotFound) {
                    crashTimestampRange = NSMakeRange(crashTimestampRange.location, line.length - crashTimestampRange.location);
                    NSString *ret = [line substringWithRange:crashTimestampRange];
                    
                    [self dateFormater].dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS ZZZ";
                    
                    NSDate *crashDate = [[self dateFormater] dateFromString:ret];
                    return crashDate;
                } else {
                    return nil;
                }
            }
        }
    } @catch (NSException *exception) {
        
    }
    return nil;
}

#endif

@end
