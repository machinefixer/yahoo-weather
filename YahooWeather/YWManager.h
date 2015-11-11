//
//  YWManager.h
//  YahooWeather
//
//  Created by Anderson on 15/11/9.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YWCondition.h"

@interface YWManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, readonly, strong) CLLocation *currentLocation;
@property (nonatomic, readonly, strong) YWCondition *currentCondition;
@property (nonatomic, readonly, strong) NSArray *hourlyForecast;
@property (nonatomic, readonly, strong) NSArray *dailyForecast;

// 用于刷新地理位置
- (void)findCurrentLocation;

@end
