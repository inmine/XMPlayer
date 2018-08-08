//
//  XMCGSize.h
//  MangGuoHeZi
//
//  Created by min on 2017/2/22.
//  Copyright © 2017年 MangGuoHeZi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XMCGSize : NSObject

/** 根据文字内容和字体得到尺寸 */
+ (CGSize)sizeWithText:(NSString *)text andFont:(UIFont *)font;

/** 根据文字内容和字体，最大宽度 得到尺寸 */
+ (CGSize)sizeWithText:(NSString *)text andFont:(UIFont *)font andMaxW:(CGFloat)maxW;

/** 根据文字内容和字体，最大宽度 得到尺寸 带行间距 */
+  (CGSize)getSpaceLabelHeightWithText:(NSString*)text withFont:(UIFont*)font withMaxW:(CGFloat)maxW andLineSpacing:(CGFloat)lineSpacing andWordsSpce:(CGFloat)wordsSpace;

/** 显示缓存大小 */
+ (CGFloat)filePath;

/** 清除缓存 */
+ (void)removeCache;

/** 根据图片返回尺寸 */
+ (CGRect)getImageRect:(UIImage *)tempImage;

/** 获取网络图片尺寸 */
+ (CGSize)getSizeWithImageUrl:(NSString *)imgurl;

// 宽高比
+ (CGFloat)getHeightRatioWithYWidth:(CGFloat)Ywidth YHeight:(CGFloat)Yheight CWidth:(CGFloat)Cwidth;

@end
