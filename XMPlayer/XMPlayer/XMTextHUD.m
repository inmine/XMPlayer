//
//  XMTextHUD.m
//  BeiHuaSuan
//
//  Created by Min Ying on 2018/6/11.
//  Copyright © 2018年 Min Ying. All rights reserved.
//

#import "XMTextHUD.h"
#import "UIView+Extension.h"
#import "XMCGSize.h"
#import "XMPlayerConfig.h"

@implementation XMTextHUD
static UIView *bgView;

/* 文字提示 **/
+ (void)xm_showText:(NSString *)text{
    
    if (!text.length) return;
    
    [bgView removeFromSuperview];
    bgView = [[UIView alloc] init];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    bgView.layer.cornerRadius = 6;
    bgView.layer.masksToBounds = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    
    CGSize titleSize = [XMCGSize sizeWithText:text andFont:[UIFont systemFontOfSize:14] andMaxW:(WIDTH - 2*40)];
    
    UILabel *alertLabel = [[UILabel alloc] init];
    alertLabel.frame = CGRectMake(16, 10, titleSize.width, titleSize.height);
    alertLabel.text = text;
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.font = [UIFont systemFontOfSize:14];
    alertLabel.numberOfLines = 0;
    alertLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [bgView addSubview:alertLabel];
    
    CGFloat w = alertLabel.width+2*alertLabel.x;
    CGFloat h = alertLabel.height+2*alertLabel.y;
    bgView.frame = CGRectMake((WIDTH-w)/2.0, (HEIGHT-h)/2.0, w, h);
    
    //延迟1秒钟释放掉该label
    [self performSelector:@selector(removeAlertLabel:) withObject:alertLabel afterDelay:1.0];
}

#pragma mark - 清除当初的提示框
+ (void)removeAlertLabel:(UILabel *)sender {
    
    UILabel *alertLabel = (UILabel *)sender;
    [UIView animateWithDuration:0.5 animations:^{
        alertLabel.alpha = 0;
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [alertLabel removeFromSuperview];
        [bgView removeFromSuperview];
    }];
}

@end
