//
//  CSInfoAlert.m
//  YYMeet
//
//  Created by chenlei1 on 12-12-1.
//
//  alert控件，用于显示相关alert信息,1.5s后自动消失，不包含按钮

#import "CSInfoAlert.h"
#import <objc/runtime.h>

#define ALERT_MAX_WIDTH          250.0f      // 文本信息的最大宽度，超过宽度折行
#define ALERT_BORDER_TOPBOTTOM   8.0f        // 上下边界的间距
#define ALERT_BORDER_LEFTRIGHT   15.0f        // 左右边界的间距
#define ALERT_FONT 16 //文字大小
@interface CSInfoAlert()

@property (nonatomic, strong)NSString *text;
@property (nonatomic, assign)CGSize fontSize;
@property (nonatomic, assign) CGFloat duration; //持续时间
@property (nonatomic, strong) UIColor *bgColor; //背景颜色

@end

@implementation CSInfoAlert

- (id)initWithInfoSize:(CGSize)size info:(NSString*)info
{
    CGRect rect = CGRectMake(0, 0, size.width + 2 * ALERT_BORDER_LEFTRIGHT, size.height + 2 * ALERT_BORDER_TOPBOTTOM);
    self = [super initWithFrame:rect];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _fontSize = size;
        _text  = [[NSString alloc] initWithString:info?:@""];
        _duration = 2;
        _bgColor = [UIColor blackColor];
    }
    return self;
}

// 绘制圆角矩形背景
- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect
{
    CGFloat fw, fh;
    CGFloat ovalWidth  = 5.0f;
    CGFloat ovalHeight = 5.0f;
    
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect),
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 背景0.8透明度
    CGContextSetAlpha(context, 0.8);
    [self addRoundedRectToPath:context rect:rect];
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillPath(context);
    
    // 文字1.0透明度
    CGContextSetAlpha(context, 1.0);
    //CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGRect rt = CGRectMake(ALERT_BORDER_LEFTRIGHT, ALERT_BORDER_TOPBOTTOM, self.fontSize.width, self.fontSize.height);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:ALERT_FONT],
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self.text drawInRect:rt withAttributes:attributes];
}

// 从上层视图移除并释放
- (void)remove{
    [self removeFromSuperview];
}

// 渐变消失
- (void)fadeAway
{
    [UIView beginAnimations:@"alertFadeaway" context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(remove)];
    self.alpha = 0.0f;
    [UIView commitAnimations];
}

// 出现
- (void)appear
{
    [UIView beginAnimations:@"alertAppear" context:nil];
    [UIView setAnimationDuration:0.3f];
    self.alpha = 1.0;
    [UIView commitAnimations];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fadeAway];
    });
}

- (void)dismiss {
    [self fadeAway];
}

+ (instancetype)showInfo:(NSString *)info
                  inView:(UIView *)view
                vertical:(CGFloat)height
{
    if (!view || !(info && info.length)) return nil ;
    height = height < 0 ? 0 : height > 1 ? 1 : height;
    UIFont *font = [UIFont systemFontOfSize:ALERT_FONT];
    CGSize size  = [info boundingRectWithSize:CGSizeMake(ALERT_MAX_WIDTH, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil].size;
    size = CGSizeMake(size.width, ceil(size.height));   // 浮点数表示问题
    CSInfoAlert* alert = [[CSInfoAlert alloc] initWithInfoSize:size info:info];
    
    alert.center = CGPointMake(view.frame.size.width/2, view.frame.size.height*height);
    alert.alpha = 0;
    [view addSubview:alert];
    //最新的弹窗显示在最上面
    [view bringSubviewToFront:alert];
    [alert appear];
    
    return alert;
}

#pragma mark - 对外接口

+ (instancetype)showInfo:(NSString*)info {
    return [CSInfoAlert showInfo:info
                          inView:[UIApplication sharedApplication].keyWindow
                        vertical:0.5];
}

+ (instancetype)showInfo:(NSString *)info vertical:(CGFloat)height {
    return [CSInfoAlert showInfo:info
                          inView:[UIApplication sharedApplication].keyWindow
                        vertical:height];
}

@end
