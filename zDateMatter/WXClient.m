//
//  WXClient.m
//  SimpleWeather
//
//  Created by hou on 15/3/26.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"
@interface WXClient()
//用来管理API请求的URL session
@property(nonatomic,strong)NSURLSession*session;
@end
@implementation WXClient
-(id)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration*config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

//创建一个对象给其他方法和对象使用(工厂模式)
-(RACSignal*)fetchJSONFromURL:(NSURL *)url
{
    NSLog(@"Fetching:%@",url.absoluteString);
    //1返回信号.只有信号被订阅时才会返回.
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //2创建一个datadask从url取数据
        NSURLSessionDataTask*dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSError*jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    //1正常发数组/字典
                    [subscriber sendNext:json];
                }
                else{
                    [subscriber sendError:jsonError];
                }
            }
            else{
                //2通知订阅者有错误
                [subscriber sendError:error];
            }
            //3通知订阅者请求已完成
            [subscriber sendCompleted];
        }];
        //3一旦订阅了信号,启动网络请求
        [dataTask resume];
        //4创建并返回racdisposable对象 信号摧毁时负责清理
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }]doError:^(NSError *error) {
        //5记录错误
        NSLog(@"%@",error);
    }];
}

//获取当前状况
-(RACSignal*)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
    // 1用经纬度数据格式化URL
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial&lang=zh_cn",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    // 2用刚建立的创建信号的方法,返回值映射到nsdic
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 3转换json到wxcondition对象
        return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
    }];
}

//获取逐时预报
-(RACSignal*)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12&lang=zh_cn",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 1映射json
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 2创建RACSequence 对列表进行rac操作
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // 3映射新的对象列表
        return [[list map:^(NSDictionary *item) {
            // 4转换json到wxcondition对象
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
            // 5
        }] array];
    }];
}

//获取每日预报
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7&lang=zh_cn",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}































@end
