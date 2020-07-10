//
//  CSBeautyManager.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/8/11.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSBeautyBaseDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSBeautyManager : NSObject

@property(nonatomic, strong)CSBeautyBaseDataSource *filterDS;
@property(nonatomic, strong)CSBeautyBaseDataSource *bodyDS;
@property(nonatomic, strong)CSBeautyBaseDataSource *skinDS;
@property(nonatomic, strong)CSBeautyBaseDataSource *stickerDS;

+ (instancetype)sharedInstance;
- (void)prepare;
- (void)unprepare;

- (void)pauseOrResumeAllBeauty:(BOOL)pauseOrResume;

#pragma mark - 美颜相关接口
- (void)setBeautifyFilterWithPath:(NSString * _Nullable)filterPath level:(int)level;
- (void)setBeautifyWhiteSkin:(NSString * _Nullable)whiteResourcePath level:(int)level;
- (void)setBeautifySmoothSkin:(int)level;
- (void)setBeautifyBigEyeWithLevel:(int)level;
- (void)setBeautifyThinFaceWithLevel:(int)level;
- (void)setStickerWithPath:(NSString * _Nullable)path;

@end

NS_ASSUME_NONNULL_END
