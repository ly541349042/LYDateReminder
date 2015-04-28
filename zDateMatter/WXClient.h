//
//  WXClient.h
//  SimpleWeather
//
//  Created by hou on 15/3/26.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
//RAC用于函数式反应型编程,提供组合和转化数据流的API
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface WXClient : NSObject
-(RACSignal*)fetchJSONFromURL:(NSURL*)url;
-(RACSignal*)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
-(RACSignal*)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
-(RACSignal*)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
