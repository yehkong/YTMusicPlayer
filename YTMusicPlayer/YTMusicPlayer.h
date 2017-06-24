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

+(instancetype)shareAVPlayer;
@property(nonatomic,strong) id currentItem;
@property(nonatomic,strong) NSMutableArray * musicList;
@property (nonatomic,strong) AVPlayer * musicPlayer;//播放器
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
- (IBAction)playOrPauseAction:(UIButton *)sender;
- (IBAction)nextSongAction:(UIButton *)sender;
- (IBAction)lastSongAction:(UIButton *)sender;
@end
