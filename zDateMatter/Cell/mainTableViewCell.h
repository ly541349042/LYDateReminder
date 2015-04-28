//
//  mainTableViewCell.h
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicModel.h"
@interface mainTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mMatter;
@property (weak, nonatomic) IBOutlet UILabel *mDate;
@property (weak, nonatomic) IBOutlet UILabel *mType;

//周期
@property(nonatomic,assign)int mTimes;

-(void)setupDataWithModel:(PublicModel*)model;
@end
