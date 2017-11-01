//
//  XMImgView.m
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

#import "XMImgView.h"
#import "XMPlayerModel.h"
#import "XMPlayer.h"

@interface XMImgView ()

/** 图片按钮 */
@property (nonatomic,strong) UIButton *imgPlayBtn;

@end

@implementation XMImgView

- (void)setPlayerModel:(XMPlayerModel *)playerModel{
    
    _playerModel = playerModel;

    _imgPlayBtn = [[UIButton alloc] init];
    NSURL *url = [NSURL URLWithString:playerModel.imgurl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    // 这里最好用SDWebImage框架加载图片
    [_imgPlayBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    _imgPlayBtn.width = playerModel.img_w;
    _imgPlayBtn.height = playerModel.img_h;
    _imgPlayBtn.x = (WIDTH - _imgPlayBtn.width)/2.0;
    _imgPlayBtn.y = ([playerModel cellHeight] - _imgPlayBtn.height)/2.0;
    [_imgPlayBtn addTarget:self action:@selector(btnPlayClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_imgPlayBtn];

    UIImageView *playImgView = [[UIImageView alloc] init];
    playImgView.image = [UIImage imageNamed:@"play.png"];
    playImgView.width = playImgView.height = 44;
    playImgView.x = (_imgPlayBtn.width - playImgView.width)/2.0;
    playImgView.y = (_imgPlayBtn.height - playImgView.height)/2.0;
    [_imgPlayBtn addSubview:playImgView];
    
}

// 点击播放
- (void)btnPlayClick:(UIButton *)sender{

//    NSLog(@"点击播放");
    XMPlayerManager *playerManager = [[XMPlayerManager alloc] init];
    playerManager.sourceImagesContainerView = self;
    playerManager.currentImage = sender.currentImage;
    playerManager.videourl = self.playerModel.videourl;
    [playerManager show];

}


@end
