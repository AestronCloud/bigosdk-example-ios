//
//  CSLiveBaseInfoView.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/27.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface CSLiveBaseInfoView : UIView

- (void)setMyUid:(uint64_t)myud channelName:(NSString *)channelName;

@end

NS_ASSUME_NONNULL_END
