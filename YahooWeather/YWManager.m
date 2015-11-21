//
//  YWManager.m
//  YahooWeather
//
//  Created by Anderson on 15/11/9.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//

#import "YWManager.h"
#import "YWClient.h"
#import <TSMessages/TSMessage.h>

@interface YWManager ()

// 同样的但可读写的属性
@property (nonatomic, readwrite, strong) YWCondition *currentCondition;
@property (nonatomic, readwrite, strong) CLLocation *currentLocation;
@property (nonatomic, readwrite, strong) NSString *currentCityName;
@property (nonatomic, readwrite, strong) NSArray *hourlyForecast;
@property (nonatomic, readwrite, strong) NSArray *dailyForecast;

// 额外属性
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) YWClient *client;

@end

@implementation YWManager

+ (instancetype)sharedManager
{
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // 请求使用定位
        [self.locationManager requestWhenInUseAuthorization];
        
        self.client = [[YWClient alloc] init];
        
        [[[[RACObserve(self, currentLocation)
            ignore:nil]
           
           // 同时订阅三个信号
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
               // 切换到主线程
           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"更新数据失败"
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation
{
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    if (location.horizontalAccuracy > 0) {
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
        
        // 更新 CityName, 通过 CLGeocoder 反向查询地理位置
        [geocoder reverseGeocodeLocation:self.currentLocation
                       completionHandler:^(NSArray *placemarks, NSError *erorr) {
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           NSLog(@"CityName: %@", placemark.locality);
                           self.currentCityName = placemark.locality;
                       }];
    }
}

#pragma mark - Fetch data

- (RACSignal *)updateCurrentConditions
{
    return [[self.client fetchCurrentConditionForLocation:self.currentLocation.coordinate]
            doNext:^(YWCondition *condition) {
                self.currentCondition = condition;
                NSLog(@"天气状况: %@", self.currentCondition.condition);
            }];
}

- (RACSignal *)updateHourlyForecast
{
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.hourlyForecast = conditions;
            }];
}

- (RACSignal *)updateDailyForecast
{
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.dailyForecast = conditions;
            }];
}



@end
