//
//  WXDailyForecast.m
//  SimpleWeather
//
//  Created by hou on 15/3/26.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

//对于预报,除了keyTemp都一样 修改键映射
+(NSDictionary*)JSONKeyPathsByPropertyKey
{
    //1
    NSMutableDictionary*paths = [[super JSONKeyPathsByPropertyKey]mutableCopy];
    //2
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    //3
    return paths;
}


@end
