//
//  XMPlayerConfig.h
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//


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

#define XMRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 图片动画时长
#define XMImageAnimationDuration 0.35f


#define RING_COLOR [UIColor colorWithRed:221 green:0 blue:0 alpha:1.0].CGColor // 默认圆环颜色
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define STROKE_END_RADIAN 180/RADIANS_TO_DEGREES(M_PI)
#define STROKE_PROCESS_RADIAN(angle) angle/RADIANS_TO_DEGREES(M_PI)
static const float DRAW_LINE_RATE = 7.5; // 画线速率
static const float RECURRENT = 4; // 周期
static const float RADIUS_NONE = 15; // 无logo半径
static const float RADIUS_LOGO = 32.5; // logo半径
static const float STROKE_STEP = 170; // 一圈
static const float DRAW_LING_ROTATE = M_PI_4;
