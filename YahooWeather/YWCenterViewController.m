//
//  YWCenterViewController.m
//  YahooWeather
//
//  Created by Anderson on 15/11/21.
//  Copyright © 2015年 Yuchen Zhan. All rights reserved.
//
//  TODO: 下拉刷新
//  TODO: 根据城市请求对应的城市图片作为背景

#import "YWCenterViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "YWManager.h"

@interface YWCenterViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;
@property (nonatomic, assign) CGFloat screenHeight;

@end

@implementation YWCenterViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hourlyFormatter = [[NSDateFormatter alloc] init];
        self.hourlyFormatter.dateFormat = @"h a";
        
        self.dailyFormatter = [[NSDateFormatter alloc] init];
        self.dailyFormatter.dateFormat = @"EEEE";
        
        // 设置 NavigationBar
        UINavigationItem *navItem = self.navigationItem;
        UIImage *menuButtonImage = [UIImage imageNamed:@"Menu"];
        UIImage *addButtonImage = [UIImage imageNamed:@"Add"];
        UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:menuButtonImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(btnMovePanelRight)];
        UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:addButtonImage
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(btnShowCitySearchingView)];
        menuBarButtonItem.tintColor = [UIColor whiteColor];
        addBarButtonItem.tintColor = [UIColor whiteColor];
        
        navItem.leftBarButtonItem = menuBarButtonItem;
        navItem.rightBarButtonItem = addBarButtonItem;
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    // 背景图平铺
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    // 模糊遮罩层一开始为透明
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    // 利用视图的 paging 把 UITableView 的主体部分撑到下一页去，第一页放 header
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20; // 内边距
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - temperatureHeight - hiloHeight,
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (2 * inset) - iconHeight - 10;
    conditionsFrame.origin.x = iconFrame.origin.x + iconHeight + 10;
    
    // 设置 UITableView 的 tableHeaderView 以及组装各个 Label 到 tableHeaderView 里
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 温度标签
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // 最高最低温标签
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // 天气状况标签
    UILabel *conditionLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionLabel.backgroundColor = [UIColor clearColor];
    conditionLabel.textColor = [UIColor whiteColor];
    conditionLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:18];
    [header addSubview:conditionLabel];
    
    // 天气状况图标
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    // 刷新地理位置
    [[YWManager sharedManager] findCurrentLocation];
    
    // 更新视图
    [[RACObserve([YWManager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(YWCondition *newCondition) {
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°", newCondition.temperature.floatValue];
         conditionLabel.text = [newCondition.condition capitalizedString];
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    // 更新 NavigationItem 标题
    [[RACObserve([YWManager sharedManager], currentCityName)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSString *newCityName) {
         self.navigationItem.title = newCityName;
     }];
    
    // 使用最新的数据整合 high 和 low 值
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       RACObserve([YWManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([YWManager sharedManager], currentCondition.tempLow)]
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString stringWithFormat:@"%.0f° / %.0f°", hi.floatValue, low.floatValue];
                                              }]
                            deliverOn:RACScheduler.mainThreadScheduler];
    
    // 更新 UITableView 中的数据并刷新
    [[RACObserve([YWManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newHourlyForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([YWManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newDailyForecast) {
         [self.tableView reloadData];
     }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section) {
        case 0:
            // 只显示未来 12 小时的天气，外加一个 header cell
            return MIN([[YWManager sharedManager].hourlyForecast count], 12) + 1;
            break;
            
        case 1:
            // 只显示未来 6 天的天气，外加一个 header cell
            return MIN([[YWManager sharedManager].dailyForecast count], 6) + 1;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    // 设置 UITableViewCell
    switch(indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                [self configureHeaderCell:cell title:@"预报"];
            }
            else {
                YWCondition *weather = [YWManager sharedManager].hourlyForecast[indexPath.row - 1];
                [self configureHourlyCell:cell weather:weather];
                NSLog(@"row: %ld", (long)indexPath.row);
            }
            break;
            
        case 1:
            if (indexPath.row == 0) {
                [self configureHeaderCell:cell title:@"一周天气"];
            }
            else {
                YWCondition *weather = [YWManager sharedManager].dailyForecast[indexPath.row - 1];
                [self configureDailyCell:cell weather:weather];
            }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

// 设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

// 设置 Section 间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

// 设置 Section 空隙的颜色，否则会有一块白色在 Section 之间
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 20)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    CGRect tableViewFrame = CGRectMake(self.view.bounds.origin.x + 10,
                                       self.view.bounds.origin.y,
                                       self.view.bounds.size.width - 20,
                                       self.view.bounds.size.height);
    self.blurredImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = tableViewFrame;
}

// 滑动时逐渐模糊背景
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    
    self.blurredImageView.alpha = percent;
}

#pragma mark - UITableViewCell Configuration
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(YWCondition *)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°", weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}
- (void)configureDailyCell:(UITableViewCell *)cell weather:(YWCondition *)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°", weather.tempHigh.floatValue, weather.tempLow.floatValue];
    
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UINavigation Button Action
- (void)btnMovePanelRight
{
    [self.delegate movePanelRight];
}

- (void)btnShowCitySearchingView
{
}



@end
