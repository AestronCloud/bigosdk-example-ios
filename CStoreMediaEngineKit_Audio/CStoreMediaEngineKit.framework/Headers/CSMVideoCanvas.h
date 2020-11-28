//
//  CSMVideoCanvas.h
//  CStoreMediaEngineKit
//
//  Created by 林小程 on 2020/10/30.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 视频画布对象
 */
@interface CSMVideoCanvas : NSObject

/**
 视频显示视窗，赋值前需要确保该view的尺寸不为0
 */
@property(nonatomic, strong)UIView *view;

/**
 用户 ID，指定需要显示视窗的 uid
 */
@property(nonatomic, assign)uint64_t uid;

@end

NS_ASSUME_NONNULL_END
