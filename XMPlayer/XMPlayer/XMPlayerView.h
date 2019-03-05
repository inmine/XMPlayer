//
//  XMPlayerView.h
//  XMPlayer
//
//  Created by XM on 2018/8/2.
//  Copyright © 2018年 min. All rights reserved.
//

// 项目github地址: https://github.com/inmine/XMPlayer.git

#import <UIKit/UIKit.h>


/** 商品类型 **/
typedef enum {
    XMPlayerViewWechatShortVideoType = 0,  // 微信短视频
    XMPlayerViewAiqiyiVideoType = 1,  // 爱奇艺视频
    XMPlayerViewTwoSynVideoType = 2,  // 两个同步视频
} XMPlayerViewType;

@interface XMPlayerView : UIView

/**
 * 当前图片
 *
 **/
@property (nonatomic,strong) UIImage *currentImage;

/**
 * 视频URL地址
 *
 * 支持网络视频，本地相册视频
 **/
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) NSURL *subVideoURL;

/**
 * 当前容器的View
 *
 **/
@property (nonatomic, weak) UIView *sourceImagesContainerView;

/**
 * 是否允许下载
 *
 * 默认YES
 **/
@property (nonatomic, assign) BOOL isAllowDownload;

/**
 * 是否允许视频循环播放
 *
 * 默认YES
 **/
@property (nonatomic, assign) BOOL isAllowCyclePlay;

/**
 * 显示
 *
 */
- (void)show;


@property (nonatomic, assign) BOOL isFullScreen; // 是否是全屏 默认：NO


@property (nonatomic, assign) XMPlayerViewType playerViewType;

/**
 设置地址
 */
- (void)settingPlayerItemWithUrl:(NSURL *)playerUrl;


@end
