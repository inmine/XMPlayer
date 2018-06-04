//
//  XMPlayerManager.m
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//


// 项目github地址: https://github.com/inmine/XMPlayer.git

#import "XMPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "XMPlayerConfig.h"
#import "UIView+Extension.h"
#import "XMRefreshView.h"
#import "XMProgress.h"
/**
 * 视频下载基于AFNetworking框架
 * 如果不需要下载功能，或者未使用AFNetworking框架，可以删除相应的代码
 **/
#import "AFNetworking.h"

@interface XMPlayerManager () {
    
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_avplayerLayer;
}

/** 背景view */
@property (nonatomic,strong) UIView *BGView;

/** 加载时旋转菊花 */
@property(nonatomic, strong) XMRefreshView *refreshView;

/** 临时图片 */
@property (nonatomic,strong) UIImageView *tempView;

/** 是否已经显示 */
@property (nonatomic, assign) BOOL hasShowedFistView;

/** 蒙版 */
@property (nonatomic,strong) UIButton *mengbanView;

/** 保存View */
@property (nonatomic,strong) UIView *saveView;

/** 进度 */
@property (nonatomic,strong) XMProgress *progressView;

/** 下载 */
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation XMPlayerManager

- (XMProgress *)progressView{
    if (_progressView == nil) {
        
        _progressView = [[XMProgress alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        _progressView.hidden = YES;
        [_BGView addSubview:_progressView];
        
    }
    return _progressView;
}
    
- (NSURLSessionDownloadTask *)downloadTask{
    
    if (!_downloadTask) {
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.videoURL];
        
        _downloadTask=[session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
            // 下载进度
//            NSLog(@"下载进度 %@",downloadProgress);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                self.progressView.progress = downloadProgress.fractionCompleted;
            }];
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            //下载到哪个文件夹
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            
            NSString *fileName = [cachePath stringByAppendingPathComponent:response.suggestedFilename];
            
            return [NSURL fileURLWithPath:fileName];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            //下载完成了
//            NSLog(@"下载完成了 %@",filePath);
            self.progressView.hidden = YES;
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([filePath path])) {
                
                // 视频保存相册核心代码
                UISaveVideoAtPathToSavedPhotosAlbum([filePath path], nil, nil, nil);
                
            }
        }];
    }
    
    return _downloadTask;
}

- (UIButton *)mengbanView{
    
    if (_mengbanView == nil) {
        
        // 蒙版
        _mengbanView = [[UIButton alloc] init];
        _mengbanView.frame = self.bounds;
        _mengbanView.hidden = YES;
        _mengbanView.backgroundColor = [UIColor blackColor];
        _mengbanView.alpha = 0;
        [_mengbanView addTarget:self action:@selector(mengbanViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_mengbanView];
        
        // 保存View
        _saveView = [[UIView alloc] init];
        _saveView.backgroundColor = XMRGBColor(247, 247, 247);
        [self addSubview:_saveView];
        
        if (HEIGHT == 812) { // iphone X
            
            _saveView.frame = CGRectMake(0, HEIGHT, WIDTH , 106 + 36);
        }else{
            _saveView.frame = CGRectMake(0, HEIGHT, WIDTH , 106);
        }
        
        // 保存Btn
        UIButton *saveBtn = [[UIButton alloc] init];
        saveBtn.frame = CGRectMake(0, 0, WIDTH, 50);
        saveBtn.backgroundColor = [UIColor whiteColor];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        saveBtn.titleLabel.font = XM18Font;
        [saveBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        [_saveView addSubview:saveBtn];
        
        // 取消Btn
        UIButton *canleBtn = [[UIButton alloc] init];
        canleBtn.frame = CGRectMake(0, 56, WIDTH, 50);
        canleBtn.backgroundColor = [UIColor whiteColor];
        [canleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [canleBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        canleBtn.titleLabel.font = XM18Font;
        [canleBtn addTarget:self action:@selector(mengbanViewClick) forControlEvents:UIControlEventTouchUpInside];
        [_saveView addSubview:canleBtn];
    }
    
    return  _mengbanView;
}
    
    
- (void)mengbanViewClick{
    
    [UIView animateWithDuration:0.1 animations:^{
        
        self.mengbanView.alpha = 0;
        _saveView.y = HEIGHT;
        
    } completion:^(BOOL finished) {
        
        _saveView.hidden = YES;
        self.mengbanView.hidden = YES;
    }];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        // 默认允许下载视频
        self.isAllowDownload = YES;
        // 默认允许循环播放
        self.isAllowCyclePlay = YES;
        
    }
    return self;
}

// 显示
- (void)show{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 设置背景View
    _BGView = [[UIView alloc] init];
    _BGView.backgroundColor = [UIColor blackColor];
    _BGView.center = window.center;
    _BGView.bounds = window.bounds;
    self.center = CGPointMake(_BGView.bounds.size.width * 0.5, _BGView.bounds.size.height * 0.5);
    self.bounds = CGRectMake(0, 0, _BGView.bounds.size.width, _BGView.bounds.size.height);
    [_BGView addSubview:self];
    
    // 添加到窗口上
    [window addSubview:_BGView];
    //隐藏状态栏
    window.windowLevel = UIWindowLevelStatusBar + 10.0f;
    
    // 添加视频
    [self addVideo];
}

#pragma mark - 重新布局
- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (!_hasShowedFistView) {
        
        [self showFirstImage];
    }
}

#pragma mark - 显示图片
- (void)showFirstImage{
    
    UIView *sourceView = [self.sourceImagesContainerView.subviews firstObject];
    
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
//    NSLog(@"%@",NSStringFromCGRect(rect));
    
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

#pragma mark - 添加视频播放器
- (void)addVideo{
    
    //1 创建AVPlayerItem
    AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:self.videoURL];
    //2.把AVPlayerItem放在AVPlayer上
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    //3 再把AVPlayer放到 AVPlayerLayer上
    _avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    _avplayerLayer.frame = _BGView.bounds;
    _avplayerLayer.delegate = self;

    //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
    [_BGView.layer addSublayer:_avplayerLayer];
    
    
    CGFloat w = 40;
    CGFloat x = (_BGView.width - w)/2.0;
    CGFloat y = (_BGView.height - w)/2.0;
    self.refreshView = [XMRefreshView refreshViewWithFrame:CGRectMake(x, y, w, w) logoStyle:RefreshLogoNone];
    [_BGView addSubview:self.refreshView];
    [self.refreshView startAnimation];
    
    /**以上是基本的播放界面，但是没有前进后退**/
    //观察是否播放，KVO进行观察，观察playerItem.status
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed2) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:_player.currentItem];
    
    //创建手势对象
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    //配置属性
    //轻拍次数
    tap.numberOfTapsRequired =1;
//    //轻拍手指个数
//    tap.numberOfTouchesRequired =1;
    //讲手势添加到指定的视图上
    [self addGestureRecognizer:tap];
    
    if (self.isAllowDownload == YES) {
        
        // 长按
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(processgestureReconizer:)];
        longPress.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longPress];
    }
}
    
// 单击
- (void)tapAction{
    
    // 停止下载
    [self.downloadTask suspend];
    
    UIView *sourceView = [self.sourceImagesContainerView.subviews firstObject];

    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    self.window.windowLevel = UIWindowLevelNormal;//显示状态栏

    // 移除播放器
    [self removePlayer];

    [UIView animateWithDuration:XMImageAnimationDuration animations:^{

        self.tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        _BGView.backgroundColor = [UIColor clearColor];

    } completion:^(BOOL finished) {

        // 移除
        [self.refreshView removeFromSuperview];
        [self.tempView removeFromSuperview];
        [_BGView removeFromSuperview];
//        [self removeFromSuperview];
    }];
}

// 播放结束
- (void)playbackFinished{
    
    if (self.isAllowCyclePlay ==  YES) {
        
        // 播放结束重复播放
        [_player seekToTime:CMTimeMake(0, 1)];
        [_player play];
        
    }else{
        
        // 退出播放
        [self tapAction];
    }
}

// 播放失败
-(void)playFailed2{
    
    [_player pause];
    // 结束刷新
    [self endAnimation];
}

-(void)playFailed{
    
    [_player pause];
    // 结束刷新
    [self endAnimation];
}

/*
 * 执行观察者方法
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *playerItems = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        
        if (status == AVPlayerStatusReadyToPlay) {
            
//            NSLog(@"AVPlayerStatusReadyToPlay");
            
            //status 点进去看 有三种状态
            
            CGFloat duration = playerItems.duration.value / playerItems.duration.timescale; //视频总时间
//            NSLog(@"准备好播放了，总时间：%.2f", duration);//还可以获得播放的进度，这里可以给播放进度条赋值了
            
        } else if (status == AVPlayerStatusFailed) {
            
//            NSLog(@"AVPlayerStatusFailed");
            
            [_player pause];
            
            // 结束刷新
            [self endAnimation];
            
        } else {
            
//            NSLog(@"AVPlayerStatusUnknown");
            
            [_player pause];
            // 结束刷新
            [self endAnimation];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        
        NSArray *loadedTimeRanges = [playerItems loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
        CMTime duration = playerItems.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        
//        NSLog(@"下载进度：%.2f", timeInterval / totalDuration);
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        
//        NSLog(@"缓冲不足暂停了");
        [_player pause];
        [self startAnimation];
         
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
//        NSLog(@"缓冲达到可播放程度了");
        
        //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        // 结束刷新
        [self endAnimation];
        // 播放
        [_player play];
        
    } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        
//        NSLog(@"缓冲区满了");
        
    }
}

// 释放
- (void)dealloc {
    
     // 移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

// 移除播放器
- (void)removePlayer{
    
    [_player pause];
    [_player setRate:0];
    [_player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:nil];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _playerItem = nil;
    _player = nil;
}

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

    _saveView.hidden = NO;
    self.mengbanView.hidden = NO;

    [UIView animateWithDuration:0.2 animations:^{

        self.mengbanView.alpha = 0.5;
        
        if (HEIGHT == 812) { // iphone X
            
            _saveView.y = HEIGHT - (106 + 36);
        }else{
            _saveView.y = HEIGHT - 106;
        }
    }];
}

- (void)saveImage{

//    XMLog(@"保存");

    [self mengbanViewClick];
    
    // 开始下载
    [self.downloadTask resume];
    
    self.progressView.hidden = NO;
}



@end
