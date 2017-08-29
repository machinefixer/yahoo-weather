//
//  YWAPIManager.m
//  YahooWeather
//
//  Created by yuchen on 2017/8/29.
//  Copyright © 2017年 Yuchen Zhan. All rights reserved.
//

#import "YWAPIManager.h"
#import "YWAPIKeyProvider-Swift.h"
#import <AFNetworking/AFNetworking.h>

static const NSString *baseURL = @"https://api.openweathermap.org/data/2.5";

@interface YWAPIManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation YWAPIManager

+ (instancetype)sharedManager {
    static YWAPIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YWAPIManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    } else {
        _sessionManager = [[AFHTTPSessionManager alloc] init];
    }
    return self;
}

#pragma mark - Request Template
- (void)sendRequest:(NSURLRequest *)request
            success:(void (^)(NSURLResponse *response, id responseObject))success
            failure:(void (^)(NSError *error))failure
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[_sessionManager dataTaskWithRequest:request
                       completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                           if (!error) {
                               NSLog(@"Response: %@", responseObject);
                               if (success) {
                                   success(responseObject, responseObject);
                               }
                           } else {
                               NSLog(@"Request Error: %@", error);
                               if (failure) {
                                   failure(error);
                               }
                           }
                           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                       }] resume];
    
}

@end
