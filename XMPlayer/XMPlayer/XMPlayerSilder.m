//
//  XMPlayerSilder.m
//  GH
//
//  Created by Min Ying on 2019/2/21.
//  Copyright © 2019 Min Ying. All rights reserved.
//

#import "XMPlayerSilder.h"
#import "UIView+Extension.h"

#define SilderH 3
#define SlipW 12
#define ProSenderW 40

@implementation XMPlayerSilder

- (UIView *)tapView{
    
    if (_tapView == nil) {
        _tapView = [[UIView alloc] init];
    }
    return _tapView;
}

- (UIView *)baseView
{
    if (_baseView == nil) {
        _baseView = [[UIView alloc] init];
        _baseView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    return _baseView;
}

- (UIView *)bufferView
{
    if (_bufferView == nil) {
        _bufferView = [[UIView alloc] init];
        _bufferView.backgroundColor = [UIColor greenColor];
    }
    return _bufferView;
}

- (UIView *)trackView
{
    if (_trackView == nil) {
        _trackView = [[UIView alloc] init];
        _trackView.backgroundColor = [UIColor orangeColor];
    }
    return _trackView;
}

- (UIButton *)slipImgView{
    
    if (_slipImgView == nil) {
        _slipImgView = [[UIButton alloc] init];
//        _slipImgView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        _slipImgView.contentMode = UIViewContentModeScaleAspectFit;
        [_slipImgView setImage:[UIImage imageNamed:@"btn_player_slider_thumb"] forState:UIControlStateNormal];
        _slipImgView.userInteractionEnabled = YES;
        [_slipImgView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slipImgPanGRAction:)]];
    }
    return _slipImgView;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        [self addSubview:self.tapView];
        [self.tapView addSubview:self.baseView];
        [self.tapView addSubview:self.bufferView];
        [self.tapView addSubview:self.trackView];
        [self addSubview:self.slipImgView];
        
        self.tapView.frame = CGRectMake(0, (self.frame.size.height - SlipW) / 2, self.frame.size.width, SlipW);
        self.baseView.frame = CGRectMake(0, (SlipW - SilderH) / 2, self.frame.size.width, SilderH);
        self.bufferView.frame = CGRectMake(0, (SlipW - SilderH) / 2, 0, SilderH);
        self.trackView.frame = CGRectMake(0, (SlipW - SilderH) / 2, 0, SilderH);
        self.slipImgView.frame = CGRectMake(0, (self.frame.size.height - SlipW) * 0.5, SlipW, SlipW);
    }
    return self;
}

- (void)slipImgPanGRAction:(UIPanGestureRecognizer *)panGR{
    
    // 获取偏移量
    CGFloat moveX = [panGR translationInView:self].x;
    // 重置偏移量，避免下次获取到的是原基础的增量
    [panGR setTranslation:CGPointMake(0, 0) inView:self];
    // 计算当前中心值
    CGFloat centerX = CGRectGetMaxX(self.slipImgView.frame) - ProSenderW * 0.5 + moveX;
    
    // 防止瞬间大偏移量滑动影响显示效果
    if (centerX < 0) centerX = 0;
    if (centerX > self.bounds.size.width) centerX = self.bounds.size.width;
    
    self.trackValue = centerX / self.frame.size.width;
    if (panGR.state == UIGestureRecognizerStateChanged) {
        
        if (self.tapChangeimgValue) {
            self.tapChangeimgValue((CGRectGetMaxX(self.slipImgView.frame) - ProSenderW * 0.5) / self.frame.size.width);
        }
    }
    
    if (panGR.state == UIGestureRecognizerStateEnded) {
        if (self.tapChangedValue) {
            self.tapChangedValue((CGRectGetMaxX(self.slipImgView.frame) - ProSenderW * 0.5) / self.frame.size.width);
        }
    }
}

- (void)setBufferValue:(float)bufferValue
{
    _bufferValue = bufferValue;
    bufferValue = isnan(bufferValue)?0:bufferValue;
    self.bufferView.frame = CGRectMake(0, (SlipW - SilderH) / 2, self.frame.size.width * (bufferValue / 1.0), CGRectGetHeight(self.bufferView.frame));
}

- (void)setTrackValue:(float)trackValue
{
    _trackValue = trackValue;
    
    CGFloat finishW = self.frame.size.width * trackValue;
    finishW = isnan(finishW)?0:finishW;
    
    self.tapView.frame = CGRectMake(0, (self.frame.size.height - SlipW) / 2, self.frame.size.width, SlipW);
    self.baseView.frame = CGRectMake(0, (SlipW - SilderH) / 2, self.frame.size.width, SilderH);
    self.trackView.frame = CGRectMake(0, (SlipW - SilderH) / 2, finishW, CGRectGetHeight(self.trackView.frame));
    self.slipImgView.frame = CGRectMake(finishW - ProSenderW * 0.5, 0, ProSenderW, self.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 旋转屏幕，根据比例重新布局
    [self setTrackValue:self.trackValue];
    [self setBufferValue:self.bufferValue];
    
}

@end
