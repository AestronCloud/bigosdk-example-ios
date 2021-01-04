//
//  CSVoiceChangerViewController.h
//  cstore-example-ios
//
//  Created by 周好冲 on 2020/12/2.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSVoiceChangerViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol CSVoiceChangerViewControllerDelegate <NSObject>

- (void)didTapBgOfVoiceChangerViewController:(CSVoiceChangerViewController*)controller;

@end

@interface CSVoiceChangerViewController : UIViewController

@property(nonatomic, weak)id<CSVoiceChangerViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
