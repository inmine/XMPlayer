//
//  XMRefreshView.m
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

// 项目github地址: https://github.com/inmine/XMPlayer.git

#import "XMRefreshView.h"
#import "XMPlayerConfig.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define STROKE_END_RADIAN 180/RADIANS_TO_DEGREES(M_PI)
#define STROKE_PROCESS_RADIAN(angle) angle/RADIANS_TO_DEGREES(M_PI)
static const float DRAW_LINE_RATE = 7.5; // 画线速率
static const float RECURRENT = 4; // 周期
static const float RADIUS_NONE = 15; // 无logo半径
static const float RADIUS_LOGO = 32.5; // logo半径
static const float STROKE_STEP = 170; // 一圈
static const float DRAW_LING_ROTATE = M_PI_4;

@interface XMSpinnerRing : CAShapeLayer

- (instancetype)initWithFrame:(CGRect)frame;

+ (instancetype)layerWithFrame:(CGRect)frame;

@end

@implementation XMSpinnerRing

+ (instancetype)layerWithFrame:(CGRect)frame {
    
    return [[self alloc]initWithFrame:frame];
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.lineWidth = RING_LINE_WIDTH;
        self.fillColor = [UIColor clearColor].CGColor;
        self.strokeColor = XMRefreshColor;
        self.lineCap = kCALineCapRound;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ([self init]) {
        
        self.frame = frame;
    }
    return self;
}
@end

@interface XMRefreshView ()

/** 容器 */
@property(nonatomic, strong) CALayer *container;

/** 左圆弧 */
@property(nonatomic, strong) XMSpinnerRing *layerLeft;

/** 右圆弧 */
@property(nonatomic, strong) XMSpinnerRing *layerRight;

/** logo图 */
@property(nonatomic, strong) UIImageView *logoImage;

@property(nonatomic, strong) CABasicAnimation *strokeEndAnimation;

@property(nonatomic, strong) CABasicAnimation *rotateAnimation;

@property(nonatomic, assign) RefreshLogo logoStyle;

@end

@implementation XMRefreshView

+ (instancetype)refreshViewWithFrame:(CGRect)frame logoStyle:(RefreshLogo)style{
    
    XMRefreshView *view = [[self alloc]initWithFrame:frame logoStyle:style];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame logoStyle:(RefreshLogo)style {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.logoStyle = style;
        
        if ([self isHasLogo]) {
            [self createLogo:style];
            [self registerNotification];
        }
        [self changeAnchor:NO];
        [self resetAnimation];
    }
    return self;
}

- (void)startAnimation {
    
    _isLoading = YES;
    [self clearAllAnimation];
    [self checkSeting];
    //    [self changeAnchor:YES];
    [self.layerLeft addAnimation:self.strokeEndAnimation forKey:self.strokeEndAnimation.keyPath];
    [self.layerRight addAnimation:self.strokeEndAnimation forKey:self.strokeEndAnimation.keyPath];
    [self.container addAnimation:self.rotateAnimation forKey:self.rotateAnimation.keyPath];
}

- (void)stopAnimation {
    
    [self clearAllAnimation];
    _isLoading = NO;
}

- (void)drawLineWithPercent:(CGFloat)percent {
    
    [self checkSeting];
    if (percent >= STROKE_PROCESS_RADIAN(160)) {
        percent = STROKE_PROCESS_RADIAN(160);
    }
    [UIView animateWithDuration:0.1 animations:^{
        [self.layerLeft setStrokeEnd:percent];
        [self.layerRight setStrokeEnd:percent];
        self.container.transform = CATransform3DMakeRotation(DRAW_LING_ROTATE * percent, 0, 0, 1);
    }];
}

#pragma mark - privateMethod
- (void)clearAllAnimation {
    
    [self.layer removeAllAnimations];
    [self resetAnimation];
}

- (void)resetAnimation {
    
    [self.layerLeft removeAllAnimations];
    [self.layerRight removeAllAnimations];
    self.container.transform = CATransform3DIdentity;
    [self.container removeAllAnimations];
    [self.layerLeft setStrokeEnd:0.01];
    [self.layerRight setStrokeEnd:0.01];
}

- (void)checkSeting {
    
    if (self.lineColor && self.lineColor.CGColor != self.layerLeft.strokeColor) {
        [self changeLineColor:self.lineColor];
    }
}

- (void)changeAnchor:(BOOL)isEnd {
    
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    //        CGFloat radius = (MIN(frame.size.width, frame.size.height))/2.0f;
    CGFloat radius = [self isHasLogo] ? RADIUS_LOGO : RADIUS_NONE;
    
    //            radius = (MAX(self.logoImage.bounds.size.width, self.logoImage.bounds.size.height))/2.0f + 10;
    NSDictionary *angleResult = [self calculateAngle:30];
    
    if (isEnd) {
        angleResult = [self calculateAngle:-115];
    }
    CGFloat leftStartAngle = [[[angleResult objectForKey:@"left"] objectForKey:@"start"] doubleValue];
    CGFloat leftEndAngle = [[[angleResult objectForKey:@"left"] objectForKey:@"end"] doubleValue];
    CGFloat rightStartAngle = [[[angleResult objectForKey:@"right"] objectForKey:@"start"] doubleValue];
    CGFloat rightEndAngle = [[[angleResult objectForKey:@"right"] objectForKey:@"end"] doubleValue];
    UIBezierPath *lineLeft = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:DEGREES_TO_RADIANS(leftStartAngle) endAngle:DEGREES_TO_RADIANS(leftEndAngle) clockwise:YES];
    
    UIBezierPath *lineRight = [UIBezierPath bezierPathWithArcCenter:center radius:radius  startAngle:DEGREES_TO_RADIANS(rightStartAngle) endAngle:DEGREES_TO_RADIANS(rightEndAngle) clockwise:YES];
    
    self.layerLeft.path = lineLeft.CGPath;
    self.layerRight.path = lineRight.CGPath;
}

- (NSDictionary *)calculateAngle:(CGFloat)leftStartPosition {
    
    CGFloat leftStartAngle = leftStartPosition;
    CGFloat leftEndAngle = leftStartPosition > 0 ? (leftStartPosition + STROKE_STEP) - 360: STROKE_STEP + leftStartPosition;
    CGFloat rightStartAngle = leftEndAngle + 10;
    CGFloat rightEndAngle = leftStartAngle - 10;
    
    return @{@"left" : @{@"start" : @(leftStartAngle), @"end" : @(leftEndAngle)}, @"right" : @{@"start" : @(rightStartAngle), @"end" : @(rightEndAngle)}};
}

- (BOOL)isHasLogo {
    
    return (self.logoStyle == RefreshLogoCommon || self.logoStyle == RefreshLogoAlbum) ? YES : NO;
}

- (void)createLogo:(RefreshLogo)style {
    
    if (style == RefreshLogoCommon) {
        self.logoImage.image = [UIImage imageNamed:@"Applogo_opacity20_light"];
        [self changeLineColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
        self.layerLeft.lineWidth = RING_LINE_WIDTH - 1;
        self.layerRight.lineWidth = RING_LINE_WIDTH - 1;
    }else if (style == RefreshLogoAlbum) {
        self.logoImage.image = [UIImage imageNamed:@"Applogo_opacity20_dark"];
        [self changeLineColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.2]];
        self.layerLeft.lineWidth = RING_LINE_WIDTH - 1;
        self.layerRight.lineWidth = RING_LINE_WIDTH - 1;
    }
    [self.logoImage sizeToFit];
    self.logoImage.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    [self addSubview:self.logoImage];
    
}

- (void)changeLineColor:(UIColor *)color {
    
    self.layerLeft.strokeColor = color.CGColor;
    self.layerRight.strokeColor = color.CGColor;
    
}

/**
 *  注册通知
 */
- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppActivity:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppActivity:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

// 处理后台和前台，让动画更亲和
- (void)handleAppActivity:(NSNotification *)notification {
    
    if (notification.name == UIApplicationDidEnterBackgroundNotification) {
        // 后台
        //记录暂停时间
        CFTimeInterval pauseTime =   [self.container convertTime:CACurrentMediaTime() fromLayer:nil];
        //设置动画速度为0
        self.container.speed = 0;
        //设置动画的偏移时间
        self.container.timeOffset = pauseTime;
        
    }else if (notification.name == UIApplicationWillEnterForegroundNotification) {
        // 前台
        //暂停的时间
        CFTimeInterval pauseTime = self.container.timeOffset;
        //设置动画速度为1
        self.container.speed = 1;
        //重置偏移时间
        self.container.timeOffset = 0;
        //重置开始时间
        self.container.beginTime = 0;
        //计算开始时间
        CFTimeInterval timeSincePause = [self.container convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
        //设置开始时间
        self.container.beginTime = timeSincePause;
    }
}

#pragma mark - lazy
- (CALayer *)container {
    
    if (!_container) {
        _container = [CALayer layer];
        _container.frame = self.bounds;
        [self.layer addSublayer:_container];
    }
    return _container;
}

- (XMSpinnerRing *)layerLeft {
    
    if (!_layerLeft) {
        _layerLeft = [XMSpinnerRing layerWithFrame:self.bounds];
        [self.container addSublayer:_layerLeft];
    }
    return _layerLeft;
}

- (XMSpinnerRing *)layerRight {
    
    if (!_layerRight) {
        _layerRight = [XMSpinnerRing layerWithFrame:self.bounds];
        [self.container addSublayer:_layerRight];
    }
    return _layerRight;
}

- (CABasicAnimation *)strokeEndAnimation {
    
    if (!_strokeEndAnimation) {
        _strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _strokeEndAnimation.fromValue = @(1 - STROKE_END_RADIAN);
        _strokeEndAnimation.toValue = @(STROKE_PROCESS_RADIAN(160));
        _strokeEndAnimation.duration = DRAW_LINE_RATE / SPEED;
        _strokeEndAnimation.repeatCount = HUGE_VAL;
        _strokeEndAnimation.removedOnCompletion = NO;
        _strokeEndAnimation.autoreverses = YES;
    }
    return _strokeEndAnimation;
}

- (CABasicAnimation *)rotateAnimation {
    
    if (!_rotateAnimation) {
        _rotateAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotateAnimation.duration = self.strokeEndAnimation.duration / RECURRENT;
        _rotateAnimation.fromValue = @(DRAW_LING_ROTATE + DEGREES_TO_RADIANS(30));
        _rotateAnimation.toValue = @(DRAW_LING_ROTATE + DEGREES_TO_RADIANS(30) + M_PI);
        _rotateAnimation.repeatCount = HUGE_VAL;
        _rotateAnimation.autoreverses = NO;
        _rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    return _rotateAnimation;
}

- (UIImageView *)logoImage {
    if (!_logoImage) {
        _logoImage = [[UIImageView alloc]init];
    }
    return _logoImage;
}

- (void)dealloc {
    
    // 移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
