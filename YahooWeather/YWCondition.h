//
//  YWCondition.h
//  YahooWeather
//
//  Created by Anderson on 15/11/9.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface YWCondition : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, copy) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, copy) NSString *conditionDescription;
@property (nonatomic, copy) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, copy) NSString *icon;

// 将天气图标和天气状况对应起来
- (NSString *)imageName;

@end
