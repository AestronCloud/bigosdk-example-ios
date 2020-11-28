//
//  CSMChannelMicUser.h
//  CStoreMediaEngineKit
//
//  Created by Caimu Yang on 2019/8/29.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BSMicLinkSeatUserInfo;

/**
 麦位相关信息
 */
@interface CSMChannelMicUser : NSObject

/// 房间sid
@property (nonatomic, assign, readonly) int64_t sid;
/// 用户uid
@property (nonatomic, assign, readonly) uint64_t uid;
/// 麦位序号：从0开始
@property (nonatomic, assign, readonly) int16_t micNum;
/// 座位号：从1开始
@property (nonatomic, assign, readonly) int seatNum;
///是否禁用了视频
@property (nonatomic, assign, readonly) BOOL videoMuted;
///是否禁用了音频
@property (nonatomic, assign, readonly) BOOL audioMuted;
@property (nonatomic, assign, readonly) int32_t timestamp;
/// 频道名
@property (nonatomic, strong, readonly) NSString *channelName;
/// 进房额外信息
@property (nonatomic, strong, readonly) NSString * extraInfo;

+ (instancetype)channelMicUserWithMicLinkSeatUserInfo:(BSMicLinkSeatUserInfo *)micLinkSeatUserInfo;

@end

NS_ASSUME_NONNULL_END
