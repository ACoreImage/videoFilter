//
//  NSString+date.m
//  VideoProcessing
//
//  Created by ClaudeLi on 16/4/25.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "NSString+date.h"

@implementation NSString (date)

+ (NSString *)vidoTempPath
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *times = [formatter stringFromDate:date];
    NSString *str = [NSString stringWithFormat:@"%@.mp4",times];
    NSString *string = [NSTemporaryDirectory() stringByAppendingPathComponent:str];
    
    return string;
}

+ (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

@end
