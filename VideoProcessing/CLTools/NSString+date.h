//
//  NSString+date.h
//  VideoProcessing
//
//  Created by ClaudeLi on 16/4/25.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (date)

// 临时文件 .mp4 以当前时间命名路径
+ (NSString *)vidoTempPath;

// 播放器_时间转换
+ (NSString *)convertTime:(CGFloat)second;


@end
