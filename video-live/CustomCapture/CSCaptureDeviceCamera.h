//
//  CSCaptureDeviceCamera.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class CSCaptureDeviceCamera;

NS_ASSUME_NONNULL_BEGIN

@protocol CSCaptureDeviceDataOutputPixelBufferDelegate <NSObject>

- (void)captureDevice:(CSCaptureDeviceCamera *)device didCapturedData:(CMSampleBufferRef)data;

@end

@interface CSCaptureDeviceCamera : NSObject

@property (nonatomic, weak) id<CSCaptureDeviceDataOutputPixelBufferDelegate> delegate;

- (instancetype)initWithPixelFormatType:(OSType)pixelFormatType;


- (void)startCapture;

- (void)stopCapture;

// Only for camera
- (void)switchCameraPosition;

- (void)setFramerate:(int)framerate;

- (void)changeCaptureResolutionToWidth:(int)width height:(int)height;


@end

NS_ASSUME_NONNULL_END
