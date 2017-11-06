//
//  UIView+Extension.h
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

// 项目github地址: https://github.com/inmine/XMPlayer.git

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat   bottom;
@property (nonatomic, assign) CGFloat   right;
@property (nonatomic, strong, readonly) UIView *lastSubviewOnX;
@property (nonatomic, strong, readonly) UIView *lastSubviewOnY;

/**
 * @brief 移除此view上的所有子视图
 */
- (void)removeAllSubviews;

@end
