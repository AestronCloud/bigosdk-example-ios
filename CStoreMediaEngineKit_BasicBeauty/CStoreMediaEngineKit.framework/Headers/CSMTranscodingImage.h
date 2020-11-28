//
//  CSMTranscodingImage.h
//  CStoreMediaEngineKit
//
//  Created by 林小程 on 2020/9/4.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 图像属性
 */
@interface CSMTranscodingImage : NSObject

@property (nonatomic, copy) NSString *url;///<  HTTP/HTTPS 地址
/**
 图片在视频帧上的位置和大小，类型为 CGRect，坐标系原点为左上角
 
 rect的x,y需要>=0，rect的width和height需要>0，并满足：0 < x + width <= transcoding.rect.size.width和0 < y + height <= transcoding.rect.size.height
 */
@property (nonatomic, assign)CGRect rect;

@end

NS_ASSUME_NONNULL_END
