//
//  CStoreMediaEngineCore.h
//  CStoreEngineKit
//
//  Created by Caimu Yang on 2019/8/20.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CStoreMediaEngineCoreDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CStoreMediaEngineCore : NSObject

/**
 设置/获取 CStoreMediaEngineCoreDelegate 
 */
@property (nonatomic, weak) id<CStoreMediaEngineCoreDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
