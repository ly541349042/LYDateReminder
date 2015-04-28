//
//  TodayViewController.m
//  NotificationTest
//
//  Created by hou on 15/4/15.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.zDateMatterSharedDefaults"];
    NSInteger timeOut = [userDefaults integerForKey:@"com.menghou.zDateMatter.lefttime"];
    NSInteger quitDate =[userDefaults integerForKey:@"com.menghou.zDateMatter.quitdate"];
    
    NSDate *passTimeFromQuit = [[NSDate alloc]initWithTimeInterval:NSTimeIntervalSince1970 sinceDate:[NSDate dateWithTimeIntervalSince1970:quitDate]];
    
    int leftTime = (int)timeOut - (int)passTimeFromQuit;
    _mNotiLabel.text = [NSString stringWithFormat:@"%d",leftTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
