//
//  XMPlayerConfig.h
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//


// 项目github地址: https://github.com/inmine/XMPlayer.git

/**************** 宏定义 ***********************/
// 输出
#if DEBUG  // 测试环境
#define XMLog(...)  //NSLog(__VA_ARGS__)
#else
#define XMLog(...)
#endif

/** 自定义宏 */
// 宽高
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

// 颜色
#define XMRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define XMRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
/** 是否是iphoneX设备 */
#define IS_PhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

/************************ main ******************************/

/**
 *  图片动画时长
 */
#define XMImageAnimationDuration 0.35f

/**
 *  图字体
 */
#define XM18Font [UIFont systemFontOfSize:18]

/************************ 文字提示 ******************************/
#define XMNetFialText @"网络连接失败"
#define XMVideoUrlText @"请输入视频地址"
#define XMVideoPlayFialText @"播放失败"
#define XMVideoDownFinish  @"下载完成"

/************************ 菊花 ******************************/

/**
 *  旋转菊花的颜色
 */
#define XMRefreshColor [UIColor whiteColor].CGColor


