//
//  CSMTranscodingUser.h
//  CStoreMediaEngineKit
//
//  Created by 林小程 on 2020/9/4.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 提供合流转码时特定用户音频/视频转码设置的类
 */
@interface CSMTranscodingUser : NSObject

@property (nonatomic, assign) uint64_t uid;///<  参与合流转码的用户 ID
/**
 直播视频上用户视频在布局中相对左上角的位置和大小信息
 
 rect的x,y需要>=0，rect的width和height需要>0，并满足：0 < x + width <= transcoding.rect.size.width和0 < y + height <= transcoding.rect.size.height
 */
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) uint8_t zOrder;///<  用户视频帧的图层编号，范围[0,100]，最小值为0，表示该区域图像位于最下层

@end

NS_ASSUME_NONNULL_END
