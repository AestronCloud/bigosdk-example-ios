//
//  CSBeautyBaseDataSource.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/8/11.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyBaseDataSource.h"
#import "CSUtils.h"

@interface CSBeautyBaseDataSource ()

@property(nonatomic, strong)CSBeautyDataSourceItem *selectedItem;
@property(nonatomic, strong)CSBeautyDataSourceItem *disabelItem;

@end

@implementation CSBeautyBaseDataSource

- (void)prepareDataWithCompletion:(void (^)(void))completion {
    MainThreadBegin
    if (self.items.count > 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self doPrepareDataWithCompletion:^(NSArray<CSBeautyDataSourceItem *> * _Nonnull items, CSBeautyDataSourceItem * _Nullable defaultItem, CSBeautyDataSourceItem * _Nullable disableItem) {
        MainThreadBegin
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        strongSelf.items = items;
        strongSelf.selectedItem = defaultItem;
        strongSelf.disabelItem = disableItem;
        if (completion) {
            completion();
        }
        MainThreadCommit
    }];
    MainThreadCommit
}

- (NSUInteger)count {
    return self.items.count;
}

- (CSBeautyDataSourceItem *)itemAtIndex:(NSUInteger)index {
    if (index < self.items.count) {
        return self.items[index];
    } else {
        return nil;
    }
}

- (void)selectItemAtIndex:(NSUInteger)index {
    if (index < self.items.count) {
        CSBeautyDataSourceItem *newSelectedItem = self.items[index];
        if (newSelectedItem != self.selectedItem) {
            self.selectedItem = newSelectedItem;
            [self doBeautyActionOfItem:self.selectedItem];
        }
    }
}

- (void)changeSelectedItemLevelTo:(int)level {
    if (self.selectedItem && self.selectedItem.level != level) {
        self.selectedItem.level = level;
        [self doBeautyActionOfItem:self.selectedItem];
    }
}

#pragma mark - For Override
- (void)doPrepareDataWithCompletion:(CSBeautyBaseDataSourcePrepareCompletion)completion {}
- (void)doBeautyActionOfItem:(CSBeautyDataSourceItem *)item {}

#pragma mark - Setter
- (void)setSelectedItem:(CSBeautyDataSourceItem *)selectedItem {
    _selectedItem = selectedItem;
    
    [_selectedItem markSelected];
}

@end
