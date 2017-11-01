//
//  XMPlayerTableViewCell.m
//  XMPlayer
//
//  Created by min on 2017/10/31.
//  Copyright © 2017年 min. All rights reserved.
//

#import "XMPlayerTableViewCell.h"
#import "XMImgView.h"
#import "XMPlayerModel.h"
#import "XMPlayer.h"

@interface XMPlayerTableViewCell ()

/** 图片View */
@property (nonatomic,strong) XMImgView *imgView;

@end

@implementation XMPlayerTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"XMPlayerTableViewCell";
    XMPlayerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[XMPlayerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _imgView = [[XMImgView alloc] init];
        _imgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_imgView];
        
        UILabel *lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = XMRGBColor(230, 230, 230);
        lineLabel.frame = CGRectMake(0, 0, WIDTH, 1);
        [self addSubview:lineLabel];
        
    }
    return self;
}

- (void)setPlayerModel:(XMPlayerModel *)playerModel{
    
    _playerModel = playerModel;
    
    _imgView.playerModel = playerModel;
    
    _imgView.frame = CGRectMake(0, 0,WIDTH, playerModel.img_h + 20);
    
}

@end
