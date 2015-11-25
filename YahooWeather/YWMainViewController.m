//
//  YWMainViewController.m
//  YahooWeather
//
//  Created by Anderson on 15/11/24.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//

#import "YWMainViewController.h"
#import "YWCenterViewController.h"
#import "YWLeftPanelViewController.h"

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define SLIDE_TIMING 0.3
#define PANEL_WIDTH 60

@interface YWMainViewController () <YWCenterViewControllerDelegate>

@property (nonatomic, strong) YWCenterViewController *centerViewController;
@property (nonatomic, strong) YWLeftPanelViewController *leftPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showPanel;

@end

@implementation YWMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView
{
    // 设置中间的视图控制器
    self.centerViewController = [[YWCenterViewController alloc] init];
    self.centerViewController.view.tag = CENTER_TAG;
    self.centerViewController.delegate = self;
    
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:self.centerViewController];
    
    [self.centerViewController didMoveToParentViewController:self];
}

- (UIView *)getLeftView
{
    if (self.leftPanelViewController == nil) {
        // 载入左侧 panel
        UIStoryboard *leftPanelViewControllerStoryboard = [UIStoryboard storyboardWithName:@"YWLeftPanelViewController" bundle:nil];
        self.leftPanelViewController = [leftPanelViewControllerStoryboard instantiateViewControllerWithIdentifier:@"leftPanelViewController"];
        self.leftPanelViewController.view.tag = LEFT_PANEL_TAG;
        
        [self.view addSubview:self.leftPanelViewController.view];
        [self addChildViewController:_leftPanelViewController];
        [self.leftPanelViewController didMoveToParentViewController:self];
        
        self.leftPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.showingLeftPanel = YES;
    
    // 设置阴影
    [self showCenterViewWithShadow:YES withOffset:-2];
    
    UIView *view = self.leftPanelViewController.view;
    return view;
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        [_centerViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_centerViewController.view.layer setShadowOpacity:0.8];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, -offset)];
    }
    else {
        [_centerViewController.view.layer setCornerRadius:0.0f];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, -offset)];
    }
}

- (void)resetMainView
{
    // 移除左视图并重置相关变量
    if (self.leftPanelViewController != nil) {
        [self.leftPanelViewController.view removeFromSuperview];
        self.leftPanelViewController = nil;
        
        self.centerViewController.navigationItem.leftBarButtonItem.tag = 1;
        self.showingLeftPanel = NO;
    }
    
    // remove view shadows
    [self showCenterViewWithShadow:NO withOffset:0];
}


#pragma mark - YWCenterViewController delegate

- (void)movePanelRight
{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.centerViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH,
                                                                       0,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height);
                     }completion:^(BOOL finished) {
                         if (finished) {
                             self.centerViewController.navigationItem.leftBarButtonItem.tag = 0;
                         }
                     }];
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.centerViewController.view.frame = CGRectMake(0,
                                                                       0,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

@end
