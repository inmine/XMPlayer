# XMPlayer
模仿微信短视频播放

![Platform](https://wx1.sinaimg.cn/mw690/e067b31fgy1fu0548jv2mg208w0ikb2b.gif)

# 一，使用步骤
1，导入XMPlayer文件夹

2，引用#import "XMPlayer.h"头文件

3，使用方法：
```
domo1:

XMPlayerView *playerView = [[XMPlayerView alloc] init];

playerView.sourceImagesContainerView = (UIView *)sender;  // 当前的View

playerView.currentImage = sender.currentImage;  // 当前的图片

//    playerView.isAllowDownload = NO; // 不允许下载视频

//    playerView.isAllowCyclePlay = NO;  // 不循环播放

playerView.videoURL = [NSURL URLWithString:@"http://www.scsaide.com/uploadfiles/video/20170928/1506570773879538.mp4"];  // 当前的视频URL

[playerView show];

```

# 二，主要属性
```
@interface XMPlayerView : UIView


/**
 * 当前图片
 *
**/
@property (nonatomic,strong) UIImage *currentImage;

/**
 * 视频URL地址
 *
 * 支持网络视频，本地相册视频
 **/
@property (nonatomic,strong) NSURL *videoURL;

/**
 * 当前容器的View
 *
 **/
@property (nonatomic, weak) UIView *sourceImagesContainerView;

/**
 * 是否允许下载视频
 *
 * 默认YES 
 **/
@property (nonatomic, assign) BOOL isAllowDownload;

/**
 * 是否允许视频循环播放
 *
 * 默认YES
 **/
@property (nonatomic, assign) BOOL isAllowCyclePlay;

/**
 * 显示
 *
 */
- (void)show;

@end
```

# 三，宏定义修改
```
/************************ main ******************************/

/**
 *  图片动画时长
 */
#define XMImageAnimationDuration 0.35f

/**
 *  字体
 */
#define XM18Font [UIFont systemFontOfSize:18]

/************************ 菊花 ******************************/

/**
 *  旋转菊花的颜色
 */
#define XMRefreshColor [UIColor whiteColor].CGColor

```

# 四，注意事项

1，框架最适合小于30s小视频循环播放

2，宏定义在XMPlayerConfig中，可修改

3，暂时没有找到竖直方向的视频，如果谁有，可以发到我的简书里，或者写在issue中，谢谢，简书地址在下面


# 五，版本记录

- 2017-11-01　　初版
- 2017-11-06　　保存添加视频下载到相册
- 2018-08-06　　优化代码，优化内存
- 2018-08-08　　解决部分文件丢失问题
- 2019-03-05    添加dome2， demo3(初稿，未优化)


# 六，更多

1，如果觉得可以，请给个星星✨✨✨✨✨，谢谢🙏

1，如果您发现了bug请尽可能详细地描述系统版本、手机型号和复现步骤等信息 提一个issue.

3，我的简书http://www.jianshu.com/p/6e82fd2fcb01
 
 
