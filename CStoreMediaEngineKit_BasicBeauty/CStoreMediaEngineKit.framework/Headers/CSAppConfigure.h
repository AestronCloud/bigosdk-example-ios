//
//  CSAppConfigure.h
//  CStoreMediaEngineKit
//
//  Created by 周好冲 on 2020/12/12.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSAppConfigure : NSObject

/**
 * 用户所在地区的国家码
 * SDK能根据用户国家码去接入更优的直播线路
 */
@property (nonatomic, copy) NSString* countryCode;

- (void)setCountryCode:(NSString * _Nonnull)countryCode;

@end

NS_ASSUME_NONNULL_END
