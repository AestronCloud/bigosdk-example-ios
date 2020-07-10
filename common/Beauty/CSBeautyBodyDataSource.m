//
//  CSBeautyBodyDataSource.m
//  video-live
//
//  Created by 林小程 on 2020/8/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyBodyDataSource.h"
#import "CSBeautyManager.h"

#define DISABLE_ITEM_NAME @"关闭"
#define BIGEYE_ITEM_NAME @"大眼"
#define THINFACE_ITEM_NAME @"瘦脸"
@implementation CSBeautyBodyDataSource

- (void)doPrepareDataWithCompletion:(CSBeautyBaseDataSourcePrepareCompletion)completion {
    CSBeautyDataSourceItem *disableItem = [[CSBeautyDataSourceItem alloc] init];
    disableItem.icon = [UIImage imageNamed:@"icon_filter_origin"];
    disableItem.name = DISABLE_ITEM_NAME;
    
    CSBeautyDataSourceItem *bigEyeItem = [[CSBeautyDataSourceItem alloc] init];
    bigEyeItem.icon = [UIImage imageNamed:@"icon_beauty_bigeye"];
    bigEyeItem.name = BIGEYE_ITEM_NAME;
    
    CSBeautyDataSourceItem *shrinkItem = [[CSBeautyDataSourceItem alloc] init];
    shrinkItem.icon = [UIImage imageNamed:@"icon_beauty_shrink_face"];
    shrinkItem.name = THINFACE_ITEM_NAME;

    if (completion) {
        completion(@[ disableItem, bigEyeItem, shrinkItem ], disableItem, disableItem);
    }
}

- (void)doBeautyActionOfItem:(CSBeautyDataSourceItem *)item {
    if (!item || [item.name isEqualToString:DISABLE_ITEM_NAME]) {
        [[CSBeautyManager sharedInstance] setBeautifyBigEyeWithLevel:0];
        [[CSBeautyManager sharedInstance] setBeautifyThinFaceWithLevel:0];
    } else if ([item.name isEqualToString:BIGEYE_ITEM_NAME]) {
        [[CSBeautyManager sharedInstance] setBeautifyBigEyeWithLevel:item.level];
    } else if ([item.name isEqualToString:THINFACE_ITEM_NAME]) {
        [[CSBeautyManager sharedInstance] setBeautifyThinFaceWithLevel:item.level];
    }
}


@end
