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
/** 是否是iphoneX设备 */
#define IS_PhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
/** iphoneX设备导航栏比其他的导航栏高出的距离 */
#define iPhoneX_To_Other_Nav_Height_Difference 24
/** iphoneX设备底部比其他的底部高出的距离 */
#define iPhoneX_To_Other_Bottom_Height_Difference 34
/** iphoneX nav高度 */
#define iPhone_Nav_Height 64
/** iphone Tabbar高度 */
#define iPhone_Tabbar_Height 49
/** iphoneX Nav高度 */
#define iPhoneX_Nav_Height (iPhone_Nav_Height+iPhoneX_To_Other_Nav_Height_Difference)
/** iphoneX Tabbar高度 */
#define iPhoneX_Tabbar_Height (iPhone_Tabbar_Height+iPhoneX_To_Other_Bottom_Height_Difference)
/** Nav高度 */
#define NavFrame (IS_PhoneX?CGRectMake(0, 0, WIDTH, iPhoneX_Nav_Height):CGRectMake(0, 0, WIDTH, iPhone_Nav_Height))

/************************ main ******************************/

/**
 *  图片动画时长
 */
#define XMImageAnimationDuration 0.15f

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


// 竖屏
#define AppDelegateOrientationMaskPortrait [(AppDelegate *)[UIApplication sharedApplication].delegate setOrientationMask:UIInterfaceOrientationMaskPortrait];
// 竖屏，横屏
#define AppDelegateOrientationMaskLandscape [(AppDelegate *)[UIApplication sharedApplication].delegate setOrientationMask:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight];

// 开启侧滑返回
#define PopGestureRecognizerOpen self.navigationController.interactivePopGestureRecognizer.enabled = YES;
// 取消侧滑返回
#define PopGestureRecognizerCancel self.navigationController.interactivePopGestureRecognizer.enabled = NO;


