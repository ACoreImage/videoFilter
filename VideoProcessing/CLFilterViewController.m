//
//  CLFilterViewController.m
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "CLFilterViewController.h"
#import "CLFilterScrollView.h"
#import "CLCustomView.h"
#import "CLFiltersClass.h"
#import "CLVideoAddFilter.h" //滤镜处理
#import "CLMBProgress.h"

@interface CLFilterViewController ()<CLFilterScroViewDelegate, CLCustomViewDelegate,CLVideoAddFilterDelegate>{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filters;
    GPUImageMovieWriter *videoWriter;
    
    AVPlayer *videoPlayer;
    AVPlayerItem *item;
    CLCustomView *customView; // 各控件所在的载体View
}
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) NSMutableArray *filterArray;// 滤镜图片数组
@property (nonatomic, strong) NSArray *titleArray; // 滤镜名数组
@property (nonatomic, weak)id playbackTimeObserver; // 播放进度观察者
@property (nonatomic, strong) CLMBProgress *clProgress; // 显示处理进度
@property (nonatomic, assign) NSInteger index; // 选择第几个滤镜参数，默认=0无滤镜
@end

@implementation CLFilterViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleArray = @[@"", @"日韩", @"现代", @"放克",@"东部", @"黑白", @"西部", @"老派",];
        UIImage *image1 = [UIImage imageNamed:@"filterImage"];
        self.filterArray = [NSMutableArray array];
        for (int i = 0; i < 8; i++) {
            if (i == 0) {
                NSString *imageName = [NSString stringWithFormat:@"filter_%d", i];
                [self.filterArray addObject:KImageName(imageName)];
            }else{
                [self.filterArray addObject:[CLFiltersClass imageAddFilter:image1 index:i]];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    self.index = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    // 后台&前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self creatFilterView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self videoStop];
    [item removeObserver:self forKeyPath:@"status"];
    [videoPlayer removeTimeObserver:self.playbackTimeObserver];
    [self removeNotification];
    [movieFile cancelProcessing];
}

// 后台
- (void)resignActiveNotification{
    [movieFile cancelProcessing];
    [self videoStop];
}

// 前台
- (void)enterForegroundNotification{
    [movieFile startProcessing];
    [self videoPlay];
}

- (void)creatFilterView{
    AVAsset *aset = [AVAsset assetWithURL:self.videoUrl];
    AVAssetTrack *videoAssetTrack = [[aset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //    NSLog(@"%f", videoAssetTrack.naturalSize.width);
    //    NSLog(@"%f", videoAssetTrack.naturalSize.height);
    [self customVideoSlider:[aset duration]];// 自定义UISlider外观
    CGAffineTransform transform;
    self.filterView = [GPUImageView new];
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        NSLog(@"1");
        transform = CGAffineTransformMakeRotation(M_PI);
        self.filterView.frame = self.view.bounds;
    }else if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        NSLog(@"2");
        transform = CGAffineTransformMakeRotation(0);
        self.filterView.frame = self.view.bounds;
    }else if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        NSLog(@"3");
        transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.filterView.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    }else if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        NSLog(@"4");
        transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.filterView.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    }
    
    item = [AVPlayerItem playerItemWithAsset:aset];
    videoPlayer = [AVPlayer playerWithPlayerItem:item];
//    [videoPlayer replaceCurrentItemWithPlayerItem:item];
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    
    movieFile = [[GPUImageMovie alloc] initWithPlayerItem:item];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = NO;
    
    GPUImageFilter *filt = [GPUImageFilter new];
    filters = filt;
    [movieFile addTarget:filters];
    
    self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];
    [self.view bringSubviewToFront:self.filterView];
    [self.filterView setTransform:transform];
    
    [filters addTarget:self.filterView];
    [movieFile startProcessing];
    
    [self videoPlay];
    [self addNotification];
    
    [self creatViews];
}

- (void)creatViews{
    customView = [[CLCustomView alloc] initWithFrame:CGRectMake(0, 0, kScreenHeight, kScreenWidth)];
    [customView setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    customView.center = self.view.center;
    [customView.videoSlider addTarget:self action:@selector(videoSliderChanged:) forControlEvents:(UIControlEventValueChanged)];
    [customView.videoSlider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
    [customView.videoSlider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
    
    [customView.filterScrollView setFilterImages:self.filterArray titleArray:self.titleArray index:self.index];
    customView.filterScrollView.tbDelegate = self;
    customView.delegate = self;
    [self.view addSubview:customView];
    
    // 点下一步视频处理进度
    self.clProgress = [[CLMBProgress alloc]initWithFrame:CGRectMake(0, 0, kScreenHeight, kScreenWidth)];
    [self.clProgress setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    self.clProgress.center = self.view.center;
    [self.view addSubview:self.clProgress];
    self.clProgress.hidden = YES;
    
    // 进入时加载滤镜，index为滤镜下标
    [self seletcScrollIndex:self.index];
    
    [self filterButtonAction];
}

#pragma mark - CLCustomView 代理
- (void)clickedButtonChooseType:(ChooseButtonType)chooseType{
    if (chooseType == BackGoOutButton) {
        [self dissMissButton];
    }else if (chooseType == NextGoInButton){
        [self nextButtonAction];
    }else if (chooseType == FilterShowButton){
        [self filterButtonAction];
    }else{
        if (isPlay) {
            [self videoStop];
        }else{
            [self videoPlay];
        }
    }
}

- (void)clickViewTap:(UITapGestureRecognizer *)tap{
    [self tapsAction];
}

#pragma mark - video 播放状态play/stop
- (void)videoPlay{
    isPlay = YES;
    [videoPlayer play];
    [customView.playButton setImage:KImageName(@"Player_暂停") forState:UIControlStateNormal];
}

- (void)videoStop{
    isPlay = NO;
    [videoPlayer pause];
    [customView.playButton setImage:KImageName(@"Player_播放") forState:UIControlStateNormal];
}

#pragma mark - buttonAction
- (void)filterButtonAction{
    if (!isShowFilter) {
        [self filterViewHiddenNO];
    }else{
        [self filterViewHiddenYES];
    }
}

// 隐藏customView
- (void)filterViewHiddenYES{
    [customView.filterButton setImage:KImageName(@"filterButton_off") forState:UIControlStateNormal];
    customView.backgroundView.hidden = YES;
    isShowFilter = 1 - isShowFilter;
}

// 显示customView
- (void)filterViewHiddenNO{
    [customView.filterButton setImage:KImageName(@"filterButton_on") forState:UIControlStateNormal];
    customView.backgroundView.hidden = NO;
    isShowFilter = 1 - isShowFilter;
}

// 点击暂停开始 手势
- (void)tapsAction{
    if (isPlay) {
        if (customView.backgroundView.hidden == NO) {
            [self filterViewHiddenYES];
        }else{
            [self videoStop];
        }
    }else{
        if (customView.backgroundView.hidden == NO) {
            [self filterViewHiddenYES];
        }else{
            [self videoPlay];
        }
    }
}

//按动滑块
-(void)scrubbingDidBegin{
    NSLog(@"按动暂停");
    [self videoStop];
}

//释放滑块
-(void)scrubbingDidEnd{
    NSLog(@"释放播放");
    [self videoPlay];
}

//滑动
-(void)videoSliderChanged:(id)slider{
    [self videoStop];
    [self scrubberIsScrolling];
}

//拖动进度条
-(void)scrubberIsScrolling{
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(customView.videoSlider.value, 1);
    
    [item seekToTime:dragedCMTime];
}

// 返回事件
- (void)dissMissButton{
    // 清空临时文件
    deleteTempDirectory();
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 下一步
- (void)nextButtonAction{
    [self videoStop];
    [self filterViewHiddenYES];
    self.clProgress.progressHUD.labelText = @"视频处理中...";
    self.clProgress.hidden = NO;
    
    CLVideoAddFilter *addFilter = [[CLVideoAddFilter alloc]init];
    addFilter.delegate = self;
    [addFilter addVideoFilter:self.videoUrl tempVideoPath:[NSString vidoTempPath] index:self.index];
}

#pragma mark - 通知/KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            CMTime duration = item.duration;// 获取视频总长度
            [self customVideoSlider:duration];// 自定义UISlider外观
            [self monitoringPlayback:item];// 监听播放状态
        }
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    __weak __typeof(&*self)weakSelf = self;
    //这里设置每秒执行30次
    self.playbackTimeObserver = [videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 计算当前在第几秒
        float currentPlayTime = (double)playerItem.currentTime.value/playerItem.currentTime.timescale;
        [weakSelf updateVideoSlider:currentPlayTime];
    }];
}

- (void)updateVideoSlider:(float)nowTime{
    customView.videoSlider.value = nowTime;
}

- (void)customVideoSlider:(CMTime)duration {
    customView.videoSlider.maximumValue = CMTimeGetSeconds(duration);
}

/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    item = [notification object];
    [item seekToTime:kCMTimeZero];
    [self videoPlay];
}

#pragma mark - 自定义ScrollView——协议
- (void)seletcScrollIndex:(NSInteger)index{
    self.index = index;
    // 实时切换滤镜
    [CLFiltersClass addFilterLayer:movieFile filters:filters filterView:self.filterView index:index];
    [self videoPlay];
}

#pragma mark - CLVideoAddFilter 协议回调
// 视频完成处理
- (void)didFinishVideoDeal:(NSURL *)videoUrl{
    NSLog(@"处理完成");
    self.clProgress.hidden = YES;
    [self save:videoUrl];
}
// 视频处理进度
- (void)filterDealProgress:(CGFloat)progress{
    int p = progress*100;
    self.clProgress.progressHUD.labelText = [NSString stringWithFormat:@"视频处理 %d%%", p];
}

// 操作中断
- (void)operationFailure:(NSString *)failure;{
    NSLog(@"==== %s", __func__);
    self.clProgress.hidden = YES;
}

// 保存至本地相册
- (void)save:(NSURL*)url{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:url
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                    } else {
                                        NSLog(@"Save video succeed.");
                                        [self dissMissButton];
                                    }
                                }];
}

#pragma mark - 系统方向与Status隐藏
- (BOOL)prefersStatusBarHidden{
    // 已经不起作用了
    return YES;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
