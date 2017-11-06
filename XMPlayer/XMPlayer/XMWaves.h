//
//  XMWaves.h
//  XMPlayer
//
//  Created by min on 2017/11/6.
//  Copyright © 2017年 min. All rights reserved.
//

// 项目github地址: https://github.com/inmine/XMPlayer.git

#import <UIKit/UIKit.h>

@interface XMWaves : UIView

/**
 * 设置进度 0~1
 */
@property (assign,nonatomic) CGFloat progress;


- (void)stop;

@end
