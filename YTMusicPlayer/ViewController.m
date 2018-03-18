//
//  ViewController.m
//  YTMusicPlayer
//
//  Created by yetaiwen on 17/3/24.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import "ViewController.h"
#import "YTMusicPlayer.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray *songList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSArray *)songList
{
    if (!_songList) {
        NSURL *url1 = [[NSBundle mainBundle]URLForResource:@"潘美辰写不完的爱.mp3" withExtension:@""];
        NSURL *url2 = [[NSBundle mainBundle]URLForResource:@"莫斯科没有眼泪twins.mp3" withExtension:@""];
        NSURL *url3 = [[NSBundle mainBundle]URLForResource:@"郑源为爱停留.mp3" withExtension:@""];
        _songList = @[url1,url2,url3];
    }return _songList;

}

- (IBAction)playMusic:(UIButton *)sender {
    YTMusicPlayer *musicPlayer = [YTMusicPlayer shareAVPlayer];
    musicPlayer.musicList = [self.songList mutableCopy];
    musicPlayer.currentItem = self.songList[0];
    [self presentViewController:musicPlayer animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
