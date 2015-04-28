//
//  WXCondition.m
//  SimpleWeather
//
//  Created by hou on 15/3/26.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "WXCondition.h"

@implementation WXCondition

+(NSDictionary*)imageMap
{
    //1
    static NSDictionary*_imageMap = nil;
    if (!_imageMap)
    {
        //2
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

//3
-(NSString*)imageName
{
    return [WXCondition imageMap][self.icon];
}

//JSON到模型属性的映射
+(NSDictionary*)JSONKeyPathsByPropertyKey
{
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

//为NSDate属性设置的转换器
+(NSValueTransformer*)dateJSONTransformer
{
    //1 使用blocks做属性的转换工作
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString*str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate*date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

//2
+(NSValueTransformer*)sunriseJSONTransformer
{
    return [self dateJSONTransformer];
}

+(NSValueTransformer*)sunsetJSONTransformer
{
    return [self dateJSONTransformer];
}

//array和string的转换
+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

#define MPS_TO_MPH 2.23694f
//每秒/米 -> 每小时/英里
+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}




























@end
