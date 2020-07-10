//
//  CSBeautyDataSourceItem.m
//  video-live
//
//  Created by 林小程 on 2020/8/7.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyDataSourceItem.h"

@interface CSBeautyDataSourceItem ()

@property(nonatomic, assign)BOOL everSelected; //标识是否被选中过

@end

@implementation CSBeautyDataSourceItem

- (void)markSelected {
    if (!self.everSelected) {
        self.everSelected = YES;
        self.level = self.defaultLevel;
    }
}

@end
