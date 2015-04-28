//
//  WXViewController.m
//  SimpleWeather
//
//  Created by hou on 15/3/26.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "WXViewController.h"
#import "AppDelegate.h"
#import "WXManager.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#define FTOC /1.8-32/1.8
@interface WXViewController ()
<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property(nonatomic,strong)UIImageView*backgroundImageView;
@property(nonatomic,strong)UIImageView*blurredImageView;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,assign)CGFloat screenHeight;

@property(nonatomic,strong)NSDateFormatter*hourlyFormatter;
@property(nonatomic,strong)NSDateFormatter*dailyFormatter;

@end

@implementation WXViewController

-(id)init
{
    self = [super init];
    if (self) {
        _hourlyFormatter = [[NSDateFormatter alloc]init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc]init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.获取并存储屏幕高度
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImage*background = [UIImage imageNamed:@"bg"];
    
    //2.创建静态背景图,并添加到视图上
    self.backgroundImageView = [[UIImageView alloc]initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    //3.创建一个模糊的背景图像,设置alpha为0
    self.blurredImageView = [[UIImageView alloc]init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    //4.创建tableView
    self.tableView = [[UITableView alloc]init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    // 1设置header大小与屏幕相同
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // 2创建inset变量,方便标签均匀分布居中
    CGFloat inset = 20;
    // 3创建各种高度变量
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    // 4给label和view创建框架
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height-60 - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height-60 - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y-60 - iconHeight,
                                  iconHeight,
                                  iconHeight);
    // 5复制图标框使文本有扩展空间
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    // 1 设置当前View 是tableHeader
    UIView *header = [[UIView alloc] init];
    [header setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60)];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 2 构建每个显示气象数据的标签
    // bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    
    // 3 添加天气图标的图像视图
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit; 
    iconView.backgroundColor = [UIColor clearColor]; 
    [header addSubview:iconView];
    
    // 1 kvo单例的kCondition
    [[RACObserve([WXManager sharedManager], currentCondition)
      // 2 传递在主线程上的任何变化 因为正在更新ui
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         // 3 使用气象数据更新文本标签
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         
         // 4 使用映射图像文件名创建一个图像并设置为视图图标
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    [[RACObserve([WXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    // 1 宏保持语法整洁
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       // 2 观察高温低温 合并信号
                                                       RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                             // 3从合并信号中减少树枝 转换成单一数据
                                                        reduce:^(NSNumber *hi, NSNumber *low) {
                                                        return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue ,low.floatValue ];
                                                        }]
                            // 4 传递到主线程
                                                        deliverOn:RACScheduler.mainThreadScheduler];
    
    [[WXManager sharedManager]findCurrentLocation];
}

//1
#pragma mark - UITableViewDataSource  tableView有两部分,一个是每小时的天气预报,另一个用于每日播报

//2
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //1逐时预报
    if (section == 0) {
        return MIN([[WXManager sharedManager].hourlyForecast count], 6) +1;
    }
    //2逐日预报
    return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*cellId = @"cellId";
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleValue1
                                     reuseIdentifier:cellId];
    }
    //3
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        // 1标题单元格
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            // 2 获取每小时天气和使用自定义配置方法配置cell
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    else if (indexPath.section == 1) {
        // 1
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            // 3 获取每天天气并用另一个方法
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather]; 
        } 
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return (self.screenHeight-60) / (CGFloat)cellCount;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
#pragma mark - 改了tv的frame 加了返回按钮
    self.tableView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
    UIButton*btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    [btn addTarget:self action:@selector(backto) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"back" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}
-(void)backto{
    AppDelegate*appD = [[UIApplication sharedApplication]delegate];
    [[UIApplication sharedApplication]keyWindow].rootViewController = appD.navigationController;
}

//让状态栏更清楚
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 1 配置和添加文本到作为section页眉单元格
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

// 2 格式化逐时预报单元格
- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

// 3 格式化每日预报单元格
- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                 weather.tempHigh.floatValue ,
                                 weather.tempLow.floatValue ];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UIScrollViewDelegate
//实现模糊
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 2
    CGFloat percent = MIN(position / height, 1.0);
    // 3
    self.blurredImageView.alpha = percent;
}









































/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
