//
//  CSMusicViewController.h
//  video-live
//
//  Created by 林小程 on 2020/10/21.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
@class CSMusicViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol CSMusicViewControllerDelegate <NSObject>

- (void)didTapBgOfMusicViewController:(CSMusicViewController *)controller;

@end

@interface CSMusicViewController : UIViewController

@property(nonatomic, weak)id<CSMusicViewControllerDelegate> delegate;

- (void)localAudioEffectStateChange:(BigoAudioMixingStateCode)state soundId:(NSInteger)soundId reason:(NSUInteger)reason;
- (void)localAudioMixingStateDidChanged:(BigoAudioMixingStateCode)state  reason:(NSUInteger)reason;
- (void)reportAudioVolumeIndicationOfSpeakers:(NSArray*)uid volume:(NSArray*)volume vad:(NSArray*)vad channelId:(NSArray<NSString *>*)channelId totalVolume:(NSUInteger)totalVolume;
- (void)activeSpeaker:(int64_t)uid;
@end

NS_ASSUME_NONNULL_END
