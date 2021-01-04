//
//  CSTestArgSettingManager.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/10/9.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSTestArgSettingManager.h"
#import "MJExtension.h"
#import "CSInfoAlert.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSUtils.h"
#import "AppDelegate.h"

#define TestArgSaveKey @"CSTestArgSettingManager.CSTestArg"

static inline void ReloadFormControllerIfNeed() {
    FXFormViewController *ctrl = (FXFormViewController *)[AppDelegate sharedInstance].globalNavController.topViewController;
    if ([ctrl isKindOfClass:[FXFormViewController class]]) {
        [ctrl.tableView reloadData];
    }
}

@interface CSTestArgSettingManager ()

- (void)saveTestArg;

@end

@implementation CSTestArg

- (NSDictionary *)customLbsConfigField
{
    return @{ FXFormFieldTitle: @"自定义Lbs和AppId"};
}

- (NSDictionary *)customVideoCaptureField
{
    return @{ FXFormFieldTitle: @"自定义视频源"};
}

- (NSDictionary *)joinExtraInfoField {
    return @{ FXFormFieldTitle: @"进房额外信息" };
}

- (NSDictionary *)multiViewRenderModeField {
    return @{ FXFormFieldTitle: @"多View绘制模式" };
}

- (NSDictionary *)autoRtmpUrlField {
    return @{ FXFormFieldTitle: @"单主播自动合流地址" };
}

- (NSDictionary *)countryCodeField {
    return @{ FXFormFieldTitle: @"国家码" };
}

@end

@implementation CSTestArgSettingManager

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)prepare {
    self.testArg = [self readTestArg];
    
    //默认自采集
    NSString *hasSetDefaultCustomVideoCapture = @"hasSetDefaultCustomVideoCapture";
    if (![[NSUserDefaults standardUserDefaults] boolForKey:hasSetDefaultCustomVideoCapture]) {
        self.testArg.customVideoCapture = YES;
        [self saveTestArg];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasSetDefaultCustomVideoCapture];
    }
    //默认多View绘制
    NSString *hasSetDefaultMultiViewRenderMode = @"hasSetDefaultMultiViewRenderMode";
    if (![[NSUserDefaults standardUserDefaults] boolForKey:hasSetDefaultMultiViewRenderMode]) {
        self.testArg.multiViewRenderMode = YES;
        [self saveTestArg];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasSetDefaultMultiViewRenderMode];
    }
}

- (void)saveTestArg {
    NSData *data = [self.testArg mj_JSONData];
    if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:TestArgSaveKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CSTestArg *)readTestArg {
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:TestArgSaveKey];
    CSTestArg *arg = nil;
    if (data) {
        arg = [CSTestArg mj_objectWithKeyValues:data];
    }
    
    return arg ?: [[CSTestArg alloc] init];
}

@end

@implementation CSTestArgSettingViewController

+ (instancetype)controller {
    CSTestArgSettingViewController *ctrl = [[CSTestArgSettingViewController alloc] init];
    ctrl.formController.form = [CSTestArgSettingManager sharedInstance].testArg;
    return ctrl;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[CSTestArgSettingManager sharedInstance] saveTestArg];
}

@end
