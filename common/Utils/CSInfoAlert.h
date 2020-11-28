//
//  DWInfoAlert.h
//  YYMeet
//
//  Created by chenlei1 on 12-12-1.
//
//  alert控件，用于显示相关alert信息,1.5s后自动消失，不包含按钮

#import <UIKit/UIKit.h>

@interface CSInfoAlert : UIView

+ (instancetype)showInfo:(NSString*)info;
+ (instancetype)showInfo:(NSString*)info vertical:(CGFloat)height;
+ (instancetype)showInfo:(NSString *)info
                  inView:(UIView *)view
                vertical:(CGFloat)height;

@end
