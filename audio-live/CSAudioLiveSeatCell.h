//
//  CSAudioLiveSeatCell.h
//  audio-live
//
//  Created by 林小程 on 2020/7/23.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSAudioLiveSeatCell;

NS_ASSUME_NONNULL_BEGIN

@protocol CSAudioLiveSeatCellDelegate <NSObject>

- (void)actionDidTapMuteOfAudioLiveSeatCell:(CSAudioLiveSeatCell *)cell;

@end

@interface CSAudioLiveSeatCell : UICollectionViewCell

@property(nonatomic, assign, readonly)uint64_t onMicUid;

@property(nonatomic, weak)id<CSAudioLiveSeatCellDelegate> delegate;

- (void)setOnMicUid:(uint64_t)onMicUid myUid:(uint64_t)myUid speaking:(BOOL)speaking mute:(BOOL)mute;

@end

NS_ASSUME_NONNULL_END
