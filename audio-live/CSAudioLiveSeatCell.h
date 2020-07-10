//
//  CSAudioLiveSeatCell.h
//  audio-live
//
//  Created by 林小程 on 2020/7/23.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface CSAudioLiveSeatCell : UIView

@property(nonatomic, assign, readonly)uint64_t onMicUid;

- (void)setOnMicUid:(uint64_t)onMicUid myUid:(uint64_t)myUid;
- (void)setUid:(uint64_t)uid speaking:(BOOL)speaking;

@end

NS_ASSUME_NONNULL_END
