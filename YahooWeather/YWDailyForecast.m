//
//  YWDailyForecast.m
//  YahooWeather
//
//  Created by Anderson on 15/11/9.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//
//  此类存在仅用于辅助 Mantle 将 JSON 映射到 Objective-C

#import "YWDailyForecast.h"

@implementation YWDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    return paths;
}

@end
