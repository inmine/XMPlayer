//
//  XMPlayerManager.h
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMPlayerManager : UIView

/** 当前图片 */
@property (nonatomic,strong) UIImage *currentImage;

/** 视频地址 */
@property (nonatomic, copy) NSString *videourl;

/** 当前容器的View */
@property (nonatomic, weak) UIView *sourceImagesContainerView;

/***
 * 显示
 */
- (void)show;


@end
