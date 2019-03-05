//
//  XMPlayerTool.m
//  edu_app_student_ios_iphone
//
//  Created by Min Ying on 2019/3/1.
//  Copyright © 2019 Min Ying. All rights reserved.
//

#import "XMPlayerTool.h"

@implementation XMPlayerTool

/**
 传入 秒  得到 xx:xx:xx

 @param totalTime 总时间（秒）
 @return 返回 xx:xx:xx
 */
+ (NSString *)getMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
}

////传入 秒  得到  xx分钟xx秒
//+ (NSString *)getMMSSFromSS:(NSString *)totalTime{
//    
//    NSInteger seconds = [totalTime integerValue];
//    
//    //format of minute
//    NSString *str_minute = [NSString stringWithFormat:@"%ld",seconds/60];
//    //format of second
//    NSString *str_second = [NSString stringWithFormat:@"%ld",seconds%60];
//    //format of time
//    NSString *format_time = [NSString stringWithFormat:@"%@分钟%@秒",str_minute,str_second];
//    
//    NSLog(@"format_time : %@",format_time);
//    
//    return format_time;
//    
//}


@end
