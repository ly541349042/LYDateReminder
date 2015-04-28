//
//  mainTableViewCell.m
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "mainTableViewCell.h"

@implementation mainTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setupDataWithModel:(PublicModel *)model
{
    //事件
    self.mMatter.text = model.mMatter;
    
    //时间:如果是过去的那么mtype显示(已过)如果是未来的那么mtype显示(还有)
    //天数:mDate-当前就是还有多少天
    float days = [model.mDate timeIntervalSinceNow]/60/60/24;
    if (days>=0) {
        self.mType.text = @"还有";
        self.mDate.text = [NSString stringWithFormat:@"%.0f天",days];
    }
    else{
        self.mType.text = @"已过";
        self.mDate.text = [NSString stringWithFormat:@"%.0f天",0-days];
    }
    //TODO:背景色:自己做几张图加到backgroundView上就行了.
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
