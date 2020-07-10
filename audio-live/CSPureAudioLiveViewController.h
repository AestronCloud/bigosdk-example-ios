//
//  CSAudioLiveViewController.h
//  audio-live
//
//  Created by 林小程 on 2020/7/23.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLiveViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSAudioLiveViewController : UIViewController<CSLiveViewControllerProtocol>

@property (nonatomic, assign) CSMClientRole clientRole;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *username;

@end

NS_ASSUME_NONNULL_END
