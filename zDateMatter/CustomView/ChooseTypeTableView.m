//
//  ChooseTypeTableView.m
//  zDateMatter
//
//  Created by hou on 15/4/1.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "ChooseTypeTableView.h"

@implementation ChooseTypeTableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setupViews];
    
    return self;
}

-(void)setupViews
{
    [self setupTableView];
    [self setupArray];
}

-(void)setupTableView
{
    _typeTableView = [[UITableView alloc]initWithFrame:self.bounds];
    _typeTableView.dataSource = self;
    [self addSubview:_typeTableView];
}

-(void)setupArray
{
    _typeArrayData = [[NSMutableArray alloc]initWithArray:@[@"once",@"yearly",@"monthly",@"weekly"]];
}

#pragma mark - tableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _typeArrayData.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*reuseId = @"chooseTypeCell";
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.textLabel.text = _typeArrayData[indexPath.row];
    return cell;
}
@end
