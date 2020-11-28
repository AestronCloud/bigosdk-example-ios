//
//  BigoAudioFrameObserver.hpp
//  Example
//
//  Created by audio on 2020/9/28.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>

@interface BigoAudioProcessing : NSObject
+ (void)registerAudioPreprocessing:(CStoreMediaEngineCore *) engine;
+ (void)deregisterAudioPreprocessing:(CStoreMediaEngineCore *) engine;
@end

