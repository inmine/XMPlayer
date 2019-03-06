//
//  XMPlayerView.m
//  XMPlayer
//
//  Created by XM on 2018/8/2.
//  Copyright © 2018年 min. All rights reserved.
//

#import "XMPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "XMPlayerConfig.h"
#import "UIView+Extension.h"
#import "XMRefreshView.h"
#import "XMDrawView.h"
#import "XMTextHUD.h"
#import "XMPlayerControlView.h"
#import "XMPlayerTool.h"
#import "XMBaseTools.h"

@interface XMPlayerView ()<NSURLSessionDelegate>

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *avPlayer;

@property (nonatomic, strong) AVPlayerItem *playerItem2;
@property (nonatomic, strong) AVPlayerLayer *playerLayer2;
@property (nonatomic, strong) AVPlayer *avPlayer2;

/** 背景view */
@property (nonatomic,weak) UIView *BGView;
/** 加载时旋转菊花 */
@property(nonatomic, weak) XMRefreshView *refreshView;
/** 临时图片 */
@property (nonatomic,weak) UIImageView *tempView;
/** 是否已经显示 */
@property (nonatomic, assign) BOOL hasShowedFistView;
/** 蒙版 */
@property (nonatomic,weak) UIButton *mengbanView;
/** 保存View */
@property (nonatomic,weak) UIView *saveView;
/** 下载 */
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
/** 下载进度 */
@property (nonatomic, strong) XMDrawView *drawView;
/** 后台session单例  */
@property (nonatomic, strong) NSURLSession *backgroundSession;
/** window */
@property (nonatomic, weak) UIWindow *window;

@property (nonatomic, strong) XMPlayerControlView *controlView;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) id timeObserver2;
@property (nonatomic, assign) CGRect shrinkRect;  // 视频窗口初始化大小
@property (nonatomic, assign) float currentPlayTime; // 当前播放时间
@property (nonatomic,assign) int minBufferTime;

@property (nonatomic,assign) int playBufferTime1;
@property (nonatomic,assign) int playBufferTime2;
/**
 是否正在被拖动
 */
@property (nonatomic,assign) BOOL isDraging;
@property (nonatomic, weak) UIButton *touchMinWindowVideoBtn;
@property (nonatomic, assign) CGRect minVideoWideoRect;

/**
 是否是手动暂停
 */
@property (nonatomic, assign) BOOL isManualStop;
@property (nonatomic, assign) BOOL isInitPlay;  // 是否是初始化播放


@end

@implementation XMPlayerView

#pragma mark - 懒加载
/**
 * 创建一个后台session单例
 *
 @return backgroundSess
 */
- (NSURLSession *)backgroundSession {
    
    if (!_backgroundSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _backgroundSession;
}

/**
 * 蒙版
 *
 @return mengbanView
 */
- (UIButton *)mengbanView{
    
    if (_mengbanView == nil) {
        
        // 蒙版
        UIButton *mengbanView = [[UIButton alloc] init];
        mengbanView.frame = self.bounds;
        mengbanView.hidden = YES;
        mengbanView.backgroundColor = [UIColor blackColor];
        mengbanView.alpha = 0;
        [mengbanView addTarget:self action:@selector(mengbanViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self.BGView addSubview:mengbanView];
        _mengbanView = mengbanView;
        
        // 保存View
        UIView *saveView = [[UIView alloc] init];
        saveView.backgroundColor = XMRGBColor(160, 160, 160);
        [self.BGView addSubview:saveView];
        _saveView = saveView;
        
        if (IS_PhoneX) { // iphone X
            saveView.frame = CGRectMake(0, HEIGHT, WIDTH , 106 + 36);
        }else{
            saveView.frame = CGRectMake(0, HEIGHT, WIDTH , 106);
        }
        
        // 保存Btn
        UIButton *saveBtn = [[UIButton alloc] init];
        saveBtn.frame = CGRectMake(0, 0, WIDTH, 50);
        saveBtn.backgroundColor = [UIColor whiteColor];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        saveBtn.titleLabel.font = XM18Font;
        [saveBtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
        [saveView addSubview:saveBtn];
        
        // 取消Btn
        UIButton *canleBtn = [[UIButton alloc] init];
        canleBtn.frame = CGRectMake(0, 56, WIDTH, 50);
        canleBtn.backgroundColor = [UIColor whiteColor];
        [canleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [canleBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        canleBtn.titleLabel.font = XM18Font;
        [canleBtn addTarget:self action:@selector(mengbanViewClick) forControlEvents:UIControlEventTouchUpInside];
        [saveView addSubview:canleBtn];
    }
    
    return  _mengbanView;
}

/**
 点击蒙版
 */
- (void)mengbanViewClick{
    
    [UIView animateWithDuration:0.1 animations:^{
        self.mengbanView.alpha = 0;
        _saveView.y = HEIGHT;
    } completion:^(BOOL finished) {
        _saveView.hidden = YES;
        self.mengbanView.hidden = YES;
    }];
}

/**
 初始化
 @return self
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        // 默认配置
        [self defaultConfiguration];
    }
    return self;
}

// 拖动界面
- (void)dragTheInterfaceWithMoveX:(CGFloat)moveX withIsDraging:(BOOL)isDraging{
    
    CMTime duration = self.playerItem.duration;
    // 目前以屏幕宽度的一半为基准（self.width/2.0）
    CGFloat baseWidth = self.width/2.0;
    // 当前时间占用的长度
    CGFloat currentTimeLenght =  (self.currentPlayTime/([[NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(duration)] intValue]*1.0)) * baseWidth;
    // 总占用比例
    CGFloat value = (currentTimeLenght + moveX) / baseWidth;
    
    if (value>=1) {
        value = 1;
    }else if (value <= 0){
        value = 0;
        self.isInitPlay = YES;
    }
    
    if (isDraging) {
        [self videoProgressWithChangeimgValue:value];
    }else{
        [self videoProgressWithchangedValue:value];
    }
}

// 正在滑动
- (void)videoProgressWithChangeimgValue:(CGFloat)value{
    
    self.isDraging = YES;
    CMTime duration = self.playerItem.duration;
    self.controlView.playTimeLabel.text = [XMPlayerTool getMMSSFromSS:[NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(duration) * value]];
    self.controlView.playerSilder.trackValue = value;
}

// 滑动结束
- (void)videoProgressWithchangedValue:(CGFloat)value{
    
    CMTime duration = self.playerItem.duration;
    // 播放结束重复播放
    [self.avPlayer seekToTime:CMTimeMake(CMTimeGetSeconds(duration)*value, 1)];
    if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
        [self.avPlayer2 seekToTime:CMTimeMake(CMTimeGetSeconds(duration)*value, 1)];
    }
    self.isDraging = NO;;
}

/**
 默认配置
 */
- (void)defaultConfiguration{
    
    // 默认允许下载视频
    self.isAllowDownload = YES;
    // 默认允许循环播放
    self.isAllowCyclePlay = YES;
}

/**
 显示
 */
- (void)show{
    
    if (self.playerViewType == XMPlayerViewWechatShortVideoType) {
        
        if (!self.currentImage) {
            NSLog(@"currentImage为null");
            return;
        }
        
        if (!self.videoURL) {
            NSLog(@"%@",XMVideoUrlText);
            return;
        }
        
        if (!self.sourceImagesContainerView) {
            NSLog(@"sourceImagesContainerView为null");
            return;
        }
        
        // 加载背景
        [self loadBgView];
        
        // 添加视频播放器
        [self loadWechatShortVideoTypeUI];
        
    }else if (self.playerViewType == XMPlayerViewAiqiyiVideoType){
        
        // 加载初始界面
        [self loadAiqiyiVideoTypeUI];
        
    }else if (self.playerViewType == XMPlayerViewTwoSynVideoType){
        
        // 加载初始界面
        [self loadTwoSynVideoTypeUI];
    }
    
    // 菊花
    CGFloat w = 40;
    CGFloat x = (self.BGView.width - w)/2.0;
    CGFloat y = (self.BGView.height - w)/2.0;
    XMRefreshView *refreshView = [XMRefreshView refreshViewWithFrame:CGRectMake(x, y, w, w) logoStyle:RefreshLogoNone];
    [self.BGView addSubview:refreshView];
    [refreshView startAnimation];
    self.refreshView = refreshView;
}

/**
 加载背景
 */
- (void)loadBgView{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.window = window;
    
    // 设置背景View
    UIView *BGView = [[UIView alloc] init];
    BGView.backgroundColor = [UIColor blackColor];
    BGView.center = self.window.center;
    BGView.bounds = self.window.bounds;
    self.center = CGPointMake(BGView.bounds.size.width * 0.5, BGView.bounds.size.height * 0.5);
    self.bounds = CGRectMake(0, 0, BGView.bounds.size.width, BGView.bounds.size.height);
    [BGView addSubview:self];
    self.BGView = BGView;
    
    // 添加到窗口上
    [self.window addSubview:BGView];
    //隐藏状态栏
    self.window.windowLevel = UIWindowLevelStatusBar + 10.0f;
}

/**
 添加视频播放器
 */
- (void)loadWechatShortVideoTypeUI{
    
    //1 创建AVPlayerItem
//    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.videoURL];
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    //2.把AVPlayerItem放在AVPlayer上
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    //3 再把AVPlayer放到 AVPlayerLayer上
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    self.playerLayer.frame = self.BGView.bounds;
    self.playerLayer.delegate = self;
    
    //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
    [self.BGView.layer addSublayer:self.playerLayer];
    
    
    // 添加观察
    [self loadObserver:self.playerItem];
    // 加载通知
    [self loadNotification:self.playerItem];
    
    // 添加手势
    [self loadGesture];
}

// 加载初始界面
- (void)loadAiqiyiVideoTypeUI{
    
    // 设置背景View
    UIView *BGView = [[UIView alloc] init];
    BGView.backgroundColor = [UIColor blackColor];
    BGView.center = self.window.center;
    BGView.bounds = self.window.bounds;
    BGView.frame = self.frame;
    [self addSubview:BGView];
    self.BGView = BGView;
    
    //1 创建AVPlayerItem
    //    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.videoURL];
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    //2.把AVPlayerItem放在AVPlayer上
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    //3 再把AVPlayer放到 AVPlayerLayer上
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    self.playerLayer.frame = self.BGView.bounds;
    //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
    [self.BGView.layer addSublayer:self.playerLayer];
    
    [self loadObserver:self.playerItem];
    // 加载通知
    [self loadNotification:self.playerItem];
    // PlayerControlView事件
    [self playerControlViewEvent];
}

// 加载初始界面
- (void)loadTwoSynVideoTypeUI{
    
    // 设置背景View
    UIView *BGView = [[UIView alloc] init];
    BGView.backgroundColor = [UIColor blackColor];
    BGView.center = self.window.center;
    BGView.bounds = self.window.bounds;
    BGView.frame = self.frame;
    [self addSubview:BGView];
    self.BGView = BGView;
    
    self.isInitPlay = YES;
    
    //1 创建AVPlayerItem
    //    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.videoURL];
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    //2.把AVPlayerItem放在AVPlayer上
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    //3 再把AVPlayer放到 AVPlayerLayer上
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    self.playerLayer.frame = self.BGView.bounds;
    //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
    [self.BGView.layer addSublayer:self.playerLayer];
    
    [self loadObserver:self.playerItem];
    // 加载通知
    [self loadNotification:self.playerItem];
    
    self.minVideoWideoRect = CGRectMake(0, 30, 100, 80);
    //1 创建AVPlayerItem
//    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mp4"];
//    self.playerItem2 = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:moviePath]];
    self.playerItem2 = [AVPlayerItem playerItemWithURL:self.subVideoURL];
    //2.把AVPlayerItem放在AVPlayer上
    self.avPlayer2 = [[AVPlayer alloc] initWithPlayerItem:self.playerItem2];
    //3 再把AVPlayer放到 AVPlayerLayer上
    self.playerLayer2 = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer2];
    self.playerLayer2.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    self.playerLayer2.frame = self.minVideoWideoRect;
    self.avPlayer2.volume = 0;
    //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
    [self.BGView.layer addSublayer:self.playerLayer2];
    [self.BGView.layer insertSublayer:self.playerLayer2 above:self.playerLayer];
    
    [self loadObserver:self.playerItem2];
    // 加载通知
    [self loadNotification:self.playerItem2];
    
    // PlayerControlView事件
    [self playerControlViewEvent];
    
    // 点击手势
    UIButton *touchMinWindowVideoBtn = [[UIButton alloc] init];
    touchMinWindowVideoBtn.frame = self.playerLayer2.frame;
    touchMinWindowVideoBtn.backgroundColor = [UIColor clearColor];
//    touchMinWindowVideoBtn.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    [touchMinWindowVideoBtn addTarget:self action:@selector(touchMinWindowVideoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:touchMinWindowVideoBtn];
    self.touchMinWindowVideoBtn = touchMinWindowVideoBtn;
    
    UIPanGestureRecognizer *movePan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(processgestureReconizer:)];
    [touchMinWindowVideoBtn addGestureRecognizer:movePan];
}

// 点击小窗口视频切换界面
- (void)touchMinWindowVideoBtnClick:(UIButton *)sender{
    
    CGRect tempRect = self.playerLayer2.frame;
    self.playerLayer2.frame = self.playerLayer.frame;
    self.playerLayer.frame = tempRect;
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        [self.BGView.layer insertSublayer:self.playerLayer above:self.playerLayer2];
    }else{
        [self.BGView.layer insertSublayer:self.playerLayer2 above:self.playerLayer];
    }
}

// PlayerControlView事件
- (void)playerControlViewEvent{
    
    self.controlView = [[XMPlayerControlView alloc] initWithFrame:self.bounds];
    [self addSubview:self.controlView];
    
    // 事件处理
    // 返回
    [self.controlView.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    // 全屏
    [self.controlView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    // 播放和暂停
    [self.controlView.playButton addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    // 手势滑动界面
    // 滑动界面中
    self.controlView.tapChangeimgValue = ^(float moveX) {
        [weakSelf dragTheInterfaceWithMoveX:moveX withIsDraging:YES];
    };
    // 滑动界面结束
    self.controlView.tapChangedValue = ^(float moveX) {
        [weakSelf dragTheInterfaceWithMoveX:moveX withIsDraging:NO];
    };
    // 手势拖动进度条
    // 拖动进度条中
    self.controlView.playerSilder.tapChangeimgValue = ^(float value) {
        [weakSelf videoProgressWithChangeimgValue:value];
    };
    // 拖动进度条结束
    self.controlView.playerSilder.tapChangedValue = ^(float value) {
        [weakSelf videoProgressWithchangedValue:value];
    };
}

/**  添加观察 */
- (void)loadObserver:(AVPlayerItem *)playerItem{
    
    /**以上是基本的播放界面，但是没有前进后退**/
    //观察是否播放，KVO进行观察，观察playerItem.status
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
    
    //监控时间进度(根据API提示，如果要监控时间进度，这个对象引用计数器要+1，retain)
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        // 获取 item 当前播放秒
        weakSelf.currentPlayTime = (double)weakSelf.avPlayer.currentItem.currentTime.value / weakSelf.avPlayer.currentItem.currentTime.timescale;
//        NSLog(@"当前时间:%f",weakSelf.currentPlayTime);
        [weakSelf updateVideoSlider:weakSelf.currentPlayTime];
    }];
    
    if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
        self.timeObserver2 = [self.avPlayer2 addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 获取 item 当前播放秒
            float currentPlayTime = (double)weakSelf.avPlayer2.currentItem.currentTime.value/ weakSelf.avPlayer2.currentItem.currentTime.timescale;
            [weakSelf updateVideoSlider2:currentPlayTime];
        }];
    }
}

/*
 * 执行观察者方法
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        
        if (status == AVPlayerStatusReadyToPlay) {
            
            XMLog(@"AVPlayerStatusReadyToPlay");
            
            //status 点进去看 有三种状态
            
//            CGFloat duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
            //            XMLog(@"准备好播放了，总时间：%.2f", duration);//还可以获得播放的进度，这里可以给播放进度条赋值了
//            if (self.minBufferTime>=10) {
//                self.controlView.playButton.selected = YES;
//                [self play];
//            }
            
            if (self.playerViewType == XMPlayerViewWechatShortVideoType) {
                [self play];
            }else if (self.playerViewType == XMPlayerViewAiqiyiVideoType){
                self.controlView.playButton.selected = NO;
                [self play];
            }
            
        } else if (status == AVPlayerStatusFailed) {
            XMLog(@"AVPlayerStatusFailed");
            // 播放失败
            [self playFailed];
        } else {
            
            XMLog(@"AVPlayerStatusUnknown");
            // 播放失败
            [self playFailed];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        
        NSArray *array = playerItem.loadedTimeRanges;
        // 缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        [self updateVideoBufferProgress:totalBuffer];
        
        self.minBufferTime = [[NSString stringWithFormat:@"%.0f", totalBuffer] intValue];
        
        if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
            
            if (playerItem == self.playerItem) {
                            XMLog(@"当前缓存时间视频1:%@",[NSString stringWithFormat:@"%.0f", totalBuffer]);
                self.playBufferTime1 = [[NSString stringWithFormat:@"%.0f", totalBuffer] intValue];
            }else if (playerItem == self.playerItem2){
                
                            XMLog(@"当前缓存时间视频2:%@",[NSString stringWithFormat:@"%.0f", totalBuffer]);
                self.playBufferTime2 = [[NSString stringWithFormat:@"%.0f", totalBuffer] intValue];
            }
            
            self.minBufferTime = (self.playBufferTime1 <= self.playBufferTime2)?self.playBufferTime1:self.playBufferTime2;
            
            XMLog(@"当前缓存时间视频最小值:%d",self.minBufferTime);
            
            if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
                
                if (self.isInitPlay) {
                    if (self.minBufferTime>=10) {
                        [self play];
                        self.isInitPlay = NO;
                    }else{
                        [self pause];
                    }
                }
            }
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        
        XMLog(@"缓冲不足暂停了");
        [self pause];
        [self startAnimation];
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        XMLog(@"缓冲达到可播放程度了");
//        // 由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        if (!self.isManualStop) { // 不是手动暂停
            if (self.playerItem.playbackLikelyToKeepUp) {  // 缓冲达到可播放程度
                
                if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
                    if (!self.isInitPlay) {
                        // 结束刷新
                        [self endAnimation];
                        // 播放
                        [self play];
                    }
                }else{
                    // 播放
                    [self play];
                }
            }
        }
    } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        
        XMLog(@"缓冲区满了");
    }
}

/**
 播放状态通知
 */
- (void)loadNotification:(AVPlayerItem *)playerItem{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed) name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:playerItem];
    
    // 监听屏幕旋转方向
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationHandler)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

// 屏幕旋转处理
- (void)orientationHandler {
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) { // 横屏
            
            _isFullScreen = YES;
            self.controlView.fullScreenButton.selected = YES;
            [self deviceLandscape];
            
        }else { // 竖屏
            //            _isFullScreen = NO;
        }
    }else if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) { // 竖屏
            _isFullScreen = NO;
            self.controlView.fullScreenButton.selected = NO;
            [self devicePortrait];
        }else{
            //            _isFullScreen = YES;
        }
    }
    self.refreshView.center = self.BGView.center;
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        [self fullScreenButtonClick];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!_isFullScreen) {
        _shrinkRect = frame;
    }
}

// 横屏
- (void)deviceLandscape{
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self twoVideoRotatingScreenLayoutSubviewsWithIsFullScreen:YES];
}

// 竖屏
- (void)devicePortrait{
    
    self.frame = _shrinkRect;
    [self twoVideoRotatingScreenLayoutSubviewsWithIsFullScreen:NO];
}

/**
 播放结束
 */
- (void)playbackFinished{
    
    if (self.isAllowCyclePlay) {
        // 播放结束重复播放
        [self.avPlayer seekToTime:CMTimeMake(0, 1)];
        [self.avPlayer play];
        
    }else{
        // 退出播放
        [self tapAction];
    }
    
    [self.playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
    self.controlView.playButton.selected = NO;
    [self pause];
}

/**
 播放失败
 */
- (void)playFailed{
    
    [XMTextHUD xm_showText:XMVideoPlayFialText];
    
    [self.avPlayer pause];
    
    // 结束刷新
    [self endAnimation];
}

/**
 添加手势
 */
- (void)loadGesture{
    
    //创建手势对象
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    //配置属性
    tap.numberOfTapsRequired =1;
    //    //轻拍手指个数
    //    tap.numberOfTouchesRequired =1;
    //讲手势添加到指定的视图上
    [self addGestureRecognizer:tap];
    
    // 允许下载
    if (self.isAllowDownload) {
        // 长按
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processgestureReconizer:)];
        longPress.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longPress];
    }
}

/**
 单击
 */
- (void)tapAction{
    
    UIView *sourceView = [self.sourceImagesContainerView.subviews firstObject];
    
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    self.window.windowLevel = UIWindowLevelNormal;//显示状态栏
    
    self.drawView = nil;
    // 移除播放器
    [self removePlayer];
    
    [UIView animateWithDuration:XMImageAnimationDuration animations:^{

        self.tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        self.BGView.backgroundColor = [UIColor clearColor];
        self.alpha = 0;

    } completion:^(BOOL finished) {
    
        // 移除
        self.refreshView.hidden = YES;
        self.tempView.hidden = YES;
        self.BGView.hidden = YES;
        self.refreshView = nil;
        self.tempView = nil;
        self.drawView = nil;
        self.hidden = YES;
        _playerItem = nil;
        self.playerLayer = nil;
        
        [self.backgroundSession invalidateAndCancel];
        self.backgroundSession = nil;
        // 停止下载
        [self.downloadTask suspend];
        self.downloadTask = nil;
        
        [self removeAllSubviews];
        [self.drawView removeFromSuperview];
        [self.saveView removeFromSuperview];
        [self.mengbanView removeFromSuperview];
        [self.BGView removeFromSuperview];
        self.saveView = nil;
        self.drawView = nil;
        self.BGView = nil;
        self.window = nil;
    }];
}

#pragma mark - 菊花状态
// 开始旋转
- (void)startAnimation{
    
    XMLog(@"开始旋转");
    [self.refreshView startAnimation];
    self.refreshView.hidden = NO;
}

// 结束旋转
- (void)endAnimation{
    
    XMLog(@"结束旋转");
    [self.refreshView stopAnimation];
    self.refreshView.hidden = YES;
}

#pragma mark 长按手势
- (void)processgestureReconizer:(UIGestureRecognizer *)gesture {
    
    if (self.playerViewType == XMPlayerViewWechatShortVideoType) {
        
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] &&
            gesture.state == UIGestureRecognizerStateBegan) { // 长按
            if (!self.drawView) { // 没有下载可以下载
                _saveView.hidden = NO;
                self.mengbanView.hidden = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    self.mengbanView.alpha = 0.5;
                    if (IS_PhoneX) { // iphone X
                        _saveView.y = HEIGHT - (106 + 36);
                    }else{
                        _saveView.y = HEIGHT - 106;
                    }
                }];
            }
        }
    }else if (self.playerViewType == XMPlayerViewTwoSynVideoType){
        
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) { // 拖拽
            
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gesture;
            static CGPoint startCenter;
            if (pan.state == UIGestureRecognizerStateBegan) {
                startCenter = self.touchMinWindowVideoBtn.center;
            }else if (pan.state == UIGestureRecognizerStateChanged) {
                // 此处必须从self.view中获取translation，因为translation和view的transform属性挂钩，若transform改变了则translation也会变
                CGPoint translation = [pan translationInView:self.touchMinWindowVideoBtn];
                XMLog(@"translation:%@",NSStringFromCGPoint(translation));
                CGFloat centerX = startCenter.x + translation.x;
                CGFloat centerY = startCenter.y + translation.y;
                CGFloat centerXMin = self.touchMinWindowVideoBtn.width/2.0;
                CGFloat centerXMax = self.width - self.touchMinWindowVideoBtn.width/2.0;
                CGFloat centerYMin = self.touchMinWindowVideoBtn.height/2.0;
                CGFloat centerYMax = self.height - self.touchMinWindowVideoBtn.height/2.0;
                if (centerX <= centerXMin) {
                    centerX = centerXMin;
                }
                if (centerX >= centerXMax) {
                    centerX = centerXMax;
                }
                if (centerY <= centerYMin) {
                    centerY = centerYMin;
                }
                if (centerY >= centerYMax) {
                    centerY = centerYMax;
                }
                
                self.touchMinWindowVideoBtn.center = CGPointMake(centerX, centerY);
                if (self.touchMinWindowVideoBtn.selected) {  // 切换后
                    self.playerLayer.frame = self.touchMinWindowVideoBtn.frame;
                }else{ // 切换前
                    
                    self.playerLayer2.frame = self.touchMinWindowVideoBtn.frame;
                }
            }else if (pan.state == UIGestureRecognizerStateEnded) {
                startCenter = CGPointZero;
            }
        }
    }
}

#pragma mark - 下载视频
/**
 保存视频
 */
- (void)saveVideo{
    
    //    XMLog(@"保存");
    [self mengbanViewClick];
    
    XMDrawView *drawView = [[XMDrawView alloc] initWithFrame:CGRectMake((WIDTH-80)/2.0, (HEIGHT-80)/2.0, 80, 80)];
    drawView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    drawView.progress = 0;
    [self.BGView addSubview:drawView];
    self.drawView = drawView;
    
    // 下载视频
    [self downLoadVideo];
}

/**
 * 下载视频
 */
- (void)downLoadVideo{
    
    self.downloadTask = [self.backgroundSession downloadTaskWithURL:self.videoURL];
    [self.downloadTask resume];
    
}

#pragma mark NSSessionUrlDelegate
/**
 下载进度
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //下载进度
    CGFloat progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        //进行UI操作  设置进度条
        XMLog(@"进度：%f",progress);
        self.drawView.progress = progress;
        // 下载完成
        if (progress==1) {
            [self progressOverAndChangeViewContents];
        }
    });
}

/**
 下载完成 保存到本地相册
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    //1.拿到cache文件夹的路径
    NSString *cache=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    //2,拿到cache文件夹和文件名
    NSString *file=[cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
    //3，保存视频到相册
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)) {
        //保存相册核心代码
        UISaveVideoAtPathToSavedPhotosAlbum(file, self, nil, nil);
    }
}

/**
 控件本身的代理方法  更新控件样子
 */
- (void)progressOverAndChangeViewContents {
    
    XMLog(@"下载完成");
    [XMTextHUD xm_showText:XMVideoDownFinish];
    
    [self.backgroundSession finishTasksAndInvalidate];
    self.drawView.progress = 0;
    self.drawView.hidden = YES;
    self.drawView = nil;
}

/** 移除播放器 */
- (void)removePlayer{
    
    if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
        [self.avPlayer2 pause];
        [self.avPlayer2 setRate:0];
        [self.avPlayer2.currentItem removeObserver:self forKeyPath:@"status" context:nil];
        [self.avPlayer2.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
        [self.avPlayer2.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
        [self.avPlayer2.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
        [self.avPlayer2.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:nil];
        [self.avPlayer2 replaceCurrentItemWithPlayerItem:nil];
        [self.avPlayer2 removeTimeObserver:self.timeObserver2];
        self.avPlayer2 = nil;
    }
    
    [self.avPlayer pause];
    [self.avPlayer setRate:0];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:nil];
    [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    // 播放完成
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if (self.playerLayer != XMPlayerViewWechatShortVideoType) {
        [self.avPlayer removeTimeObserver:self.timeObserver];
    }
    // 移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.avPlayer = nil;
//    self.BGView = nil;
}

/**
 布局
 */
- (void)layoutSubviews{
    
    if (self.playerViewType == XMPlayerViewWechatShortVideoType) {
        if (!_hasShowedFistView) {
            [self showFirstImage];
        }
    }else if (self.playerViewType == XMPlayerViewAiqiyiVideoType || self.playerViewType == XMPlayerViewTwoSynVideoType){
        self.controlView.frame = self.bounds;
    }
}

/**
 显示图片
 */
- (void)showFirstImage{
    
    UIView *sourceView = [self.sourceImagesContainerView.subviews firstObject];
    
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    //    XMLog(@"%@",NSStringFromCGRect(rect));
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.frame = rect;
    tempView.image = self.currentImage;
    [self addSubview:tempView];
    self.tempView = tempView;
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat placeImageSizeW = tempView.image.size.width;
    CGFloat placeImageSizeH = tempView.image.size.height;
    CGRect targetTemp;
    
    CGFloat placeHolderH = (placeImageSizeH * WIDTH)/placeImageSizeW;
    if (placeHolderH <= HEIGHT) {
        targetTemp = CGRectMake(0, (HEIGHT - placeHolderH) * 0.5 , WIDTH, placeHolderH);
    } else {//图片高度>屏幕高度
        targetTemp = CGRectMake(0, 0, WIDTH, placeHolderH);
    }
    
    [UIView animateWithDuration:XMImageAnimationDuration animations:^{
        //将点击的临时imageview动画放大到和目标imageview一样大
        tempView.frame = targetTemp;
    } completion:^(BOOL finished) {
        //动画完成后，删除临时imageview，让目标imageview显示
        _hasShowedFistView = YES;
    }];
}

// 更新进度条时间
- (void)updateVideoSlider:(float)currentPlayTime
{
    CMTime duration = _playerItem.duration;
    self.controlView.totalTimeLabel.text = [XMPlayerTool getMMSSFromSS:[NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(duration)]];
    
    if (!self.isDraging){
        self.controlView.playTimeLabel.text = [XMPlayerTool getMMSSFromSS:[NSString stringWithFormat:@"%.0f", currentPlayTime]];
        self.controlView.playerSilder.trackValue = currentPlayTime / CMTimeGetSeconds(duration);
    }
}
- (void)updateVideoSlider2:(float)currentPlayTime{
    
    CMTime duration = self.playerItem2.duration;
//    XMLog(@"前播放时间视频2:%@",[NSString stringWithFormat:@"%.0f", currentPlayTime]);
}

// 更新缓冲进度
- (void)updateVideoBufferProgress:(NSTimeInterval)buffer
{
    CMTime duration = _playerItem.duration;
    self.controlView.playerSilder.bufferValue = buffer / CMTimeGetSeconds(duration);
}

// 返回
- (void)closeButtonClick{
    
    if (_isFullScreen) { // 全屏
        
        self.controlView.fullScreenButton.selected = NO;
        [XMBaseTools interfaceOrientation:UIInterfaceOrientationPortrait];
        self.frame = _shrinkRect;
        self.refreshView.center = self.BGView.center;
        if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
            // 视频旋转屏幕更新布局
            [self twoVideoRotatingScreenLayoutSubviewsWithIsFullScreen:self.controlView.fullScreenButton.selected];
        }
    }else{ //
        
    }
}

// 事件处理
- (void)fullScreenButtonClick {
    
    self.controlView.fullScreenButton.selected = !self.controlView.fullScreenButton.isSelected;
    if (self.controlView.fullScreenButton.selected) {
        [XMBaseTools interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }else{
        [XMBaseTools interfaceOrientation:UIInterfaceOrientationPortrait];
        self.frame = _shrinkRect;
    }
    
    if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
        // 视频旋转屏幕更新布局
        [self twoVideoRotatingScreenLayoutSubviewsWithIsFullScreen:self.controlView.fullScreenButton.selected];
    }
    self.refreshView.center = self.BGView.center;
}

// 双视频旋转屏幕更新布局
- (void)twoVideoRotatingScreenLayoutSubviewsWithIsFullScreen:(BOOL)isFullScreen{
    
    self.BGView.frame = self.frame;
    CGFloat ratio = 1.6;
    if (self.touchMinWindowVideoBtn.selected) {  // 切换后
        if (isFullScreen) {
            self.playerLayer.frame = CGRectMake(self.minVideoWideoRect.origin.x, self.minVideoWideoRect.origin.y, self.minVideoWideoRect.size.width*ratio, self.minVideoWideoRect.size.height*ratio);
        }else{
            self.playerLayer.frame = self.minVideoWideoRect;
        }
        self.playerLayer2.frame = self.BGView.frame;
        self.touchMinWindowVideoBtn.frame = self.playerLayer.frame;
        [self.BGView.layer insertSublayer:self.playerLayer above:self.playerLayer2];
    }else{ // 初始化样子
        self.playerLayer.frame = self.BGView.frame;
        if (isFullScreen) {
            self.playerLayer2.frame = CGRectMake(self.minVideoWideoRect.origin.x, self.minVideoWideoRect.origin.y, self.minVideoWideoRect.size.width*ratio, self.minVideoWideoRect.size.height*ratio);
        }else{
            self.playerLayer2.frame = self.minVideoWideoRect;
        }
        self.touchMinWindowVideoBtn.frame = self.playerLayer2.frame;
        [self.BGView.layer insertSublayer:self.playerLayer2 above:self.playerLayer];
    }
}

//  即将进入后台的处理
- (void)applicationWillEnterForeground {
    
    [self play];
}

//  即将返回前台的处理
- (void)applicationWillResignActive {
    [self pause];
}

// 点击播放
- (void)playClick:(UIButton *)sender{
    
    sender.selected = !sender.isSelected;
    self.isManualStop = sender.selected;
    if (sender.selected) {
        [self pause];
    }else{
        [self play];
    }
}

// 播放
- (void)play{
    
    if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
        [self.avPlayer2 play];
    }
    [self.avPlayer play];
    // 结束刷新
    [self endAnimation];
}

// 暂停
- (void)pause
{
    if (self.playerViewType == XMPlayerViewTwoSynVideoType) {
        [self.avPlayer2 pause];
    }
    [self.avPlayer pause];
}

// 释放
- (void)dealloc{
    
    XMLog(@"XMPlayer_dealloc");
    [self removePlayer];
    // 注销通知
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.avPlayer = nil;
    self.avPlayer2 = nil;
}


@end
