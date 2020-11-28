//
//  CSUtils.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSUtils.h"
#import "SSZipArchive.h"

@interface NSObject(PerformSelector)

- (void)bl_performSelector:(SEL)aSelector withObject:(id _Nullable)anArgument afterDelay:(NSTimeInterval)delay;
- (void)bl_cancelPreviousPerformRequestsWithTarget:(SEL)aSelector withObject:(id _Nullable)anArgument;
- (void)bl_cancelPreviousPerformRequests;

@end

@implementation CSUtils

+ (void)invokeOnMainThread:(void(^)(void))action {
    if (!action) {
        return;
    }
    if ([NSThread isMainThread]) {
        action();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            action();
        });
    }
}

+ (NSString *)trimedString:(NSString *)str {
    if (str.length == 0) {
        return str;
    } else {
        return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

+ (void)showTipAlert:(NSString *)tip inController:(UIViewController *)controller {
    MainThreadBegin
    if (tip.length == 0 || !controller) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:tip preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [controller presentViewController:alert animated:YES completion:nil];
    MainThreadCommit
}

+ (NSString *)demoVersion {
    NSString *shortVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *ver = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
#ifdef DEBUGLOG_ENABLE
    return [NSString stringWithFormat:@"%@(%@)-DEBUG", shortVer, ver];
#else
    return [NSString stringWithFormat:@"%@(%@)", shortVer, ver];
#endif
}

+ (NSString *)libraryPath {
    static NSString *path = nil;
    if (path.length == 0) {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];
    }
    return path;
}

+ (NSString *)docPath {
    static NSString *path = nil;
    if (path.length == 0) {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];
    }
    return path;
}

+ (BOOL)unzip:(NSString *)zipPath to:(NSString *)destDir {
    NSLog(@"unzip %@, to %@", zipPath, destDir);
    
    //return:参数检查
    if (zipPath.length == 0 || destDir == 0) {
        NSAssert(NO, @"arg err, zippath: %@, dest: %@", zipPath, destDir);
        return NO;
    }
    
    //return:zip包路径文件不存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        NSLog(@"zip file not exists");
        NSAssert(NO, @"zip file not exists");
        return NO;
    }

    //return:移除临时解压目录失败
    NSString *targetPath = [destDir stringByDeletingPathExtension];
    NSString *targetPathTemp = [targetPath stringByAppendingString:@"_temp"]; // 解压后的临时目录
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPathTemp]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:targetPathTemp error:&error];
        if (error) {
            NSLog(@"remove exiting temp error=%@", error);
            NSAssert(NO, @"remove exiting temp error=%@", error);
            return NO;
        }
    }
    
    //解压到临时目录
    BOOL success = [SSZipArchive unzipFileAtPath:zipPath toDestination:targetPathTemp];
    
    //return:解压失败
    if (!success) {
        NSLog(@"unzip fail");
        return NO;
    }
    
    //解压成功以后，先把旧目录删掉
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
        //return:已有dest目录移除失败
        if (error) {
            NSLog(@" remove old dest fail error=%@", error);
            NSAssert(NO, @" remove old dest fail error=%@", error);
            return NO;
        }
    }
    
    //把临时目录重命名过去
    [[NSFileManager defaultManager] moveItemAtPath:targetPathTemp toPath:targetPath error:&error];
    if (error) {
        NSLog(@"rename fail error=%@", error);
        NSAssert(NO, @"rename fail error=%@", error);
        return NO;
    }
    
    return YES;
}

+ (UIEdgeInsets)safeEreaInsetsOfView:(UIView *)view {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

+ (void)showAlertWithTitle:(NSString *)title
                       msg:(NSString *)msg
            fromController:(UIViewController *)fromVC
                sureAction:(void (^)(void))sureAction {
    [self showAlertWithTitle:title
                         msg:msg
              fromController:fromVC
                  sureAction:sureAction
                cancelAction:nil];
}

+ (void)showAlertWithTitle:(NSString *)title
                       msg:(NSString *)msg
            fromController:(UIViewController *)fromVC
                sureAction:(void (^)(void))sureAction cancelAction:(void (^)(void))cancelAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelAction) {
            cancelAction();
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureAction) {
            sureAction();
        }
    }]];
    [fromVC presentViewController:alert animated:YES completion:nil];
}

+ (void)addWhiteFlagOnPixelBuffer:(CVPixelBufferRef)ref {
    const int kBytesPerPixel = 4;
    CVPixelBufferLockBaseAddress( ref, 0 );
    int bufferWidth = (int)CVPixelBufferGetWidth( ref );
    int bufferHeight = (int)CVPixelBufferGetHeight( ref );
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow( ref );
    uint8_t *baseAddress = CVPixelBufferGetBaseAddress( ref );
    
    for ( int row = 0; row < bufferHeight; row++ )
    {
        uint8_t *pixel = baseAddress + row * bytesPerRow;
        for ( int column = 0; column < bufferWidth; column++ )
        {
            if ((row < 100) && (column < 100)) {
                pixel[0] = 255; // BGRA, Blue value
                pixel[1] = 255; // Green value
                pixel[2] = 255; // Red value
            }
            pixel += kBytesPerPixel;
        }
    }
    
    CVPixelBufferUnlockBaseAddress( ref, 0 );
}

@end

@implementation CSButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self cs_setupStyle];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self cs_setupStyle];
    }
    return self;
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self cs_setupStyle];
}

- (void)cs_setupStyle {
    self.layer.cornerRadius = 22;
    self.layer.masksToBounds = YES;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor colorWithRed:41.0f / 255 green:149.0f / 255 blue:204.0f / 255 alpha:1];
}

@end
