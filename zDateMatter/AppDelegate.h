//
//  AppDelegate.h
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

//it's a date matter to keep date for past and future.

//simple function:
//1.tell you the number of days past or left;
//2.automatically compare your dates and help you to keep them in order.
//3.see weather of your locations,also the forecast.

//todo:
//1.make it possible to separate dates' type, like once,yearly,monthly,weekly,etc.
//2.if a  once type date change status from future to memory,move it.
//3.add a notification bar in the notification center,you can see your nearest coming matter from your notification center.
//4.add a watch kit support. if you use apple watch you can also check the coming matter from your watch, like the notification center.


#import <UIKit/UIKit.h>
#import "PublicModel.h"
#import "MainViewController.h"
#import "WXViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,retain)MainViewController*mainViewController;
@property(nonatomic,retain)UINavigationController*navigationController;

@property(nonatomic,retain)WXViewController*wxViewController;

@property(nonatomic,retain)NSMutableDictionary*mDictionary;
//读取和写入plist的block方法
-(void)readDictionaryBlock:(NSMutableArray*(^)())myBlock thenSave:(void(^)(PublicModel*))myBlock2;
-(void)writeDictionaryBlock:(void(^)())myBlock;

@end

