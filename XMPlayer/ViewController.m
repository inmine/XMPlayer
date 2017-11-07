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
#import "MJExtension.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 数据数据 */
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"XM短视频播放";
    
    // 添加数据
    [self addData];
    
    // 添加UI
    [self addUI];
}

#pragma mark - 添加数据
- (void)addData{
    
    NSArray *array = @[@{
                           @"img_w":@(200),
                           @"img_h":@(111.25),
                           @"imgurl":@"http://www.xingyi888.com/xingyi/upload/201709/ca5b813bb30310f10c811a325856cc1f50714b69.jpg",
                           @"videourl":@"http://www.xingyi888.com/xingyi/upload/video/201709/4249dc6bcd0c3ebdeb3f800c1b436115dd899d8b.mp4"
                         },
                       @{
                           @"img_w":@(200),
                           @"img_h":@(122.54),
                           @"imgurl":@"https://wx3.sinaimg.cn/mw690/e067b31fgy1fl2n55uh8dj20zg0jy1kx.jpg",
                           @"videourl":@"http://www.scsaide.com/uploadfiles/video/20170928/1506570773879538.mp4"
                           },
                       @{
                           @"img_w":@(200),
                           @"img_h":@(112),
                           @"imgurl":@"http://120.25.226.186:32812/resources/images/minion_08.png",
                           @"videourl":@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"
                           },
                       ];
    
    self.dataArray = [XMPlayerModel mj_objectArrayWithKeyValuesArray:array];
    
}

#pragma mark - 添加UI
- (void)addUI{
    
    // tableView
    UITableView *tableView = [[UITableView alloc] init];
    // 去掉UITableView中cell不够多余部分的分割线
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.backgroundColor = [UIColor lightGrayColor];
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
