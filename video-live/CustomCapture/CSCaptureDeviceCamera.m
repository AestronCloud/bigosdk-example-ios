//
//  CSCaptureDeviceCamera.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "CSCaptureDeviceCamera.h"

@interface CSCaptureDeviceCamera () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _sampleBufferCallbackQueue;
}

@property (nonatomic, assign) OSType pixelFormatType;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) int framerate;

@property (nonatomic, assign) BOOL isRunning;

@end

@implementation CSCaptureDeviceCamera

- (instancetype)initWithPixelFormatType:(OSType)pixelFormatType {
    self = [super init];
    if (self) {
        _pixelFormatType = pixelFormatType;

        // Use front camera as default
        _cameraPosition = AVCaptureDevicePositionFront;

        // Default is 30 fps
        _framerate = 30;

        _sampleBufferCallbackQueue = dispatch_queue_create("cs.bigo.outputCallbackQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (void)startCapture {
    if (self.isRunning) {
        return;
    }
    
    [self.session beginConfiguration];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    AVCaptureDeviceInput *input = self.input;
    
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    
    AVCaptureVideoDataOutput *output = self.output;
    
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    AVCaptureConnection *captureConnection = [output connectionWithMediaType:AVMediaTypeVideo];
    
    if (captureConnection.isVideoOrientationSupported) {
        captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    [self.session commitConfiguration];
    
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
    
    self.isRunning = YES;
}

- (void)stopCapture {
    if (!self.isRunning) {
        return;
    }
    
    if (self.session.isRunning) {
        [self.session stopRunning];
        [self.session removeInput:_input];
    }
    
    self.isRunning = NO;
}

- (void)switchCameraPosition {

    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        self.cameraPosition = AVCaptureDevicePositionBack;
    } else {
        self.cameraPosition = AVCaptureDevicePositionFront;
    }

    // Restart capture
    if (self.isRunning) {
        [self stopCapture];
        [self startCapture];
    }
}

- (void)setFramerate:(int)framerate {
    if (!_device) {
        NSLog(@"Camera is not actived");
        return;
    }

    NSArray<AVFrameRateRange *> *ranges = _device.activeFormat.videoSupportedFrameRateRanges;
    AVFrameRateRange *range = [ranges firstObject];

    if (!range) {
        NSLog(@"videoSupportedFrameRateRanges is empty");
        return;
    }

    if (framerate > range.maxFrameRate || framerate < range.minFrameRate) {
        NSLog(@"Unsupport framerate: %d, range is %.2f ~ %.2f", framerate, range.minFrameRate, range.maxFrameRate);
        return;
    }

    NSError *error = [[NSError alloc] init];
    if (![_device lockForConfiguration:&error]) {
        NSLog(@"AVCaptureDevice lockForConfiguration failed. errCode:%ld, domain:%@", error.code, error.domain);
    }
    _device.activeVideoMinFrameDuration = CMTimeMake(1, framerate);
    _device.activeVideoMaxFrameDuration = CMTimeMake(1, framerate);
    [_device unlockForConfiguration];

    NSLog(@"Set framerate to %d", framerate);
}

- (void)changeCaptureResolutionToWidth:(int)width height:(int)height {
    [self.session beginConfiguration];
    if (width >= 480 && height >= 854 && [self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    } else {
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
    }
    [self.session commitConfiguration];
}

#pragma mark - Getter

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

// Reacquire the camera every time it is called
- (AVCaptureDevice *)device {
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    // Get the specified position camera
    NSArray *captureDeviceArray = [cameras filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"position == %d", _cameraPosition]];
    if (captureDeviceArray.count == 0) {
        NSLog(@"Failed to get camera");
        return nil;
    }
    AVCaptureDevice *camera = captureDeviceArray.firstObject;


    _device = camera;
    return _device;
}

// Reacquire the camera every time it is called
- (AVCaptureDeviceInput *)input {

    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {
        NSLog(@"Conversion of AVCaptureDevice to AVCaptureDeviceInput failed");
        return nil;
    }
    _input = captureDeviceInput;

    return _input;
}

- (AVCaptureVideoDataOutput *)output {
    if (!_output) {
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(self.pixelFormatType)};
        [videoDataOutput setSampleBufferDelegate:self queue:_sampleBufferCallbackQueue];
        _output = videoDataOutput;
    }
    return _output;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    CFRetain(sampleBuffer);
    id<CSCaptureDeviceDataOutputPixelBufferDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(captureDevice:didCapturedData:)]) {
        [delegate captureDevice:self didCapturedData:sampleBuffer];
    }
    CFRelease(sampleBuffer);
}

@end
