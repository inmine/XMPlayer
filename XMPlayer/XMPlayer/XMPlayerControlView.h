//
//  XMPlayerControlView.h
//  GH
//
//  Created by Min Ying on 2019/2/21.
//  Copyright © 2019 Min Ying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPlayerSilder.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TapChangeingMoveX)(float moveX);  // 正在改变
typedef void(^TapChangedMoveX)(float moveX);  // 改变结束

@interface XMPlayerControlView : UIView


/**
 顶部view
 */
@property (nonatomic, strong) UIView *topView;
/**
 返回
 */
@property (nonatomic, strong) UIButton *closeButton;


/**
 底部view
 */
@property (nonatomic, strong) UIView *bottomView;
/**
 全屏
 */
@property (nonatomic, strong) UIButton *fullScreenButton;
/**
 播放按钮
 */
@property (nonatomic, strong) UIButton *playButton;

/**
 播放时间
 */
@property (nonatomic, strong) UILabel *playTimeLabel;

/**
 总共时间
 */
@property (nonatomic, strong) UILabel *totalTimeLabel;


/**
 进度条
 */
@property (nonatomic, strong) XMPlayerSilder *playerSilder;

// 是否锁屏
//@property (nonatomic, assign) BOOL isLock;

/**
 菜单是否显示
 */
@property (nonatomic, assign) BOOL menuShow;

@property (nonatomic, copy) TapChangeingMoveX tapChangeimgValue;
@property (nonatomic, copy) TapChangedMoveX tapChangedValue;

@end

NS_ASSUME_NONNULL_END
