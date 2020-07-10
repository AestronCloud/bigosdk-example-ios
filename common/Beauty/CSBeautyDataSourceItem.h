//
//  CSBeautyDataSourceItem.h
//  video-live
//
//  Created by 林小程 on 2020/8/7.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSBeautyDataSourceItem : NSObject

@property(nonatomic, strong)UIImage *icon;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong, nullable)NSString *resourcePath;
@property(nonatomic, assign)int level; //第一次打开该效果时，把defaultLevel赋值给level
@property(nonatomic, assign)int defaultLevel;

//第一次选中某个美颜效果，则把默认等级赋值给level
- (void)markSelected;

@end

NS_ASSUME_NONNULL_END
