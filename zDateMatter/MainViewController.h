//
//  MainViewController.h
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)UITableView*mTableView;
@property(nonatomic,retain)NSMutableArray*mArrayData;
@property(nonatomic,retain)UISegmentedControl*mSegment;


@end
