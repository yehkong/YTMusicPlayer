# YTMusicPlayer
一款简单的音乐播放器，可支持在线播放，全局播放，后台播放

序言：此款播放器基于AVFoundation框架的AVPlayer开发，可以播放苹果音乐格式(MPMediaItem),可以播放在线的音乐(基于url)，也可以自己在代码中简单定制其他来源的音乐，扩展其功能。
其博客介绍地址：[一款简单好用的在线音乐播放器(可功能扩展)](https://www.jianshu.com/p/5fc6935e8d85)
* 简单API介绍：
```
/*播放器的基本初始化API*/
//初始化单例
+(instancetype)shareAVPlayer;
//指定当前播放的曲目
@property(nonatomic,strong) id currentItem;
//曲目列表，可以是URL,也可以是MPMediaItem，这里可以根据扩展音乐类型情况装入不同的音乐来源数据
@property(nonatomic,strong) NSMutableArray * musicList;
```
* 播放用例：
```
YTMusicPlayer *musicPlayer = [YTMusicPlayer shareAVPlayer];
musicPlayer.musicList = [self.songList mutableCopy];
musicPlayer.currentItem = self.songList[0];
[self presentViewController:musicPlayer animated:YES completion:nil];
```
* 其他API,主要用于在全局播放时，对播放器进行控制
```
/*播放器的扩展API，可用于全局播放*/
//播放器
@property (nonatomic,strong) AVPlayer * musicPlayer;
//上一曲按钮
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
//下一曲按钮
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
//播放暂停按钮
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
//播放暂停
- (IBAction)playOrPauseAction:(UIButton *)sender;
//播放下一曲
- (IBAction)nextSongAction:(UIButton *)sender;
//播放上一曲
- (IBAction)lastSongAction:(UIButton *)sender;
```
* 可扩展性
可以再源文件中进行判断，增加对传入数组内的数据进行特别处理，以实现对不同的音乐类型进行无缝播放。
建议扩展处在源文件中有注释。
* 效果图片
> ![1.png](https://upload-images.jianshu.io/upload_images/2737326-67d0d37a914781bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> ![2.png](https://upload-images.jianshu.io/upload_images/2737326-9b5baa1da66a7124.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
PS:博客说明地址：[一款简单好用的在线音乐播放器(可功能扩展)](https://www.jianshu.com/p/5fc6935e8d85)


