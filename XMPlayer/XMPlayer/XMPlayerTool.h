//
//  XMPlayerTool.h
//  edu_app_student_ios_iphone
//
//  Created by Min Ying on 2019/3/1.
//  Copyright © 2019 Min Ying. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMPlayerTool : NSObject

/**
 传入 秒  得到 xx:xx:xx
 
 @param totalTime 总时间（秒）
 @return 返回 xx:xx:xx
 */
+ (NSString *)getMMSSFromSS:(NSString *)totalTime;

/**
 传入 秒  得到  xx分钟xx秒

 @param totalTime <#totalTime description#>
 @return <#return value description#>
 */
//+ (NSString *)getMMSSFromSS:(NSString *)totalTime;


@end

NS_ASSUME_NONNULL_END
