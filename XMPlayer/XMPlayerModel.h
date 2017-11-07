//
//  XMPlayerModel.h
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XMPlayerModel : NSObject

/** 图片宽度 */
@property (nonatomic, assign) CGFloat img_w;

/** 图片高度 */
@property (nonatomic, assign) CGFloat img_h;

/** 视频图片地址 */
@property (nonatomic, copy) NSString *imgurl;

/** 视频地址 */
@property (nonatomic, copy) NSString *videourl;

/** 字典转模型 */
+ (instancetype)statusWithDict:(NSDictionary *)dict;

/** cell高度 */
- (CGFloat)cellHeight;

@end
