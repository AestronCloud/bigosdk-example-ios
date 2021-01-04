//
//  CSTestArgSettingManager.h
//  cstore-example-ios
//
//  Created by 林小程 on 2020/10/9.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

NS_ASSUME_NONNULL_BEGIN

#define TestArg [CSTestArgSettingManager sharedInstance].testArg

@interface CSTestArg : NSObject<FXForm>

@property(nonatomic, assign)BOOL customVideoCapture;
@property(nonatomic, strong)NSString *joinExtraInfo;
@property(nonatomic, assign)BOOL multiViewRenderMode;
@property(nonatomic, strong)NSString *autoRtmpUrl;
@property(nonatomic, strong)NSString *countryCode;

@end

@interface CSTestArgSettingManager : NSObject

@property(nonatomic, strong)CSTestArg *testArg;

+ (instancetype)sharedInstance;
- (void)prepare;

@end

@interface CSTestArgSettingViewController : FXFormViewController

+ (instancetype)controller;

@end

NS_ASSUME_NONNULL_END
