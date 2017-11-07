//
//  XMPlayerTableViewCell.m
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

#import "XMPlayerTableViewCell.h"
#import "XMPlayerModel.h"
#import "XMPlayer.h"

@interface XMPlayerTableViewCell ()

/** 图片按钮 */
@property (nonatomic,strong) UIButton *imgPlayBtn;

@end

@implementation XMPlayerTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"XMPlayerTableViewCell";
    XMPlayerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[XMPlayerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _imgPlayBtn = [[UIButton alloc] init];
        [_imgPlayBtn addTarget:self action:@selector(btnPlayClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_imgPlayBtn];
        
        UILabel *lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = XMRGBColor(230, 230, 230);
        lineLabel.frame = CGRectMake(0, 0, WIDTH, 1);
        [self addSubview:lineLabel];
        
    }
    return self;
}

- (void)layoutSubviews{
    
    _imgPlayBtn.width = self.playerModel.img_w;
    _imgPlayBtn.height = self.playerModel.img_h;
    _imgPlayBtn.x = (WIDTH - _imgPlayBtn.width)/2.0;
    _imgPlayBtn.y = ([self.playerModel cellHeight] - _imgPlayBtn.height)/2.0;
    
    
    UIImageView *playImgView = [[UIImageView alloc] init];
    playImgView.image = [UIImage imageNamed:@"play.png"];
    playImgView.width = playImgView.height = 44;
    playImgView.x = (_imgPlayBtn.width - playImgView.width)/2.0;
    playImgView.y = (_imgPlayBtn.height - playImgView.height)/2.0;
    [_imgPlayBtn addSubview:playImgView];
}

- (void)setPlayerModel:(XMPlayerModel *)playerModel{
    
    _playerModel = playerModel;
    
    NSURL *url = [NSURL URLWithString:playerModel.imgurl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    // 这里最好用SDWebImage框架加载图片
    [_imgPlayBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
}

// 点击播放
- (void)btnPlayClick:(UIButton *)sender{
    
    //    NSLog(@"点击播放");
    XMPlayerManager *playerManager = [[XMPlayerManager alloc] init];
    playerManager.sourceImagesContainerView = (UIView *)sender;  // 当前的View
    playerManager.currentImage = sender.currentImage;  // 当前的图片
//    playerManager.isAllowDownload = NO; // 不允许下载视频
//    playerManager.isAllowCyclePlay = NO;  // 不循环播放
    playerManager.videoURL = [NSURL URLWithString:self.playerModel.videourl];  // 当前的视频URL
    [playerManager show];
}



@end
