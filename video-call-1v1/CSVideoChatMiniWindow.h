//
//  CSVideoChatMiniWindow.h
//  video-call-1v1
//
//  Created by 林小程 on 2020/9/22.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSVideoChatMiniWindow;

NS_ASSUME_NONNULL_BEGIN

@protocol CSVideoChatMiniWindowProtocol <NSObject>

- (void)miniWindow:(CSVideoChatMiniWindow *)miniWindow preferChangeFrameWithOffsetX:(CGFloat)offsetX OffsetY:(CGFloat)offsetY;

@end

@interface CSVideoChatMiniWindow : UIControl

@property(nonatomic, assign)id<CSVideoChatMiniWindowProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
