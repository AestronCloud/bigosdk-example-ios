//
//  CSELocalAudioStats.h
//  CStoreMediaEngineKit
//
//  Created by 林小程 on 2020/11/11.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 本地音频统计信息
 */
@interface CSMLocalAudioStats : NSObject

/**
 发送码率的平均值，单位为 Kbps。
 */
@property (nonatomic) int32_t sentBitrate;

/**
 弱网对抗前本地客户端到 Bigo 边缘服务器的音频丢包率 (%)。
 */
@property (nonatomic) int32_t txPacketLossRate;

@end

NS_ASSUME_NONNULL_END
