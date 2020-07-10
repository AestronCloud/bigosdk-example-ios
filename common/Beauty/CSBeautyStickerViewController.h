//
//  CSBeautyStickerViewController.h
//  video-live
//
//  Created by 林小程 on 2020/8/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CSBeautyStickerViewControllerDismissBlock)(void);

@interface CSBeautyStickerViewController : UIViewController

+ (void)showInVC:(UIViewController *)vc dismissBlock:(CSBeautyStickerViewControllerDismissBlock)dismissBlock;

@end

NS_ASSUME_NONNULL_END
