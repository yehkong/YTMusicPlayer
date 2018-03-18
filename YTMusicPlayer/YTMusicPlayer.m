//
//  YTMusicPlayer.m
//  YTMusicPlayer
//
//  Created by yetaiwen on 17/3/24.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import "YTMusicPlayer.h"
#import "YTMusicTableViewCell.h"

typedef NS_ENUM(NSUInteger,MusicPlayMode) {
    MusicPlayModeRepeat = 0,
    MusicPlayModeRepeatOne,
    MusicPlayModeRandomRepeat,
};

@interface YTMusicPlayer ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistance;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLal;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLal;
@property (weak, nonatomic) IBOutlet UIProgressView *playProgressView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property (nonatomic,strong) AVPlayerItem * currentPlayItem;//播放项目
@property (nonatomic,assign) MusicPlayMode musicPlayMode;//播放模式
@property (nonatomic,weak) UILabel * titleLal;//标题

@end

YTMusicPlayer * ytPlayerController = nil;


@implementation YTMusicPlayer

+ (instancetype)shareAVPlayer{
    if (!ytPlayerController) {
        @synchronized (self) {
            ytPlayerController = [[YTMusicPlayer alloc]init];
        }
    }return ytPlayerController;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setSpecifiedCellSelected:self.currentItem];//高亮开始播放的item
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /***  标题 ***/
    UILabel * titleLal = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 35)];
    _titleLal = titleLal;
    if ([_currentItem isKindOfClass:[MPMediaItem class]]) {
        self.titleLal.text = [_currentItem valueForProperty:MPMediaItemPropertyTitle];
    }else{
        NSURL *url = (NSURL*)_currentItem;
        self.titleLal.text = url.path.lastPathComponent;
    }
    _titleLal.font = [UIFont systemFontOfSize:15];
    _titleLal.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = _titleLal;
    
    /***  返回按钮 ***/
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"explorer_back"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(5, -20, 0, 0)];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    /***  注册cell ***/
    [self.tableView registerNib:[UINib nibWithNibName:@"YTMusicTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YTMusicTableViewCell"];
    
    if (!_musicPlayer) {
        _currentPlayItem = [[AVPlayerItem alloc]initWithURL:[self getCurrentItemUrl:_currentItem]];
        _musicPlayer = [[AVPlayer alloc]initWithPlayerItem:_currentPlayItem];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        __weak typeof(self) weakSelf = self;
        [_musicPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakSelf updateTime];
        }];
    }
    [self musicPlayerStartPlay];
    [self.tableView reloadData];
}

/**
 *  开始播放
 */
- (void)musicPlayerStartPlay{
    [self.musicPlayer play];
    [self setSpecifiedCellSelected:self.currentItem];
    [self _setNowPlayingCenterInfo];
}
/**
 *  获得url
 */
- (NSURL *)getCurrentItemUrl:(id)currentItem{
    /***  初始化self.currentUrl ***/
    NSURL * currentUrl = nil;
    if ([currentItem isKindOfClass:[MPMediaItem class]]) {
        currentUrl = [currentItem valueForProperty:MPMediaItemPropertyAssetURL];
    }else{
        currentUrl = currentItem;
    }
    return currentUrl;
    
}
/**
 *  播放完了
 */
- (void)playEnd:(NSNotification *)nofy{
    NSUInteger currentRow=[self.musicList indexOfObject:self.currentItem];
    switch (_musicPlayMode) {
        case MusicPlayModeRepeat:
            currentRow = (currentRow+1) % self.musicList.count;
            break;
            
        case MusicPlayModeRandomRepeat:
            currentRow = arc4random() % self.musicList.count;
            break;
            
        default:
            break;
    }
    self.currentItem=[self.musicList objectAtIndex:currentRow];
    self.currentPlayItem = [[AVPlayerItem alloc]initWithURL:[self getCurrentItemUrl:self.currentItem]];
    [self.musicPlayer replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self musicPlayerStartPlay];
}
/**
 *  设置cell选定状态
 */
- (void)setSpecifiedCellSelected:(id)mediaItem{
    /***  设置标题 ***/
    if ([mediaItem isKindOfClass:[MPMediaItem class]]) {
        self.titleLal.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    }else{
        NSURL *url = (NSURL*)_currentItem;
        self.titleLal.text = url.path.lastPathComponent;
    }
    NSUInteger  index = [self.musicList indexOfObject:mediaItem];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    /***  设置选定cell状态 ***/
    YTMusicTableViewCell * cell;
    for (int i = 0; i < self.musicList.count; i++) {
        NSIndexPath * inPath = [NSIndexPath indexPathForRow:i inSection:0];
        cell = [self.tableView cellForRowAtIndexPath:inPath];
        [cell setSelected:NO animated:YES];
    }
    
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES animated:YES];
    
}
/**
 *  更新播放时间
 */
- (void)updateTime{
    
    self.currentTimeLal.text = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)CMTimeGetSeconds(_currentPlayItem.currentTime)/60,(unsigned long)CMTimeGetSeconds(_currentPlayItem.currentTime)%60];
    self.totalTimeLal.text = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)CMTimeGetSeconds(_currentPlayItem.duration)/60,(unsigned long)CMTimeGetSeconds(_currentPlayItem.duration)%60];
    self.playProgressView.progress = CMTimeGetSeconds(_currentPlayItem.currentTime)/CMTimeGetSeconds(_currentPlayItem.duration);
    self.progressSlider.value = CMTimeGetSeconds(_currentPlayItem.currentTime)/CMTimeGetSeconds(_currentPlayItem.duration);
    
}
/**
 *  上一首
 */
- (IBAction)lastSongAction:(UIButton *)sender {
    NSUInteger currentRow=[self.musicList indexOfObject:self.currentItem];
    currentRow = (currentRow-1)%self.musicList.count;
    self.currentItem = [self.musicList objectAtIndex:currentRow];
    self.currentPlayItem = [[AVPlayerItem alloc]initWithURL:[self getCurrentItemUrl:self.currentItem]];
    [self.musicPlayer replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self musicPlayerStartPlay];
    
}
/**
 *  播放或暂停
 */
- (IBAction)playOrPauseAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        [self.musicPlayer pause];
    }
    else{
        [self.musicPlayer play];
    }
}
/**
 *  下一首
 */
- (IBAction)nextSongAction:(UIButton *)sender {
    NSUInteger currentRow=[self.musicList indexOfObject:self.currentItem];
    NSUInteger newRow = 0;
    switch (_musicPlayMode) {
        case MusicPlayModeRandomRepeat:
        {
            newRow = arc4random() % self.musicList.count;
            break;
        }
        default:
        {
            newRow = (currentRow+1)%self.musicList.count;
            break;
        }
    }
    self.currentItem = [self.musicList objectAtIndex:newRow];
    
    self.currentPlayItem = [[AVPlayerItem alloc]initWithURL:[self getCurrentItemUrl:self.currentItem]];
    [self.musicPlayer replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self musicPlayerStartPlay];
    
}
/**
 *  pop事件
 */
- (void)backAction{
    //        [self.musicList removeAllObjects];
    //        self.musicList = nil;
    //        self.currentItem = nil;
    //        self.currentPlayItem = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  播放模式选择
 *
 *  @param sender sender description
 */
- (IBAction)changePlayMode:(UIButton *)sender {
    switch (_musicPlayMode) {
        case MusicPlayModeRandomRepeat:
            _musicPlayMode=MusicPlayModeRepeatOne;
            [sender setImage:[UIImage imageNamed:@"Track_Repeat_On_Track"] forState:UIControlStateNormal];
            [sender setTitle:@"单曲播放" forState:UIControlStateNormal];
            break;
        case MusicPlayModeRepeat:
            _musicPlayMode=MusicPlayModeRandomRepeat;
            [sender setImage:[UIImage imageNamed:@"Track_Shuffle_On"] forState:UIControlStateNormal];
            [sender setTitle:@"随机播放" forState:UIControlStateNormal];
            
            break;
            
        default:
            _musicPlayMode=MusicPlayModeRepeat;
            [sender setImage:[UIImage imageNamed:@"Track_Repeat_On"] forState:UIControlStateNormal];
            [sender setTitle:@"顺序播放" forState:UIControlStateNormal];
            break;
    }
}
- (IBAction)progressSlideAction:(UISlider *)sender {
    [self.musicPlayer pause];
    float kProgress = sender.value;
    float seconds = CMTimeGetSeconds(self.currentPlayItem.duration) * kProgress;
    [self.musicPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
    [self.musicPlayer play];
}


- (void)_setNowPlayingCenterInfo{
    dispatch_async(dispatch_queue_create("", NULL), ^{
        NSMutableDictionary * infoDict = [NSMutableDictionary dictionary];
        if ([self.currentItem isKindOfClass:[MPMediaItem class]]) {
            [infoDict setObject:[NSNumber numberWithInteger:CMTimeGetSeconds(self.currentPlayItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
            //            [infoDict setObject:[self.currentItem valueForProperty:MPMediaItemPropertyArtwork] forKey:MPMediaItemPropertyArtwork];
            [infoDict setObject:[self.currentItem valueForProperty:MPMediaItemPropertyTitle] forKey:MPMediaItemPropertyTitle];
            [infoDict setObject:[self.currentItem valueForProperty:MPMediaItemPropertyArtist] forKey:MPMediaItemPropertyArtist];
            [infoDict setObject:[self.currentItem valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:MPMediaItemPropertyAlbumTitle];
        }else {
            AVURLAsset * asset = nil;
            NSURL * url = self.currentItem;
            
            asset = [AVURLAsset assetWithURL:url];
            for (NSString * format in [asset availableMetadataFormats]) {
                for (AVMetadataItem * metadata in [asset metadataForFormat:format]) {
                    if (metadata.value) {
                        if ([metadata.commonKey isEqualToString:@"artwork"]) {
                            MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc]initWithImage:[UIImage imageWithData:(NSData *)metadata.value]];
                            [infoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
                        }
                        else if([metadata.commonKey isEqualToString:@"artist"]) {
                            [infoDict setObject:metadata.value forKey:MPMediaItemPropertyArtist];
                        }
                        else if([metadata.commonKey isEqualToString:@"albumName"]){
                            [infoDict setObject:metadata.value forKey:MPMediaItemPropertyAlbumTitle];
                        }
                    }
                }
            }
            [infoDict setObject:[NSNumber numberWithInteger:CMTimeGetSeconds(self.currentPlayItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
#warning
            [infoDict setObject:@"fileName" forKey:MPMediaItemPropertyTitle];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MPNowPlayingInfoCenter defaultCenter]setNowPlayingInfo:infoDict];
            [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
        });
    });
    
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.musicList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMusicTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"YTMusicTableViewCell" forIndexPath:indexPath];
    id item = self.musicList[indexPath.row];
    if ([item isKindOfClass:[MPMediaItem class]]) {
        cell.musicNameLal.text = [item valueForProperty:MPMediaItemPropertyTitle];
    }else{
        NSURL *url = (NSURL*)item;
        cell.musicNameLal.text = url.path.lastPathComponent;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentItem = [self.musicList objectAtIndex:indexPath.row];
    
    self.currentPlayItem = [[AVPlayerItem alloc]initWithURL:[self getCurrentItemUrl:self.currentItem]];
    [self.musicPlayer replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self.musicPlayer play];
    [self setSpecifiedCellSelected:self.currentItem];
    
}
#pragma mark - NKDelegate

- (void)accessoryDidconnect{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"已连接设备，是否离开此页面开始更多功能···" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 10;
    [alertView show];
    
}
- (void)accessoryDidDisconnect{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"已拨出设备，是否离开此页面" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 11;
    [alertView show];
}

#pragma mark - alterview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else{
        if (buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - autoRotate

- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationPortrait) {
        self.topDistance.constant = 64;
    }else{
        self.topDistance.constant = 32;
    }
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
