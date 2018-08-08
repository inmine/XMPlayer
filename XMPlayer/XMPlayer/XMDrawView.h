//
//  XMDrawView.h
//  XMPlayer
//
//  Created by XM on 2018/8/3.
//  Copyright © 2018年 min. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMCircleProgressLayer;

@interface XMDrawView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UILabel * progressLabel;
@property (strong,nonatomic) XMCircleProgressLayer *circleProgressLayer;

@end
