//
//  ViewController.m
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//

#import "ViewController.h"
#import "XMDemo1ViewController.h"
#import "XMDemo2ViewController.h"
#import "XMDemo3ViewController.h"
#import "XMPlayer.h"
#import "AppDelegate.h"

@interface listItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, assign) Class viewControllClass;
- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle viewControllClass:(Class)class;

@end

@implementation listItem

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle viewControllClass:(Class)class
{
    self = [super init];
    if (self) {
        self.title = title;
        self.subTitle = subTitle;
        self.viewControllClass = class;
    }
    return self;
}

@end

static NSString *const xm_cellIdentifier = @"cell_identifier";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSArray *listArray;

@end

@implementation ViewController

- (NSArray *)listArray{
    if (!_listArray) {
        _listArray = @[[[listItem alloc] initWithTitle:@"Demo1" subTitle:@"短视频播放（模仿微信朋友圈）" viewControllClass:[XMDemo1ViewController class]],
                       [[listItem alloc] initWithTitle:@"Demo2" subTitle:@"单视频播放器（模仿爱奇艺）" viewControllClass:[XMDemo2ViewController class]],
                       [[listItem alloc] initWithTitle:@"Demo3" subTitle:@"两个视频同步播放播放器（界面可切换）" viewControllClass:[XMDemo3ViewController class]],
                       ];
    }
    return _listArray;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    // 竖屏
    AppDelegateOrientationMaskPortrait
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"XMPlayer";
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = self.view.frame;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.contentInset = UIEdgeInsetsMake(NavFrame.size.height, 0, 0, 0);
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:xm_cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:xm_cellIdentifier];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    listItem *item = self.listArray[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.subTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    listItem *item = self.listArray[indexPath.row];
    UIViewController *viewController = [[item.viewControllClass alloc] init];
    viewController.title = item.title;
    viewController.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

    
@end
