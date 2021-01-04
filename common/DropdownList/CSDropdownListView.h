//
//  CSDropdownList.h
//  cstore-example-ios
//
//  Created by 周好冲 on 2020/12/2.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSDropdownListItem : NSObject
@property (nonatomic, copy, readonly) NSString *itemId;
@property (nonatomic, copy, readonly) NSString *itemName;

- (instancetype)initWithItem:(NSString*)itemId itemName:(NSString*)itemName NS_DESIGNATED_INITIALIZER;
@end


@class CSDropdownListView;

typedef void (^CSDropdownListViewSelectedBlock)(CSDropdownListView *dropdownListView);

@interface CSDropdownListView : UIView
// 字体颜色，默认 blackColor
@property (nonatomic, strong) UIColor *textColor;
// 字体默认14
@property (nonatomic, strong) UIFont *font;
// 数据源
@property (nonatomic, strong) NSArray *dataSource;
// 默认选中第一个
@property (nonatomic, assign) NSUInteger selectedIndex;
// 当前选中的DropdownListItem
@property (nonatomic, strong, readonly) CSDropdownListItem *selectedItem;


- (instancetype)initWithDataSource:(NSArray*)dataSource;

- (void)setViewBorder:(CGFloat)width borderColor:(UIColor*)borderColor cornerRadius:(CGFloat)cornerRadius;

- (void)setDropdownListViewSelectedBlock:(CSDropdownListViewSelectedBlock)block;
@end
