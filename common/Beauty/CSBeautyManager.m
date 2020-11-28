//
//  CSBeautyManager.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/8/11.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyManager.h"
#import "CSBeautyDataSourceItem.h"
#import "CSBeautyFilterDataSource.h"
#import "CSBeautyBodyDataSource.h"
#import "CSBeautySkinDataSource.h"
#import "CSBeautyStickerDataSource.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>

@interface CSBeautyManager ()

@property(nonatomic, strong)NSString *filterPathBeforePause;
@property(nonatomic, assign)int filterLevelBeforePause;
@property(nonatomic, strong)NSString *whiteningSkinPathBeforePause;
@property(nonatomic, assign)int whiteningLevelBeforePause;
@property(nonatomic, assign)int smoothLevelBeforePause;
@property(nonatomic, assign)int bigEyeLevelBeforePause;
@property(nonatomic, assign)int thinFaceLevelBeforePause;

@end

@implementation CSBeautyManager

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)prepare {
#if AdvancedBeauty
    [[CStoreMediaEngineCore sharedSingleton] enableVenusEngineWithModelPath:[[NSBundle mainBundle] pathForResource:@"CStoreMediaEngineModel" ofType:@"bundle"]];
#endif
}

- (void)unprepare {
    _filterDS = nil;
    _bodyDS = nil;
    _skinDS = nil;
    _stickerDS = nil;
}

- (void)pauseOrResumeAllBeauty:(BOOL)pauseOrResume {
    NSString *filterPath = pauseOrResume ? nil : self.filterPathBeforePause;
    int filterLevel = pauseOrResume ? 0 : self.filterLevelBeforePause;
    NSString *whiteningSkinPath = pauseOrResume ? nil : self.whiteningSkinPathBeforePause;
    int whiteningLevel = pauseOrResume ? 0 : self.whiteningLevelBeforePause;
    int smoothLevel = pauseOrResume ? 0 : self.smoothLevelBeforePause;
    int bigEyeLevel = pauseOrResume ? 0 : self.bigEyeLevelBeforePause;
    int thinFaceLevel = pauseOrResume ? 0 : self.thinFaceLevelBeforePause;
    
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyFilterWithPath:filterPath level:filterLevel];
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyWhiteSkinWithPath:whiteningSkinPath level:whiteningLevel];
    [[CStoreMediaEngineCore sharedSingleton] setBeautifySmoothSkinWithLevel:smoothLevel];
#if AdvancedBeauty
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyBigEyeWithLevel:bigEyeLevel];
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyThinFaceWithLevel:thinFaceLevel];
#endif
}

- (void)setBeautifyFilterWithPath:(NSString * _Nullable)filterPath level:(int)level {
    self.filterPathBeforePause = filterPath;
    self.filterLevelBeforePause = level;
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyFilterWithPath:filterPath level:level];
    [[CStoreMediaEngineCore sharedSingleton] setMediaSideFlags:YES onlyAudioPublish:YES seiSendType:0];
    
    unsigned char uuid[16] = {0x3c, 0x13, 0x1e, 0x19,
        0x16, 0x18, 0x49, 0x1c,
        0x1a, 0x33, 0x15, 0x1e,
        0x1f, 0x12, 0x53, 0x4d};
    NSString *uuidStr = [NSString stringWithCString:(const char *)uuid encoding:NSUTF8StringEncoding];
    [[CStoreMediaEngineCore sharedSingleton] sendMediaSideInfo:[NSString stringWithFormat:@"%@ios:filter is changed,send in audio.", uuidStr]];
}

- (void)setBeautifyWhiteSkin:(NSString * _Nullable)whiteResourcePath level:(int)level {
    self.whiteningSkinPathBeforePause = whiteResourcePath;
    self.whiteningLevelBeforePause = level;
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyWhiteSkinWithPath:whiteResourcePath level:level];
}

- (void)setBeautifySmoothSkin:(int)level {
    self.smoothLevelBeforePause = level;
    [[CStoreMediaEngineCore sharedSingleton] setBeautifySmoothSkinWithLevel:level];
}

- (void)setBeautifyBigEyeWithLevel:(int)level {
    self.bigEyeLevelBeforePause = level;
#if AdvancedBeauty
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyBigEyeWithLevel:level];
#endif
}

- (void)setBeautifyThinFaceWithLevel:(int)level {
    self.thinFaceLevelBeforePause = level;
#if AdvancedBeauty
    [[CStoreMediaEngineCore sharedSingleton] setBeautifyThinFaceWithLevel:level];
#endif
}

- (void)setStickerWithPath:(NSString * _Nullable)path {
#if AdvancedBeauty
    [[CStoreMediaEngineCore sharedSingleton] setStickerWithPath:path];
#endif
    [[CStoreMediaEngineCore sharedSingleton] setMediaSideFlags:YES onlyAudioPublish:NO seiSendType:0];
    
    unsigned char uuid[16] = {0x3c, 0x13, 0x1e, 0x19,
        0x16, 0x18, 0x49, 0x1c,
        0x1a, 0x33, 0x15, 0x1e,
        0x1f, 0x12, 0x53, 0x4d};
    NSString *uuidStr = [NSString stringWithCString:(const char *)uuid encoding:NSUTF8StringEncoding];
    [[CStoreMediaEngineCore sharedSingleton] sendMediaSideInfo:[NSString stringWithFormat:@"%@ios:sticker is changed,send in video.", uuidStr]];
}

#pragma mark - Getter
- (CSBeautyBaseDataSource *)filterDS {
    if (!_filterDS) {
        _filterDS = [[CSBeautyFilterDataSource alloc] init];
    }
    return _filterDS;
}

- (CSBeautyBaseDataSource *)bodyDS {
    if (!_bodyDS) {
        _bodyDS = [[CSBeautyBodyDataSource alloc] init];
    }
    return _bodyDS;
}

- (CSBeautyBaseDataSource *)skinDS {
    if (!_skinDS) {
        _skinDS = [[CSBeautySkinDataSource alloc] init];
    }
    return _skinDS;
}

- (CSBeautyBaseDataSource *)stickerDS {
    if (!_stickerDS) {
        _stickerDS = [[CSBeautyStickerDataSource alloc] init];
    }
    return _stickerDS;
}

@end
