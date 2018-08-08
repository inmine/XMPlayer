//
//  XMCircleProgressLayer.m
//  XMPlayer
//
//  Created by XM on 2018/8/3.
//  Copyright © 2018年 min. All rights reserved.
//

#import "XMCircleProgressLayer.h"
#import <UIKit/UIKit.h>

@implementation XMCircleProgressLayer

/*3、重载其绘图方法 drawInContext，并在progress属性变化时让其重绘*/
- (void)drawInContext:(CGContextRef)ctx {
    CGFloat radius = self.bounds.size.width / 2;
    CGFloat lineWidth = 10.0;
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius - lineWidth / 2 startAngle:0.f endAngle:M_PI * 2 * self.progress clockwise:YES];
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1.0);//笔颜色
    CGContextSetLineWidth(ctx, 4);//线条宽度
    CGContextAddPath(ctx, path.CGPath);
    CGContextStrokePath(ctx);
}
- (instancetype)initWithLayer:(XMCircleProgressLayer *)layer {
    
    if (self = [super initWithLayer:layer]) {
        self.progress = layer.progress;
    }
    return self;
}
+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

//- (void)dealloc{
//
//    NSLog(@"XMCircleProgressLayer_dealloc");
//}

@end
