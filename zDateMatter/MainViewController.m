//
//  MainViewController.m
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

#import "NewMatterViewController.h"
#import "WeatherVC/WeatherViewController.h"

#import "mainTableViewCell.h"

#import "PublicModel.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height
@interface MainViewController ()

@end

@implementation MainViewController
@synthesize mTableView;
@synthesize mArrayData;
@synthesize mSegment;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupData];
    
    [self setupTitle];
    [self setupBarButtonItem];
    [self setupSeg];
    [self setupTableView];
    
    //添加一个程序失去前台的监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self didChangeSegmentValue];
}

#pragma mark - setup UI

-(void)setupData
{
    mArrayData = [[NSMutableArray alloc]init];
}

-(void)setupTitle
{
    NSDate*date = [NSDate date];
    NSDateFormatter*fmt = [[NSDateFormatter alloc]init];
    
    [fmt setDateFormat:@"yyyy年MM月dd日"];
    NSString*string = [fmt stringFromDate:date];
    self.title = string;
}

-(void)setupBarButtonItem
{
    UIBarButtonItem*itemRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
    self.navigationItem.rightBarButtonItem = itemRight;
    
    UIBarButtonItem*itemLeft = [[UIBarButtonItem alloc]initWithTitle:@"天气" style:UIBarButtonItemStylePlain target:self action:@selector(seeWeather)];
    self.navigationItem.leftBarButtonItem = itemLeft;
}

//itemRight
-(void)addNewItem
{
    NewMatterViewController*nmvc = [[NewMatterViewController alloc]init];
    [self.navigationController pushViewController:nmvc animated:YES];
}
//itemLeft
-(void)seeWeather
{
    AppDelegate*appD = [[UIApplication sharedApplication]delegate];
    [[UIApplication sharedApplication]keyWindow].rootViewController = appD.wxViewController;
}

-(void)setupSeg
{
    mSegment = [[UISegmentedControl alloc]initWithItems:@[@"future",@"memory"]];
    mSegment.frame = CGRectMake(8, 8+64, WIDTH-16, 44);
    mSegment.selectedSegmentIndex = 0;
    [mSegment addTarget:self action:@selector(didChangeSegmentValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:mSegment];
}

-(void)setupTableView
{
    mTableView = [[UITableView alloc]initWithFrame:CGRectMake(8, 60+64, WIDTH-16, HEIGHT-60-64) style:UITableViewStylePlain];
    mTableView.rowHeight = 70.0f;
    mTableView.delegate = self;
    mTableView.dataSource = self;
    [self.view addSubview:mTableView];
}

#pragma mark - setup tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mArrayData.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*reuseId = @"mainCell";
    mainTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"mainTableViewCell" owner:self options:nil]lastObject];
    }
    PublicModel*model = [mArrayData objectAtIndex:indexPath.row];
    [cell setupDataWithModel:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete!");
        AppDelegate*appD = [[UIApplication sharedApplication]delegate];
        [appD writeDictionaryBlock:^{
            if (mSegment.selectedSegmentIndex == 0) {
                NSMutableArray*array = [appD.mDictionary objectForKey:@"future"];
                [array removeObjectAtIndex:indexPath.row];
                mArrayData = array;
            }
            else
            {
                NSMutableArray*array = [appD.mDictionary objectForKey:@"memory"];
                [array removeObjectAtIndex:indexPath.row];
                mArrayData = array;
            }
        }];
        [mTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

#pragma mark - method: segmentChange
-(void)didChangeSegmentValue
{
    [mArrayData removeAllObjects];
    AppDelegate*appD = [[UIApplication sharedApplication]delegate];
    if (mSegment.selectedSegmentIndex == 0)
    {
       [appD readDictionaryBlock:^NSMutableArray *{
           return [appD.mDictionary objectForKey:@"future"];
       } thenSave:^(PublicModel *model) {
           [mArrayData addObject:model];
       }];
    }
    else if (mSegment.selectedSegmentIndex == 1)
    {
        [appD readDictionaryBlock:^NSMutableArray *{
            return [appD.mDictionary objectForKey:@"memory"];
        } thenSave:^(PublicModel *model) {
            [mArrayData addObject:model];
        }];
    }
    [mTableView reloadData];
}

@end
