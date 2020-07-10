//
//  CSBeautyViewController.h
//  video-live
//
//  Created by 林小程 on 2020/8/7.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CSBeautyViewControllerDismissBlock)(void);
@interface CSBeautyViewController : UIViewController

+ (void)showInVC:(UIViewController *)vc dismissBlock:(CSBeautyViewControllerDismissBlock)dismissBlock;

@end

NS_ASSUME_NONNULL_END
