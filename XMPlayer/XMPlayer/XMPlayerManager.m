//
//  XMPlayerManager.m
//  XMPlayer
//
//  Created by min on 2017/10/30.
//  Copyright © 2017年 min. All rights reserved.
//

#import "XMPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "XMPlayerConfig.h"
#import "UIView+Extension.h"
#import "XMRefreshView.h"

@interface XMPlayerManager () {
    
        AVPlayer *player;
        AVPlayerItem *playerItem;
        AVPlayerLayer *avplayerLayer;
}

/** 背景view */
@property (nonatomic,strong) UIView *BGView;

/** 加载时旋转菊花 */
@property(nonatomic, strong) XMRefreshView *refreshView;

/** 临时图片 */
@property (nonatomic,strong) UIImageView *tempView;

/** 是否已经显示 */
@property (nonatomic, assign) BOOL hasShowedFistView;

@end

@implementation XMPlayerManager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
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

#pragma mark - 点击退出播放
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
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

#pragma mark - 添加视频播放器
- (void)addVideo{
    
    //1 创建AVPlayerItem
    AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:self.videourl]];
    //2.把AVPlayerItem放在AVPlayer上
    player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    //3 再把AVPlayer放到 AVPlayerLayer上
    avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    avplayerLayer.frame = _BGView.bounds;
    avplayerLayer.delegate = self;

    //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
    [_BGView.layer addSublayer:avplayerLayer];
    
//    // 播放
//    [player play];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed2) name:AVPlayerItemFailedToPlayToEndTimeNotification object:player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailed) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:player.currentItem];
    
}

// 播放结束
- (void)playbackFinished{
    
    // 播放结束重复播放
    [player seekToTime:CMTimeMake(0, 1)];
    [player play];
    
}

// 播放失败
-(void)playFailed2{
    
    [player pause];
    // 结束刷新
    [self endAnimation];
}

-(void)playFailed{
    
    [player pause];
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
            
            [player pause];
            
            // 结束刷新
            [self endAnimation];
            
        } else {
            
//            NSLog(@"AVPlayerStatusUnknown");
            
            [player pause];
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
        [player pause];
        [self startAnimation];
         
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
//        NSLog(@"缓冲达到可播放程度了");
        
        //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        // 结束刷新
        [self endAnimation];
        // 播放
        [player play];
        
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
    
    [player pause];
    [player setRate:0];
    [player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:nil];
    [player replaceCurrentItemWithPlayerItem:nil];
    playerItem = nil;
    player = nil;
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

// videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    
//    if (_videoPath) {
//
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([_videoPath path])) {
//            //保存相册核心代码
//            UISaveVideoAtPathToSavedPhotosAlbum([_videoPath path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//        }
//
//    }
    
}

//保存视频完成之后的回调
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    
    if (error) {
        
        NSLog(@"保存视频失败%@", error.localizedDescription);
        
    }else {
        
        NSLog(@"保存视频成功");
    }
    
}


@end
