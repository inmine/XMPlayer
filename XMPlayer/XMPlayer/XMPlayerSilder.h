//
//  XMPlayerSilder.h
//  GH
//
//  Created by Min Ying on 2019/2/21.
//  Copyright © 2019 Min Ying. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapChangeingValue)(float value);  // 正在改变
typedef void(^TapChangedValue)(float value);  // 改变结束

NS_ASSUME_NONNULL_BEGIN

@interface XMPlayerSilder : UIView

@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *bufferView;
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIButton *slipImgView;

@property (nonatomic, assign) float bufferValue;
@property (nonatomic, assign) float trackValue;

@property (nonatomic, copy) TapChangeingValue tapChangeimgValue;
@property (nonatomic, copy) TapChangedValue tapChangedValue;

@end

NS_ASSUME_NONNULL_END
