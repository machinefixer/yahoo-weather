//
//  YWClient.m
//  YahooWeather
//
//  Created by Anderson on 15/11/9.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//

#import "YWClient.h"
#import "YWDailyForecast.h"

// API Key
static NSString * const weatherAPIKey = @"";
static NSString * const baseRequestString = @"http://api.openweathermap.org/data/2.5";

@interface YWClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation YWClient

- (id)init
{
    self = [super init];
    
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url
{
    NSLog(@"Fetching: %@", url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session
                                          dataTaskWithURL:url
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (!error) {
                                                  NSError *jsonError = nil;
                                                  
                                                  // JSON 转为 Objective-C 对象
                                                  id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                                  
                                                  if (!jsonError) {
                                                      [subscriber sendNext:json];
                                                  } else {
                                                      [subscriber sendError:jsonError];
                                                      NSLog(@"JSON ERROR!");
                                                  }
                                              } else {
                                                  [subscriber sendError:error];
                                              }
                                              
                                              [subscriber sendCompleted];
                                          }];
        
        [dataTask resume];
        
        // 在 Subscription 被取消或清除时做一些清理操作
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (RACSignal *)fetchCurrentConditionForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString
                           stringWithFormat:@"%@/weather?lat=%f&lon=%f&units=metric&appid=%@",
                           baseRequestString,
                           coordinate.latitude,
                           coordinate.longitude,
                           weatherAPIKey];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 用 Mantle 的 JSON 适配器把 JSON 转换成 YWCondition 对象
        return [MTLJSONAdapter modelOfClass:[YWCondition class]
                         fromJSONDictionary:json
                                      error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    // 返回 16 条
    NSString *urlString = [NSString
                           stringWithFormat:@"%@/forecast?lat=%f&lon=%f&units=metric&cnt=16&appid=%@",
                           baseRequestString,
                           coordinate.latitude,
                           coordinate.longitude,
                           weatherAPIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 把字典做成一个 RACSequence
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // 把 RACSequence 中的元素转成 Mantle 模型对象
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[YWCondition class]
                             fromJSONDictionary:item
                                          error:nil];
        // 把返回的新的 RACSequence 转成 NSArray
        }] array];
    }];
    
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    // 获取最近一周的天气
    NSString *urlString = [NSString
                           stringWithFormat:@"%@/forecast/daily?lat=%f&lon=%f&units=metric&cnt=7&appid=%@",
                           baseRequestString,
                           coordinate.latitude,
                           coordinate.longitude,
                           weatherAPIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        RACSequence *list = [json[@"list"] rac_sequence];
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[YWDailyForecast class]
                             fromJSONDictionary:item
                                          error:nil];
        }] array];
    }];
}

@end
