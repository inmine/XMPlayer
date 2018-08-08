//
//  XMCGSize.m
//  MangGuoHeZi
//
//  Created by min on 2017/2/22.
//  Copyright © 2017年 MangGuoHeZi. All rights reserved.
//

#import "XMCGSize.h"

@implementation XMCGSize

/** 根据文字内容和字体得到尺寸 */
+ (CGSize)sizeWithText:(NSString *)text andFont:(UIFont *)font{
    
    return [self sizeWithText:text andFont:font andMaxW:MAXFLOAT];
}

/** 根据文字内容和字体，最大宽度 得到尺寸 */
+ (CGSize)sizeWithText:(NSString *)text andFont:(UIFont *)font andMaxW:(CGFloat)maxW{
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

/** 根据文字内容和字体，最大宽度 得到尺寸 带行间距 */
+  (CGSize)getSpaceLabelHeightWithText:(NSString*)text withFont:(UIFont*)font withMaxW:(CGFloat)maxW andLineSpacing:(CGFloat)lineSpacing andWordsSpce:(CGFloat)wordsSpace{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = lineSpacing;  // 行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@(wordsSpace)
                          };  // NSKernAttributeName 字间距
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size;
}


/** 显示缓存大小 */
+ (CGFloat)filePath{
    
    NSString *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject];
    CGFloat f = [self filePathfolderSizeAtPath:cachPath];
    
    return f;
}

//1:首先我们计算一下 单个文件的大小
+ ( long long )fileSizeAtPath:( NSString *)filePath{
    
    NSFileManager * manager = [ NSFileManager defaultManager ];
    
    if ([manager fileExistsAtPath :filePath]){
        
        return [[manager attributesOfItemAtPath :filePath error : nil ] fileSize ];
    }
    
    return 0 ;
}

//2:遍历文件夹获得文件夹大小，返回多少 M（提示：你可以在工程界设置（)m）
+ ( float )filePathfolderSizeAtPath:(NSString *)folderPath{
    
    NSFileManager * manager = [ NSFileManager defaultManager ];
    
    if (![manager fileExistsAtPath :folderPath]) return 0 ;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator ];
    
    NSString * fileName;
    
    long long folderSize = 0 ;
    
    while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
        
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
        
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        
    }
    
    return folderSize/( 1024.0 * 1024.0 );
}

/** 清除缓存 */
+ (void)removeCache
{
    //===============清除缓存==============
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    //    NSLog(@"文件数 ：%d",[files count]);
    for (NSString *p in files)
    {
        NSError *error;
        NSString *path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}

/** 根据图片返回尺寸 */
+ (CGRect)getImageRect:(UIImage *)tempImage {
    CGRect rect;
    
    rect = CGRectMake(0, 0, tempImage.size.width, tempImage.size.height);
    return rect;
}

/** 获取网络图片尺寸 */
+ (CGSize)getSizeWithImageUrl:(NSString *)imgurl{
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgurl]];
    UIImage *image = [UIImage imageWithData:data];
    
    return CGSizeMake(image.size.width, image.size.height);
}

// 宽高比
+ (CGFloat)getHeightRatioWithYWidth:(CGFloat)Ywidth YHeight:(CGFloat)Yheight CWidth:(CGFloat)Cwidth{
    
    return (Cwidth*Yheight)/(Ywidth*1.0);
}

@end
