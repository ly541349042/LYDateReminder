//
//  WXManager.h
//  SimpleWeather
//
//  Created by hou on 15/3/26.
//  Copyright (c) 2015年 hou. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>
// 1 没有用wxdailyforecast
#import "WXCondition.h"

@interface WXManager : NSObject
<CLLocationManagerDelegate>

// 2子类将返回适当的类型
+ (instancetype)sharedManager;

// 3存储数据
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// 4启动or刷新整个位置和天气的查找过程
- (void)findCurrentLocation;

@end
