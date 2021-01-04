//
//  BigoAudioFrameObserver.cpp
//  Example
//
//  Created by audio on 2020/9/28.
//  Copyright © 2020 BIGO Inc. All rights reserved.
//

#import "BigoAudioProcessing.hpp"
#import <CStoreMediaEngineKit/BigoMediaEngine.h>

class BigoAudioFrameObserver : public bigo::IAudioFrameObserver
{
public:
    virtual void onRecordFrame (char* data, int len, int bytesPerSample, int channel, int samplesPerSec) override
    {
    }
    
    virtual void onPlaybackFrame (char* data, int len, int bytesPerSample, int channel, int samplesPerSec) override {
    }
    
    virtual void onEffectFileFrame (char* data, int len, int bytesPerSample, int channel, int samplesPerSec)  override {
    }
    
    ~BigoAudioFrameObserver() {
    }
    
};


static BigoAudioFrameObserver mBigoAudioFrameObserver;

@implementation BigoAudioProcessing

+ (void)registerAudioPreprocessing: (CStoreMediaEngineCore*) engine {
    if (!engine) {
        return;
    }
    [engine registerAudioFrameObserver:long(&mBigoAudioFrameObserver)];
}

+ (void)deregisterAudioPreprocessing:(CStoreMediaEngineCore*) engine {
    if (!engine) {
        return;
    }
    [engine registerAudioFrameObserver:0];
}

@end


