//
//  AppDelegate.m
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "AppDelegate.h"
#import <TSMessage.h>
#import "PublicModel.h"

//事件类型: 1次  每年  每月 每周(后两个暂时不考虑实现)
typedef enum _mMatterType {
    mMatterTypeOnce = 1,
    mMatterTypeYearly = 2,
    mMatterTypeMonthly = 3,
    mMatterTypeWeekly = 4
} mMatterType;

@interface AppDelegate ()
{
    NSTimer*timer;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    _mainViewController = [[MainViewController alloc]init];
    _wxViewController = [[WXViewController alloc]init];
    [TSMessage setDefaultViewController:_wxViewController];
    
    _navigationController = [[UINavigationController alloc]initWithRootViewController:_mainViewController];
    self.window.rootViewController = _navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //判断是否第一次使用
    NSString*key = (NSString*)kCFBundleVersionKey;
    NSString*version = [NSBundle mainBundle].infoDictionary[key];
    NSString*savedVersion = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    if ([version isEqualToString:savedVersion])
    {
        //非初次使用,不创建,直接读取plist内容
        [self readPlist];
    }
    else
    {
        //初次使用,创建plist文件并读取内容
        [[NSUserDefaults standardUserDefaults]setObject:version forKey:key];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self setupPlist];
    }
    
    return YES;
}

//创建plist文件
-(void)setupPlist
{
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*path = [paths objectAtIndex:0];
    NSString*fileName = [path stringByAppendingPathComponent:@"dateMatter.plist"];
    NSFileManager*fm = [NSFileManager defaultManager];
    [fm createFileAtPath:fileName contents:nil attributes:nil];
    
    NSMutableArray*arrayMemory = [[NSMutableArray alloc]init];
    NSMutableArray*arrayFuture = [[NSMutableArray alloc]init];
    
    NSNumber*number1 = [NSNumber numberWithInt:1];
    NSNumber*number2 = [NSNumber numberWithInt:2];
    [arrayMemory addObject:@{@"matter": @"yesterday",
                             @"date":[NSDate dateWithTimeIntervalSinceNow:-24*60*60],
                             @"type":number1
                             }];
    [arrayFuture addObject:@{@"matter": @"tomorrow",
                             @"date":[NSDate dateWithTimeIntervalSinceNow:24*60*60],
                             @"type": number2
                             }];
    NSMutableDictionary*dicRoot = [[NSMutableDictionary alloc]initWithObjectsAndKeys:arrayMemory,@"memory",arrayFuture,@"future", nil];
    
    [dicRoot writeToFile:fileName atomically:YES];
    
    _mDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
}
//直接读取plist文件
-(void)readPlist
{
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*path = [paths objectAtIndex:0];
    NSString*fileName = [path stringByAppendingPathComponent:@"dateMatter.plist"];
    _mDictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:fileName];
    //把future过去了的事情移动到memory中,而不存在memory变成future的情况
    //todo:以后可能会根据纪念日有memory变成future的情况
    [self moveObject];
}

//读取plist里的数据 第一个block是返回数组(过去or未来) 第二个block传递model 用法参见mainvc
-(void)readDictionaryBlock:(NSMutableArray* (^)())myBlock thenSave:(void (^)(PublicModel*))myBlock2
{
    NSArray*pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*path = [pathArray objectAtIndex:0];
    NSString*filePath = [path stringByAppendingPathComponent:@"dateMatter.plist"];
    _mDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableArray*array = myBlock();
    for (int i = 0; i<array.count; i++)
    {
        PublicModel*model = [[PublicModel alloc]init];
        NSDictionary*dic = [array objectAtIndex:i];
        model.mMatter = [dic objectForKey:@"matter"];
        model.mDate = [dic objectForKey:@"date"];
        model.mType = (int)[dic objectForKey:@"type"];
        myBlock2(model);
    }
    NSLog(@"读取当前plist中存在的事件:%@",_mDictionary);
}

//写入数据到plist中
-(void)writeDictionaryBlock:(void (^)())myBlock
{
    NSArray*pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*path = [pathArray objectAtIndex:0];
    NSString*filePath = [path stringByAppendingPathComponent:@"dateMatter.plist"];
    _mDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    myBlock();
    //按日期排序
    [self sortArrayAtKey:@"memory"];
    [self sortArrayAtKey:@"future"];
    [_mDictionary writeToFile:filePath atomically:YES];
}
-(void)sortArrayAtKey:(NSString*)key
{
    NSMutableArray*array = [_mDictionary objectForKey:key];
    NSArray*arrayNew = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate*date1 = [obj1 objectForKey:@"date"];
        NSDate*date2 = [obj2 objectForKey:@"date"];
        return [date1 compare:date2];
    }];
    [_mDictionary removeObjectForKey:key];
    NSMutableArray*arr = [NSMutableArray arrayWithArray:arrayNew];
    [_mDictionary setObject:arr forKey:key];
}
-(void)moveObject
{
    NSMutableArray*arrayMemory = [_mDictionary objectForKey:@"memory"];
    NSMutableArray*arrayFuture = [_mDictionary objectForKey:@"future"];
    for (int i = 0;i<arrayFuture.count;i++)
    {
        NSDictionary*dic = arrayFuture[i];
        if ([[dic objectForKey:@"date"]timeIntervalSinceNow]/60/60/24<0) {
            [arrayFuture removeObject:dic];
            [arrayMemory addObject:dic];
        }
    }
}

#pragma mark - notify user the coming things
//- (void)applicationWillResignActive:(UIApplication *)application {
//    //先去加载字典,遍历找到future里最近的日期,转化为相应的int,传给TodayViewController
//    
//}
//-(void)saveDefaults{
//    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.zDateMatterSharedDefaults"];
//    [userDefaults setInteger:timer.leftTime forKey:@"com.menghou.zDateMatter.lefttime"];
//    [userDefaults setInteger:[timer timeInterval] forKey:@"com.menghou.zDateMatter.quittime"];
//    [userDefaults synchronize];
//}
//-(void)clearDefaults{
//    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.zDateMatterSharedDefaults"];
//    [userDefaults removeObjectForKey:@"com.menghou.zDateMatter.lefttime"];
//    [userDefaults removeObjectForKey:@"com.menghou.zDateMatter.quittime"];
//    [userDefaults synchronize];
//}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
