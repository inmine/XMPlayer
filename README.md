# XMPlayer
模仿微信短视频播放

![Platform](https://wx4.sinaimg.cn/mw690/e067b31fgy1fl2nfwkfgwj208c0i2acj.jpg)
![Platform](https://wx3.sinaimg.cn/mw690/e067b31fgy1fl8e7qo5tcj208c0i2jt3.jpg)
![Platform](https://wx3.sinaimg.cn/mw690/e067b31fgy1fl8e7qeacmj208c0i2q4z.jpg)

# 一，使用步骤
1，导入XMPlayer文件夹

2，引用#import "XMPlayer.h"头文件

3，使用方法：
```
XMPlayerManager *playerManager = [[XMPlayerManager alloc] init];

playerManager.sourceImagesContainerView = (UIView *)sender; // 当前的View

playerManager.currentImage = sender.currentImage;  // 当前的图片

 // playerManager.isAllowDownload = NO; // 不允许下载视频
 
//    playerManager.isAllowCyclePlay = NO;  // 不循环播放

playerManager.videoURL = [NSURL URLWithString:self.playerModel.videourl]; // 当前的视频URL

[playerManager show];
```

# 二，主要属性
```
@interface XMPlayerManager : UIView


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
 *  图字体
 */
#define XM18Font [UIFont systemFontOfSize:18]


/************************ 菊花 ******************************/

/**
 *  旋转菊花的颜色
 */
#define XMRefreshColor [UIColor redColor].CGColor


/************************ 进度条 ******************************/

/**
 *  进度背景颜色
 */
#define XMProgressBGColor XMRGBAColor(0,0,255,0.7)

/**
 *  进度背景颜色
 */
#define XMProgressInsideBGColor XMRGBAColor(0,255,0,0.7)

/**
 *  波浪进度颜色1
 */
#define XMWavesColor1 XMRGBAColor(216,59,49,0.7)

/**
 *  波浪进度颜色2
 */
#define XMWavesColor2 XMRGBAColor(255,0,0,0.7)
```

# 四，注意事项

1，框架最适合小于30s小视频循环播放，由于AVPlayer缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放，所以视频过大可能会出现中断问题

2，整个方法在demo中在XMPlayerTableViewCell实现

3，长按视频下载，视频下载基于AFNetworking框架，如果不需要下载功能，或者未使用AFNetworking框架，可以删除相应的代码

4，宏定义在XMPlayerConfig中，可修改

5，暂时没有找到竖直方向的视频，如果谁有，可以发到我的简书里，或者写在issue中，谢谢，简书地址在下面


# 五，版本记录

- 2017-11-01　　初版
- 2017-11-06　　保存添加视频下载到相册


# 六，更多

1，如果觉得可以，请给个星星✨✨✨✨✨，谢谢🙏

1，如果您发现了bug请尽可能详细地描述系统版本、手机型号和复现步骤等信息 提一个issue.

2，我的简书http://www.jianshu.com/p/6e82fd2fcb01
 
3，支持横竖屏等其他新功能正在添加中。。。。
 
 
