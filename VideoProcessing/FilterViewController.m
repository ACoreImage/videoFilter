


//
//  FilterViewController.m
//  VideoProcessing
//
//  Created by ClaudeLi on 16/4/25.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController (){
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filters;
    GPUImageMovieWriter *videoWriter;

    AVPlayer *player;
    AVPlayerItem *playerItem;
}
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) NSMutableArray *filterArray;// 滤镜图片数组
@property (nonatomic, strong) NSArray *titleArray; // 滤镜名数组
@property (nonatomic, weak)id playbackTimeObserver; // 播放进度观察者
@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self creatMoviePlayer];
}

- (void)creatMoviePlayer{
    AVAsset *aset = [AVAsset assetWithURL:self.videoUrl];
    
    playerItem = [AVPlayerItem playerItemWithAsset:aset];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    //    [videoPlayer replaceCurrentItemWithPlayerItem:item];
//    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, kNavgationHeight, kScreenWidth, kScreenWidth);
//    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:playerLayer];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [player play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([item status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
//            CMTime duration = item.duration;// 获取视频总长度
//            [self customVideoSlider:duration];// 自定义UISlider外观
//            [self monitoringPlayback:item];// 监听播放状态
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
