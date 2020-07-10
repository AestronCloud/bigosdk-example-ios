//
//  CSBeautyFilterDataSource.m
//  video-live
//
//  Created by 林小程 on 2020/8/7.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyFilterDataSource.h"
#import "CSUtils.h"
#import "CSBeautyDataSourceItem.h"
#import "CSBeautyManager.h"

#define FilterItemConfig(defaultStrength, name, resourceName) \
@{ KEY_DEFAULT_STRENGTH : @(defaultStrength), KEY_NAME : name, KEY_RESOURCE_NAME : resourceName }

#define KEY_DEFAULT_STRENGTH @"defaultStrength"
#define KEY_NAME @"name"
#define KEY_RESOURCE_NAME @"resourceName"

#define FilterVersion @"1"

@implementation CSBeautyFilterDataSource

- (void)doPrepareDataWithCompletion:(CSBeautyBaseDataSourcePrepareCompletion)completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        
        //解压资源
        NSString *nowVer = [[NSString alloc] initWithContentsOfFile:[self cs_versionFilePath] encoding:NSUTF8StringEncoding error:nil];
        if (nowVer.length == 0 || ![nowVer isEqualToString:FilterVersion]) {
            NSString *zipPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"zip"];
            [CSUtils unzip:zipPath to:[self cs_filterResourceDir]];
        }
        
        //解析资源配置，更新配置记得更新版本号 FilterVersion
        NSArray<NSDictionary *> *configs = @[
            FilterItemConfig(0, @"原图", @""),
            FilterItemConfig(30, @"鲜明", @"lutimage_beauty_brown.png"),
            FilterItemConfig(70, @"少女", @"f_pink_v2.png"),
            FilterItemConfig(60, @"质感", @"f_texture_v2.png"),
            FilterItemConfig(80, @"高雅", @"f_chic_v2.png"),
            FilterItemConfig(70, @"彩虹", @"f_rainbow_v2.png"),
            FilterItemConfig(70, @"粉嫩", @"lut_babypink.png"),
            FilterItemConfig(80, @"清晰", @"lutimage_modern.png"),
            FilterItemConfig(80, @"自然", @"lutimage_original.png"),
            FilterItemConfig(70, @"櫻桃", @"lut_cherry.png"),
            FilterItemConfig(70, @"神秘", @"lut_danube_new.png"),
            FilterItemConfig(70, @"暖阳", @"lut_a6.png"),
            FilterItemConfig(70, @"樱花", @"lut_sakura.png"),
            FilterItemConfig(70, @"情书", @"lut_se_new.png"),
        ];
        NSMutableArray<CSBeautyDataSourceItem *> *mutItems = [NSMutableArray array];
        __block CSBeautyDataSourceItem *disableItem;
        [configs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
            CSBeautyDataSourceItem *item = [[CSBeautyDataSourceItem alloc] init];
            item.name = dic[KEY_NAME];
            if ([dic[KEY_RESOURCE_NAME] length] == 0) { //原图
                item.icon = [UIImage imageNamed:@"icon_filter_origin"];
                disableItem = item;
            } else {
                NSString *iconPath = [[self cs_filterResourceDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"icon_%@", dic[KEY_RESOURCE_NAME]]];
                if (iconPath) {
                    item.icon = [UIImage imageWithContentsOfFile:iconPath];
                }
            }
            
            item.resourcePath = [[self cs_filterResourceDir] stringByAppendingPathComponent:dic[KEY_RESOURCE_NAME]];
            item.defaultLevel = [dic[KEY_DEFAULT_STRENGTH] intValue];
            [mutItems addObject:item];
        }];
                
        MainThreadBegin
        if (completion) {
            completion(mutItems, disableItem, disableItem);
        }
        MainThreadCommit
    });
}


- (void)doBeautyActionOfItem:(CSBeautyDataSourceItem *)item {
    [[CSBeautyManager sharedInstance] setBeautifyFilterWithPath:item.resourcePath level:item.level];
}

#pragma mark - Private
- (NSString *)cs_filterRootDir {
    NSString *rootDir = [[CSUtils libraryPath] stringByAppendingPathComponent:@"Filter"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return rootDir;
}

- (NSString *)cs_versionFilePath {
    NSString *path = [[self cs_filterRootDir] stringByAppendingPathComponent:@"version"];
    return path;
}

- (NSString *)cs_filterResourceDir {
    return [[self cs_filterRootDir] stringByAppendingPathComponent:@"Resources"];
}

@end
