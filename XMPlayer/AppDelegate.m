//
//  AppDelegate.m
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "XMPlayer.h"
#import "OttoFPSButton.h"
#import "LXDAppFluecyMonitor.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // UIScrollView兼容ios11
    if(@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    // 1.创建窗口
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 2.直接进入主页面
    ViewController *mainVC = [[ViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = navVC;
    
    // 3.显视窗口
    [self.window makeKeyAndVisible];
    
    // FPS
    CGRect frame = CGRectMake(WIDTH-80, 300, 80, 30);
    UIColor *btnBGColor = [UIColor colorWithWhite:0.000 alpha:0.700];
    OttoFPSButton *btn = [OttoFPSButton setTouchWithFrame:frame titleFont:[UIFont systemFontOfSize:15] backgroundColor:btnBGColor backgroundImage:nil];
    [self.window addSubview:btn];
    
    // 卡顿监测
    [[LXDAppFluecyMonitor sharedMonitor] startMonitoring];
    
    // 兼容ios11
    if(@available(iOS 11.0, *)){
        // UIScrollView兼容ios11
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        // UITableView兼容ios11
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    return YES;
}

// window中支持的屏幕显示方向
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return _orientationMask;
}



@end
