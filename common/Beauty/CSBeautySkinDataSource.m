//
//  CSBeautySkinDataSource.m
//  video-live
//
//  Created by 林小程 on 2020/8/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautySkinDataSource.h"
#import "CSBeautyManager.h"

#define DISABLE_ITEM_NAME @"关闭"
#define WHITENING_ITEM_NAME @"美白"
#define SMOOTH_ITEM_NAME @"磨皮"

@implementation CSBeautySkinDataSource

- (void)doPrepareDataWithCompletion:(CSBeautyBaseDataSourcePrepareCompletion)completion {
    CSBeautyDataSourceItem *disableItem = [[CSBeautyDataSourceItem alloc] init];
    disableItem.icon = [UIImage imageNamed:@"icon_beauty_clear_sticker"];
    disableItem.name = DISABLE_ITEM_NAME;
    
    int defaultWhitening = 70;
    int defaultSmooth = 20;
    CSBeautyDataSourceItem *whiteningItem = [[CSBeautyDataSourceItem alloc] init];
    whiteningItem.icon = [UIImage imageNamed:@"icon_beauty_whitening"];
    whiteningItem.resourcePath = [[NSBundle mainBundle] pathForResource:@"whitening_lut_img" ofType:nil];
    whiteningItem.name = WHITENING_ITEM_NAME;
    whiteningItem.defaultLevel = defaultWhitening;
    
    CSBeautyDataSourceItem *smoothItem = [[CSBeautyDataSourceItem alloc] init];
    smoothItem.icon = [UIImage imageNamed:@"icon_beauty_smooth"];
    smoothItem.name = SMOOTH_ITEM_NAME;
    smoothItem.defaultLevel = defaultSmooth;
    
    if (completion) {
        completion(@[ disableItem, whiteningItem, smoothItem ], disableItem, disableItem);
    }
}

- (void)doBeautyActionOfItem:(CSBeautyDataSourceItem *)item {
    if (!item || [item.name isEqualToString:DISABLE_ITEM_NAME]) {
        [[CSBeautyManager sharedInstance] setBeautifyWhiteSkin:nil level:0];
        [[CSBeautyManager sharedInstance] setBeautifySmoothSkin:0];
    } else if ([item.name isEqualToString:WHITENING_ITEM_NAME]) {
        [[CSBeautyManager sharedInstance] setBeautifyWhiteSkin:item.resourcePath level:item.level];
    } else if ([item.name isEqualToString:SMOOTH_ITEM_NAME]) {
        [[CSBeautyManager sharedInstance] setBeautifySmoothSkin:item.level];
    }
}

@end
