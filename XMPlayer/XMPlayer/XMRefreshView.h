//
//  XMRefreshView.h
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

// 项目github地址: https://github.com/inmine/XMPlayer.git

#import <UIKit/UIKit.h>

#define SPEED 5       // 转动速度
#define RING_LINE_WIDTH 2  // 圆环线的宽度

typedef NS_ENUM(NSInteger, RefreshLogo) {
    RefreshLogoNone,   // none
    RefreshLogoCommon, // 默认style
    RefreshLogoAlbum   // 图集style
};

@interface XMRefreshView : UIView

@property(nonatomic, strong)UIColor *lineColor; // 不设置为默认颜色
@property(nonatomic, assign, readonly)BOOL isLoading; // 是否在loading状态
/**
 *  根据是否有logo创建不同的刷新样式
 *
 *  @param frame  刷新view位置
 *  @param isLogo 是否有logo
 *
 */
+ (instancetype)refreshViewWithFrame:(CGRect)frame logoStyle:(RefreshLogo)style;
/**
 *  根据百分比进度去画线，应用在下拉操作
 *
 *  @param percent 百分比
 */
- (void)drawLineWithPercent:(CGFloat)percent;
// 开启动画
- (void)startAnimation;
// 停止动画
- (void)stopAnimation;

@end
