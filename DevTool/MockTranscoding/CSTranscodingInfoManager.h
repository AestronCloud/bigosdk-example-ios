//
//  CSTranscodingInfoManager.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/9/27.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSTranscodingInfoManager : NSObject

+ (instancetype)sharedInstance;
- (void)prepare;
- (NSUInteger)transcodingUserCountInPk:(BOOL)isPk;
- (CSMLiveTranscoding *)transcodingInPk:(BOOL)isPk withUids:(NSArray<NSNumber *> *)uids;
- (void)restoreDefaultTranscodingInPk:(BOOL)isPk;

@end

@interface CSModiTranscodingFormController : FXFormViewController

+ (CSModiTranscodingFormController *)formControllerWithPkOrMic:(BOOL)isPK;

@end;

NS_ASSUME_NONNULL_END
