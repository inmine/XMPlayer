//
//  XMProgress.m
//  XMPlayer
//
//  Created by min on 2017/11/6.
//  Copyright © 2017年 min. All rights reserved.
//

// 项目github地址: https://github.com/inmine/XMPlayer.git

#import "XMProgress.h"
#import "XMWaves.h"
#import "XMPlayerConfig.h"

@interface XMProgress ()
{
    XMWaves *_wave;
    UILabel *_textLabel;
}

@end

@implementation XMProgress

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // 添加UI
        [self addUI];
    }
    return self;
}

#pragma mark - 添加UI
- (void)addUI
{
    self.backgroundColor = XMProgressBGColor;
    self.layer.cornerRadius = self.bounds.size.width/2.0f;
    self.layer.masksToBounds = true;
    
    CGFloat waveWidth = self.bounds.size.width * 0.8f;
    _wave = [[XMWaves alloc] initWithFrame:CGRectMake(0, 0, waveWidth, waveWidth)];
    _wave.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.width/2.0f);
    _wave.alpha = 0.7;
    [self addSubview:_wave];
    
    _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:10];
    [self addSubview:_textLabel];
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _wave.progress = progress;
    _textLabel.text = [NSString stringWithFormat:@"%.0f%%",progress*100];
}

-(void)dealloc
{
    [_wave stop];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end
