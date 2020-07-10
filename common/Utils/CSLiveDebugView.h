//
//  CSLiveDebugView.h
//
//  Created by zy on 16/11/30.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSLiveDebugView;

@protocol CSLiveDebugViewDataSource <NSObject>

@optional
- (NSString *)mssdkDebugInfoForLiveDebugView:(CSLiveDebugView *)liveDebugView;

@end

/**
 显示debug信息的视图
 */
@interface CSLiveDebugView : UIView

@property (weak, nonatomic) id<CSLiveDebugViewDataSource> dataSource;

- (instancetype)initWithFrame:(CGRect)frame vc:(UIViewController *)vc;

- (void)dismiss;

@end
