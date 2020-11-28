//
//  CSVideoChatMiniWindow.m
//  video-call-1v1
//
//  Created by 林小程 on 2020/9/22.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSVideoChatMiniWindow.h"

@interface CSVideoChatMiniWindow ()

@property(nonatomic, assign)CGPoint touchBeginPoint;

@end

@implementation CSVideoChatMiniWindow

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touchBeginPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    //计算偏移值
    CGFloat offSetX = currentPoint.x - self.touchBeginPoint.x;
    CGFloat offSetY = currentPoint.y - self.touchBeginPoint.y;
    
    if ([self.delegate respondsToSelector:@selector(miniWindow:preferChangeFrameWithOffsetX:OffsetY:)]) {
        [self.delegate miniWindow:self preferChangeFrameWithOffsetX:offSetX OffsetY:offSetY];
    }
}

@end
