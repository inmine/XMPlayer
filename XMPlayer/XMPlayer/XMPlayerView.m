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

@interface XMPlayerView ()<NSURLSessionDelegate>{
    
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_avplayerLayer;
}

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
    [self loadVideoPlayer];
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
- (void)loadVideoPlayer{
    
    //1 创建AVPlayerItem
//    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.videoURL];
    _playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    
    //2.把AVPlayerItem放在AVPlayer上
    _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    
    //3 再把AVPlayer放到 AVPlayerLayer上
    _avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    _avplayerLayer.frame = self.BGView.bounds;
    _avplayerLayer.delegate = self;
    
    //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
    [self.BGView.layer addSublayer:_avplayerLayer];
    
    // 菊花
    CGFloat w = 40;
    CGFloat x = (self.BGView.width - w)/2.0;
    CGFloat y = (self.BGView.height - w)/2.0;
    XMRefreshView *refreshView = [XMRefreshView refreshViewWithFrame:CGRectMake(x, y, w, w) logoStyle:RefreshLogoNone];
    [self.BGView addSubview:refreshView];
    [refreshView startAnimation];
    self.refreshView = refreshView;
    
    // 添加观察
    [self loadObserver:_playerItem];
    
    // 播放状态通知
    [self loadPlayStatusNoti];
    
    // 添加手势
    [self loadGesture];
}

/**
 添加观察
 */
- (void)loadObserver:(AVPlayerItem *)playerItem{
    
    /**以上是基本的播放界面，但是没有前进后退**/
    //观察是否播放，KVO进行观察，观察playerItem.status
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
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
            
        } else if (status == AVPlayerStatusFailed) {
            //
            XMLog(@"AVPlayerStatusFailed");
            
            // 播放失败
            [self playFailed];
            
        } else {
            
            XMLog(@"AVPlayerStatusUnknown");
            
            // 播放失败
            [self playFailed];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        
        NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
        CMTime duration = playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        
        //        XMLog(@"加载进度：%.2f", timeInterval / totalDuration);
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        
        XMLog(@"缓冲不足暂停了");
        [_player pause];
        [self startAnimation];
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        XMLog(@"缓冲达到可播放程度了");
        
        //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        // 结束刷新
        [self endAnimation];
        // 播放
        [_player play];
        
    } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        
        XMLog(@"缓冲区满了");
    }
}

/**
 播放状态通知
 */
- (void)loadPlayStatusNoti{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:_player.currentItem];
}

/**
 播放结束
 */
- (void)playbackFinished{
    
    if (self.isAllowCyclePlay) {
        
        // 播放结束重复播放
        [_player seekToTime:CMTimeMake(0, 1)];
        [_player play];
        
    }else{
        
        // 退出播放
        [self tapAction];
    }
}

/**
 播放失败
 */
- (void)playFailed{
    
    [XMTextHUD xm_showText:XMVideoPlayFialText];
    
    [_player pause];
    
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
        _avplayerLayer = nil;
        
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
    
    [self.refreshView startAnimation];
    self.refreshView.hidden = NO;
}

// 结束旋转
- (void)endAnimation{
    
    [self.refreshView stopAnimation];
    self.refreshView.hidden = YES;
}

#pragma mark 长按手势
- (void)processgestureReconizer:(UIGestureRecognizer *)gesture {
    
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

#pragma mark - 移除
/**
 移除播放器
 */
- (void)removePlayer{
    
    [_player pause];
    [_player setRate:0];
    [_player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:nil];
    [_player replaceCurrentItemWithPlayerItem:nil];
    // 移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _player = nil;
}

#pragma mark - 重新布局
/**
 布局
 */
- (void)layoutSubviews{
    
    XMLog(@"重新布局");
    if (!_hasShowedFistView) {
        [self showFirstImage];
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

// 释放
- (void)dealloc{
    
    XMLog(@"XMPlayer_dealloc");
}


@end
