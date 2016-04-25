//
//  CLCustomView.m
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "CLCustomView.h"
#define TopGroundHight 132.0f // 滤镜背景高度
#define CustomViewWidth self.frame.size.width
#define CustomViewHeight self.frame.size.height

@implementation CLCustomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
        // 点击手势 播放/暂停
        UITapGestureRecognizer *taps = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapsAction:)];
        [self addGestureRecognizer:taps];
        
        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CustomViewWidth, TopGroundHight)];
        self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        self.filterScrollView = [[CLFilterScrollView alloc] initWithFrame:CGRectMake(0, self.backgroundView.frame.size.height - FilterScrollHight, self.backgroundView.frame.size.width, FilterScrollHight)];
        [self.backgroundView addSubview:self.filterScrollView];
        [self addSubview:self.backgroundView];
        self.backgroundView.hidden = YES;
        
        self.backButton = [[CLButton alloc]initWithFrame:CGRectMake(0, 0, 12 + 30, 24 + 40)];
        _backButton.chooseType = BackGoOutButton;
        [_backButton setImage:KImageName(@"filter_back") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickedButtonType:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        self.nextButton = [[CLButton alloc]initWithFrame:CGRectMake(CustomViewWidth - (12 + 30), 0, 12 + 30, 24 + 40)];
        _nextButton.chooseType = NextGoInButton;
        [_nextButton setImage:KImageName(@"filter_next") forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(clickedButtonType:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextButton];
        
        self.filterButton = [[CLButton alloc]initWithFrame:CGRectMake(0, 0, 42.5 + 10, 42.5 + 10)];
        self.filterButton.chooseType = FilterShowButton;
        self.filterButton.center = CGPointMake(self.center.x, 52.5/2 + 10);
        [self.filterButton setImage:KImageName(@"filterButton_off") forState:UIControlStateNormal];
        [_filterButton addTarget:self action:@selector(clickedButtonType:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_filterButton];
        
        self.playButton = [[CLButton alloc] initWithFrame:CGRectMake(0, CustomViewHeight - 42, 57, 42)];
        self.playButton.chooseType = PlayOrStopButton;
        [self.playButton setImage:KImageName(@"Player_暂停") forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(clickedButtonType:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        self.videoSlider = [UISlider new];
        _videoSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), CustomViewHeight - 22, CustomViewWidth - self.playButton.frame.size.width - 15, 2);
        self.videoSlider.continuous = YES;
        [self.videoSlider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
        [self.videoSlider setThumbImage:KImageName(@"MoviePlayer_控制点") forState:UIControlStateNormal];
        [self.videoSlider setMinimumTrackImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        //最大值轨道图片
        [self.videoSlider setMaximumTrackImage:KImageName(@"进度条_背景") forState:UIControlStateNormal];
        
        [self addSubview:self.videoSlider];
    }
    return self;
}

// button 点击事件
- (void)clickedButtonType:(CLButton *)sender
{
    scaleAnimation(sender);
    if ([self.delegate respondsToSelector:@selector(clickedButtonChooseType:)]) {
        [self.delegate clickedButtonChooseType:sender.chooseType];
    }
}

- (void)tapsAction:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(clickViewTap:)]) {
        [self.delegate clickViewTap:tap];
    }
}



@end
