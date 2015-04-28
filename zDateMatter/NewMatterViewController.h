//
//  NewMatterViewController.h
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import <UIKit/UIKit.h>

//事件类型: 1次  每年  每月 每周(后两个暂时不考虑实现)
typedef enum _mMatterType {
    mMatterTypeOnce = 1,
    mMatterTypeYearly = 2,
    mMatterTypeMonthly = 3,
    mMatterTypeWeekly = 4
} mMatterType;

@interface NewMatterViewController : UIViewController

@property(nonatomic,retain)NSDate*mDate;
@property(nonatomic,retain)NSString*mMatter;

@property(nonatomic,assign)int mType;

@end
