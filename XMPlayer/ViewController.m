//
//  ViewController.m
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//

#import "ViewController.h"
#import "XMPlayerTableViewCell.h"
#import "XMPlayerModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 数据数据 */
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation ViewController

- (NSArray *)dataArray{
    
    if (_dataArray == nil) {
        
        NSArray *dictArray = @[
                           @{
                               @"img_w":@(200),
                               @"img_h":@(122.54),
                               @"imgurl":@"https://wx3.sinaimg.cn/mw690/e067b31fgy1fl2n55uh8dj20zg0jy1kx.jpg",
                               @"videourl":@"http://www.scsaide.com/uploadfiles/video/20170928/1506570773879538.mp4"
                               }
                           ];
        
        // 字典数组 -> 模型数组
        NSMutableArray *statusArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            XMPlayerModel *status = [XMPlayerModel statusWithDict:dict];
            [statusArray addObject:status];
        }
        
        _dataArray = statusArray;
    }
    return _dataArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"XM短视频播放";
    
    // 添加UI
    [self addUI];
}

#pragma mark - 添加UI
- (void)addUI{
    
    // tableView
    UITableView *tableView = [[UITableView alloc] init];
    // 去掉UITableView中cell不够多余部分的分割线
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.backgroundColor = [UIColor grayColor];
    // 隐藏cell分割线
    tableView.separatorStyle = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.frame = self.view.bounds;
    [self.view addSubview:tableView];
    [tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMPlayerModel *model = self.dataArray[indexPath.row];
    return [model cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMPlayerTableViewCell *cell = [XMPlayerTableViewCell cellWithTableView:tableView cellForRowAtIndexPath:indexPath];
    XMPlayerModel *model = self.dataArray[indexPath.row];
    cell.playerModel = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
