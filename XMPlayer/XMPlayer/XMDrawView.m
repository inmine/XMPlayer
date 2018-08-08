//
//  XMDrawView.m
//  XMPlayer
//
//  Created by XM on 2018/8/3.
//  Copyright © 2018年 min. All rights reserved.
//

#import "XMDrawView.h"
#import "XMCircleProgressLayer.h"
#import "UIView+Extension.h"

@interface XMDrawView ()<CAAnimationDelegate>

@end

@implementation XMDrawView

/*重载drawRect的方法*/
- (void)drawRect:(CGRect)rect {
    
}

//4、将layer添加到自定义的view中，并在progress属性变化时通知layer
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.circleProgressLayer = [XMCircleProgressLayer layer];
        self.circleProgressLayer.frame = CGRectMake(8, 8, self.width-2*8, self.height-2*8);
        //像素大小比例
        self.circleProgressLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:self.circleProgressLayer];
        
        self.progressLabel = [[UILabel alloc]initWithFrame:self.bounds];
        self.progressLabel.textColor = [UIColor whiteColor];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.font = [UIFont systemFontOfSize:14.0];
        self.progressLabel.text = @"0%";
        [self addSubview:self.progressLabel];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    
    CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"progress"];
    ani.duration = 5.0 * fabs(progress - _progress);
    ani.toValue = @(progress);
    ani.removedOnCompletion = YES;
    ani.fillMode = kCAFillModeForwards;
    ani.delegate = self;
    [self.circleProgressLayer addAnimation:ani forKey:@"progressAni"];
    
    self.progressLabel.text = [NSString stringWithFormat:@"%0.f%%", progress * 100];
    _progress = progress;
    //    self.circleProgressLayer.progress = progress;
    //    [self.circleProgressLayer setNeedsDisplay];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.circleProgressLayer.progress = self.progress;
}


//- (void)dealloc{
//    
//    NSLog(@"XMDrawView_dealloc");
//}

@end
