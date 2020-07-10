//
//  CSBeautyBaseDataSource.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/8/11.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSBeautyDataSourceItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CSBeautyBaseDataSourcePrepareCompletion)(NSArray<CSBeautyDataSourceItem *> *items, CSBeautyDataSourceItem * _Nullable defaultItem, CSBeautyDataSourceItem * _Nullable disableItem);
@interface CSBeautyBaseDataSource : NSObject

@property(nonatomic, strong)NSArray<CSBeautyDataSourceItem *> *items;
@property(nonatomic, strong, readonly)CSBeautyDataSourceItem *selectedItem;
@property(nonatomic, strong, readonly)CSBeautyDataSourceItem *disabelItem;

#pragma mark - Public
- (void)prepareDataWithCompletion:(void(^ _Nullable)(void))completion;

- (NSUInteger)count;
- (CSBeautyDataSourceItem *)itemAtIndex:(NSUInteger)index;

- (void)selectItemAtIndex:(NSUInteger)index;
- (void)changeSelectedItemLevelTo:(int)level;

#pragma mark - Only For Override
- (void)doPrepareDataWithCompletion:(CSBeautyBaseDataSourcePrepareCompletion)completion;
- (void)doBeautyActionOfItem:(CSBeautyDataSourceItem *)item; //执行相应SDK接口进行美颜

@end

NS_ASSUME_NONNULL_END
