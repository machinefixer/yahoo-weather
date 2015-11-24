//
//  YWCenterViewController.h
//  YahooWeather
//
//  Created by Anderson on 15/11/21.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YWCenterViewControllerDelegate <NSObject>

@optional
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end

@interface YWCenterViewController : UIViewController

@property (nonatomic, assign) id<YWCenterViewControllerDelegate> delegate;

@end
