//
//  ChooseTypeTableView.h
//  zDateMatter
//
//  Created by hou on 15/4/1.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseTypeTableView : UIView<UITableViewDataSource>
@property(nonatomic,retain)UITableView*typeTableView;
@property(nonatomic,retain)NSMutableArray*typeArrayData;
@end
