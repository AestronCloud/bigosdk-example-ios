//
//  CSLiveDebugView.m
//
//  Created by zy on 16/11/30.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "CSLiveDebugView.h"
#import "PAirSandbox.h"
#import "CSUtils.h"

@interface CSLiveDebugView()

@property (nonatomic, strong) UIButton *debugBtn;
@property (nonatomic, strong) UIButton *sandboxBtn;
@property (nonatomic, strong) UITextView *debugText;

@property (strong, nonatomic) dispatch_source_t timerSourceForUpdateDebugText;

@property(nonatomic, weak)UIViewController *vc;

@end

@implementation CSLiveDebugView

- (void)dealloc {
    if (_timerSourceForUpdateDebugText) {
        dispatch_source_cancel(_timerSourceForUpdateDebugText);
        _timerSourceForUpdateDebugText = NULL;
    }
}

- (instancetype)initWithFrame:(CGRect)frame vc:(UIViewController *)vc {
    if (self = [super initWithFrame:frame]) {
        _vc = vc;
        self.backgroundColor = [UIColor clearColor];
        _debugBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _debugBtn.frame = CGRectMake(ScreenWidth - 50 - 10, 150, 50, 22);
        _debugBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _debugBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _debugBtn.layer.cornerRadius = 6;
        [_debugBtn setTitle:@"Debug" forState:UIControlStateNormal];
        [_debugBtn addTarget:self action:@selector(toggleDebugInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_debugBtn];
        
        _sandboxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sandboxBtn.frame = CGRectMake(ScreenWidth - 50 - 10 - 60 - 10, 200, 60, 22);
        _sandboxBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _sandboxBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _sandboxBtn.layer.cornerRadius = 6;
        _sandboxBtn.hidden = YES;
        [_sandboxBtn setTitle:@"Sandbox" forState:UIControlStateNormal];
        [_sandboxBtn addTarget:self action:@selector(toggleSandboxInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sandboxBtn];
        
        _debugText = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_debugBtn.frame) + 2, ScreenWidth, ScreenHeight - CGRectGetMaxY(_debugBtn.frame))];
        _debugText.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _debugText.textColor = [UIColor greenColor];
        _debugText.font = [UIFont systemFontOfSize:12.f];
        _debugText.editable = NO;
        _debugText.userInteractionEnabled = YES;
        _debugText.hidden = YES;
        [self addSubview:_debugText];
        
        if ([self isDebugTextShow]) {
            [self toggleDebugInfo:nil];
        }
    }
    
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view != self) {
        return view;
    }
    
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat originY = [UIApplication sharedApplication].statusBarFrame.size.height + 50;
    self.debugBtn.frame = CGRectMake(ScreenWidth - 50 - 10, originY, 50, 22);
    self.sandboxBtn.frame = CGRectMake(ScreenWidth - 50 - 10 - 70 - 10, originY, 60, 22);
    
    self.debugText.frame = CGRectMake(0, CGRectGetMaxY(self.debugBtn.frame) + 2, ScreenWidth, ScreenHeight - CGRectGetMaxY(_debugBtn.frame));
}

- (void)startUpdateDebugText {
    if ([self.dataSource respondsToSelector:@selector(mssdkDebugInfoForLiveDebugView:)]) {
        _debugText.text = [self.dataSource mssdkDebugInfoForLiveDebugView:self];
    }
    
    [self stopUpdateDebugText];
    [self startTimerForUpdateDebugText];
}

- (void)startTimerForUpdateDebugText {
    NSDate *timerStart = [NSDate date];
    int interval = 1;
    __weak typeof(self) weakSelf = self;
    
    dispatch_source_t timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timerSource, dispatch_walltime(NULL, 0), interval * 1.*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timerSource, ^{
        NSDate *now = [NSDate date];
        NSTimeInterval time = [now timeIntervalSinceDate:timerStart];
        if (ceil(time) > interval) {
            typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            [strongSelf startUpdateDebugText];
        }
    });
    
    dispatch_source_set_cancel_handler(timerSource, ^{
    });
    dispatch_resume(timerSource);
    self.timerSourceForUpdateDebugText = timerSource;
}

- (void)stopUpdateDebugText {
    if (_timerSourceForUpdateDebugText) {
        dispatch_source_cancel(_timerSourceForUpdateDebugText);
        _timerSourceForUpdateDebugText = NULL;
    }
}

- (void)toggleDebugInfo:(id)sender {
    _debugText.hidden = !_debugText.hidden;
    _sandboxBtn.hidden = _debugText.hidden;
    if (_debugText.hidden)  {
        [self stopUpdateDebugText];
    } else {
        [self startUpdateDebugText];
    }
    [self saveDebugTextIsShow:!_debugText.hidden];
}

- (void)toggleSandboxInfo:(id)sender {
    if (self.vc) {
        [[PAirSandbox sharedInstance] presentSanboxInVC:self.vc];
    }
}

- (void)dismiss {
    [self stopUpdateDebugText];
    [self removeFromSuperview];
}

- (void)saveDebugTextIsShow:(BOOL)isShow {
    [[NSUserDefaults standardUserDefaults] setBool:isShow forKey:@"DebugTextIsShow"];
}

- (BOOL)isDebugTextShow {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DebugTextIsShow"];
}

@end
