# XMPlayer
模仿微信短视频播放

![Platform](https://wx4.sinaimg.cn/mw690/e067b31fgy1fl2nfwkfgwj208c0i2acj.jpg)
![Platform](https://wx4.sinaimg.cn/mw690/e067b31fgy1fl2nfwjhbqj208c0i2q4j.jpg)

# 一，使用步骤
1，导入XMPlayer文件夹

2，引用#import "XMPlayer.h"头文件

3，使用方法：
```
    XMPlayerManager *playerManager = [[XMPlayerManager alloc] init];
    
    playerManager.sourceImagesContainerView = self; ／／ 当前的view
    
    playerManager.currentImage = sender.currentImage;  ／／ 当前的图片
    
    playerManager.videourl = self.playerModel.videourl;    ／／ 视频地址
    
    [playerManager show];
```

# 二，主要属性
```
@interface XMPlayerManager : UIView

/** 当前图片 */

@property (nonatomic,strong) UIImage *currentImage;

/** 视频地址 */

@property (nonatomic, copy) NSString *videourl;

/** 当前容器的View */

@property (nonatomic, weak) UIView *sourceImagesContainerView;

/*** 显示*/

 - (void)show;

@end
```

# 三，注意事项

1，框架最适合小于30s小视频循环播放，由于AVPlayer缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放，所以视频过大可能会出现中断问题

2，整个方法最好在一个单独的view中实现，demo中在XMImgView实现，以免视频播放完后返回时的图片动画不连贯

3，暂时没有找到竖直方向的视频，如果谁有，可以发到我的简书里，或者写在issue中，谢谢，简书地址在下面

# 四，更多

1，如果觉得可以，请给个星星✨✨✨✨✨，谢谢🙏

1，如果您发现了bug请尽可能详细地描述系统版本、手机型号和复现步骤等信息 提一个issue.

2，我的简书http://www.jianshu.com/p/6e82fd2fcb01
 
3，保存视频以及支持横竖屏等其他新功能正在添加中。。。。
 
 
