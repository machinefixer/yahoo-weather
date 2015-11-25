//
//  AppDelegate.m
//  YahooWeather
//
//  Created by Anderson on 15/11/9.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//

#import "AppDelegate.h"
#import "YWMainViewController.h"
#import <TSMessage.h>

@interface AppDelegate ()

@property (nonatomic, strong) YWMainViewController *viewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    YWMainViewController *mainViewController = [[YWMainViewController alloc] init];
    
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
//    
//    // 设置导航条背景为透明
//    [navController.navigationBar setBackgroundImage:[UIImage new]
//                                      forBarMetrics:UIBarMetricsDefault];
//    navController.navigationBar.shadowImage = [UIImage new];
//    navController.navigationBar.translucent = YES;
//    
//    // 设置导航条标题
//    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
//                                                          NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18]}];
//    
//    // 设置根视图控制器
//    self.window.rootViewController = navController;
    
    self.viewController = mainViewController;
    self.window.rootViewController = self.viewController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [TSMessage setDefaultViewController:self.window.rootViewController];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
