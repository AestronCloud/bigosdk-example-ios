//
//  CSMLiveTranscoding.h
//  CStoreMediaEngineKit
//
//  Created by 林小程 on 2020/9/4.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSMTranscodingUser.h"
#import "CSMTranscodingImage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 合流转码参数
 */
@interface CSMLiveTranscoding : NSObject

/**
 推流视频的总尺寸（宽和高），单位为像素
 
 - size.width范围为(0, 720]
 - size.height范围为(0,1280]
 */
@property (assign, nonatomic) CGSize size;
@property (nonatomic, assign) uint16_t videoBitrate;///<  码率(单位为 Kbps)
@property (nonatomic, assign) uint8_t videoFramerate;///<  帧率，单位为 fps
@property (nonatomic, assign) uint8_t videoGop;///<  旁路直播的输出视频的 GOP，单位为帧
@property (nonatomic, strong) NSArray<CSMTranscodingUser *> *transcodingUsers;///<  视频转码合图的用户，详见 CSMTranscodingUser
@property (nonatomic, strong) CSMTranscodingImage *backgroundImage;///<  输出视频上的背景图片，详见 CSMTranscodingImage

@end

NS_ASSUME_NONNULL_END
