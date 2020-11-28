//
//  CSMLocalVideoStats.h
//  CStoreMediaEngineKit
//
//  Created by 林小程 on 2020/11/11.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 本地视频流统计信息
 */
@interface CSMLocalVideoStats : NSObject

/**
 实际发送码率，单位为 Kbps，不包含丢包后重传的视频码率。
 */
@property (nonatomic) int32_t sentBitrate;

/**
 实际发送帧率，单位为 fps，不包含丢包后重传视频等的发送帧率。
 */
@property (nonatomic) int32_t sentFrameRate;

/**
 本地编码器的输出帧率，单位为 fps。
 */
@property (nonatomic) int32_t encoderOutputFrameRate;

/**
 视频编码码率（Kbps）。该参数不包含丢包后重传视频等的编码码率。
 */
@property (nonatomic) int32_t encodedBitrate;

/**
 视频编码宽度（px）。
 */
@property (nonatomic) int32_t encodedFrameWidth;

/**
 视频编码高度（px)。
 */
@property (nonatomic) int32_t encodedFrameHeight;

/**
 弱网对抗前本地客户端到边缘服务器的视频丢包率 (%)。
 */
@property (nonatomic) int32_t txPacketLossRate;

/**
 本地采集帧率 (fps)。
 */
@property (nonatomic) int32_t captureFrameRate;

@end

NS_ASSUME_NONNULL_END
