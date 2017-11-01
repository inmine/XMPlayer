//
//  XMPlayerTableViewCell.h
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMPlayerModel;

@interface XMPlayerTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/** 模型 */
@property (nonatomic,strong) XMPlayerModel *playerModel;

@end
