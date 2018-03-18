//
//  YTMusicPlayer.h
//  YTMusicPlayer
//
//  Created by yetaiwen on 17/3/24.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface YTMusicPlayer : UIViewController
/*播放器的基本初始化API*/
//初始化单例
+(instancetype)shareAVPlayer;
//指定当前播放的曲目
@property(nonatomic,strong) id currentItem;
//曲目列表，可以是URL,也可以是MPMediaItem，这里可以根据扩展音乐类型情况装入不同的音乐来源数据
@property(nonatomic,strong) NSMutableArray * musicList;
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
@end
