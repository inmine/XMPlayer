//
//  XMDemo1ViewController.m
//  XMPlayer
//
//  Created by Min Ying on 2019/3/4.
//  Copyright © 2019 min. All rights reserved.
//

#import "XMDemo1ViewController.h"
#import "XMPlayer.h"

@interface XMDemo1ViewController ()

@end

@implementation XMDemo1ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    UIButton *playerBtn = [[UIButton alloc] init];
    playerBtn.backgroundColor = [UIColor redColor];
    playerBtn.frame = CGRectMake((self.view.bounds.size.width-200)/2.0, 100, 200, 122.54);
    [self.view addSubview:playerBtn];
    
    NSURL *url = [NSURL URLWithString:@"http://wx3.sinaimg.cn/mw690/e067b31fgy1fl2n55uh8dj20zg0jy1kx.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    // 这里最好用SDWebImage框架加载图片
    [playerBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    [playerBtn addTarget:self action:@selector(btnPlayClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *playImgView = [[UIImageView alloc] init];
    playImgView.image = [UIImage imageNamed:@"play.png"];
    playImgView.width = playImgView.height = 44;
    playImgView.x = (playerBtn.width - playImgView.width)/2.0;
    playImgView.y = (playerBtn.height - playImgView.height)/2.0;
    [playerBtn addSubview:playImgView];
}

// 点击播放
- (void)btnPlayClick:(UIButton *)sender{
    
    //    NSLog(@"点击播放");
    XMPlayerView *playerView = [[XMPlayerView alloc] init];
    playerView.sourceImagesContainerView = (UIView *)sender;  // 当前的View
    playerView.currentImage = sender.currentImage;  // 当前的图片
    //    playerView.isAllowDownload = NO; // 不允许下载视频
    //    playerView.isAllowCyclePlay = NO;  // 不循环播放
    playerView.videoURL = [NSURL URLWithString:@"http://www.scsaide.com/uploadfiles/video/20170928/1506570773879538.mp4"];  // 当前的视频URL
    playerView.playerViewType = XMPlayerViewWechatShortVideoType;
    [playerView show];
}



@end
