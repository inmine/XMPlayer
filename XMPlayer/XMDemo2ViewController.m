//
//  XMDemo2ViewController.m
//  XMPlayer
//
//  Created by Min Ying on 2019/3/4.
//  Copyright © 2019 min. All rights reserved.
//

#import "XMDemo2ViewController.h"
#import "XMPlayer.h"
#import "AppDelegate.h"

@interface XMDemo2ViewController ()

@end

@implementation XMDemo2ViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    // 支持 横屏 竖屏
    AppDelegateOrientationMaskLandscape
}


/** 隐藏状态栏 */
- (BOOL)prefersStatusBarHidden{
    
    return YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGFloat palyerW = [UIScreen mainScreen].bounds.size.width;
    XMPlayerView *playerView = [[XMPlayerView alloc] init];
    playerView.frame = CGRectMake(0, 0, palyerW, palyerW / 7 * 4);
    playerView.playerViewType = XMPlayerViewAiqiyiVideoType;
    playerView.videoURL = [NSURL URLWithString:@"https://www.xingyi888.com/xingyi/upload/video/201806/cbc13a1ed0309138ce559dfad8de42b8ca26234c.mp4"];
    [self.view addSubview:playerView];
    [playerView show];
    
    // 监听屏幕旋转方向
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationHandler)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

// 屏幕旋转处理
- (void)orientationHandler {
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        PopGestureRecognizerCancel
    }else if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        PopGestureRecognizerOpen
    }
}


@end
