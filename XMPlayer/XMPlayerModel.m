//
//  XMPlayerModel.m
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

#import "XMPlayerModel.h"

@implementation XMPlayerModel

- (CGFloat)cellHeight{
    
    return _img_h + 20;
}

+ (instancetype)statusWithDict:(NSDictionary *)dict
{
    XMPlayerModel *status = [[self alloc] init];
    [status setValuesForKeysWithDictionary:dict];
    return status;
}

@end
