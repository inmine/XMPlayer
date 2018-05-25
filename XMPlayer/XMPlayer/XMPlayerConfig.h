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
#define XMLog(...)  NSLog(__VA_ARGS__)
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


/************************ main ******************************/

/**
 *  图片动画时长
 */
#define XMImageAnimationDuration 0.35f

/**
 *  图字体
 */
#define XM18Font [UIFont systemFontOfSize:18]


/************************ 菊花 ******************************/

/**
 *  旋转菊花的颜色
 */
#define XMRefreshColor [UIColor redColor].CGColor




/************************ 进度条 ******************************/

/**
 *  进度背景颜色
 */
#define XMProgressBGColor XMRGBAColor(0,0,255,0.7)

/**
 *  进度背景颜色
 */
#define XMProgressInsideBGColor XMRGBAColor(0,255,0,0.7)

/**
 *  波浪进度颜色1
 */
#define XMWavesColor1 XMRGBAColor(216,59,49,0.7)

/**
 *  波浪进度颜色2
 */
#define XMWavesColor2 XMRGBAColor(255,0,0,0.7)

