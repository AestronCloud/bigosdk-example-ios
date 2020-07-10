//
//  CSBeautyStickerDataSource.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/8/11.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyStickerDataSource.h"
#import "CSUtils.h"
#import "CSBeautyManager.h"

static inline NSString *StickerRootDir() {
    NSString *rootDir = [[CSUtils libraryPath] stringByAppendingPathComponent:@"Sticker"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return rootDir;
}

static inline CSBeautyDataSourceItem* Sticker(NSString *resourceName) {
    CSBeautyDataSourceItem *item = [[CSBeautyDataSourceItem alloc] init];
    if (resourceName.length > 0) {
        if ([resourceName isEqualToString:@"关闭"]) {
            item.icon = [UIImage imageNamed:@"icon_beauty_clear_sticker"];
            item.resourcePath = nil;
        } else {
            item.icon = [UIImage imageNamed:resourceName];
            item.resourcePath = [StickerRootDir() stringByAppendingPathComponent:resourceName];
        }
        item.name = resourceName;
    }
    return item;
}

@implementation CSBeautyStickerDataSource

- (void)doPrepareDataWithCompletion:(CSBeautyBaseDataSourcePrepareCompletion)completion {
    NSArray<CSBeautyDataSourceItem *> *conf = @[
        Sticker(@"关闭"),
        Sticker(@"泰迪熊"),
        Sticker(@"功夫熊"),
        Sticker(@"亮粉猫"),
        Sticker(@"小黑猫"),
        Sticker(@"小熊发夹"),
        Sticker(@"小熊猫"),
        Sticker(@"比心"),
        Sticker(@"爱心桃"),
        Sticker(@"小可爱"),
        Sticker(@"粉红咩咩")
    ];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        
        //解压素材
        for (CSBeautyDataSourceItem *info in conf) {
            NSString *destPath = info.resourcePath;
            if (destPath.length > 0) {
                NSString *zipPath = [[NSBundle mainBundle] pathForResource:info.name ofType:@"zip"];
                BOOL isDir = NO;
                if ([[NSFileManager defaultManager] fileExistsAtPath:destPath isDirectory:&isDir] && isDir) {
                    continue;
                }
                
                [CSUtils unzip:zipPath to:destPath];
            }
        }
        
        if (completion) {
            completion(conf, conf.firstObject, conf.firstObject);
        }
        
        //删除无效的素材文件
        NSArray<NSString *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:StickerRootDir() error:nil];
        for (NSString *existPath in contents) {
            NSString *existResourceName = existPath.lastPathComponent;
            NSUInteger index = [conf indexOfObjectPassingTest:^BOOL(CSBeautyDataSourceItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [obj.name isEqualToString:existResourceName];
            }];
            if (index != NSNotFound) {
                [[NSFileManager defaultManager] removeItemAtPath:existPath error:nil];
            }
        }
    });
}

- (void)doBeautyActionOfItem:(CSBeautyDataSourceItem *)item {
    [[CSBeautyManager sharedInstance] setStickerWithPath:item.resourcePath];
}

@end
