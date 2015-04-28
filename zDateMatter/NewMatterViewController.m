//
//  NewMatterViewController.m
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "NewMatterViewController.h"
#import "ChooseTypeTableView.h"
#import "AppDelegate.h"
@interface NewMatterViewController ()<UITextFieldDelegate,UITableViewDelegate>

@property(nonatomic,retain)UILabel*mMatterLabel;
@property(nonatomic,retain)UITextField*mMatterTF;

@property(nonatomic,retain)UILabel*mTypeLabel;
@property(nonatomic,retain)UIButton*mTypeSelectButton;
@property(nonatomic,retain)ChooseTypeTableView*mChooseView;

@property(nonatomic,retain)UILabel*mDateLabel;
@property(nonatomic,retain)UILabel*mChooseDateLabel;

@property(nonatomic,retain)UIDatePicker*mDatePicker;

@end

@implementation NewMatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加新事件";
    self.navigationItem.leftBarButtonItem.title = @"返回";
    
    _mMatterLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 72, 50, 44)];
    _mMatterLabel.text = @"事件";
    _mMatterLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_mMatterLabel];
    
    _mMatterTF = [[UITextField alloc]initWithFrame:CGRectMake(66, 72, 246, 44)];
    _mMatterTF.delegate = self;
    _mMatterTF.borderStyle = UITextBorderStyleRoundedRect;
    _mMatterTF.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_mMatterTF];
    
    _mTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 176, 50, 44)];
    _mTypeLabel.text = @"类型";
    _mTypeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_mTypeLabel];
    
    _mTypeSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 176, 150, 44)];
    [_mTypeSelectButton setTitle:@"请选择" forState:UIControlStateNormal];
    _mTypeSelectButton.backgroundColor = [UIColor redColor];
    [_mTypeSelectButton addTarget:self action:@selector(pressSelectButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_mTypeSelectButton];
    
    _mChooseView = [[ChooseTypeTableView alloc]initWithFrame:CGRectMake(100, 176, 150, 44*4)];
    _mChooseView.typeTableView.delegate = self;
    _mChooseView.hidden = YES;
    [self.view addSubview:_mChooseView];
    
    _mDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 124, 50, 44)];
    _mDateLabel.text = @"日期";
    _mDateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_mDateLabel];
    
    _mChooseDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(100,124,150,44)];
    NSDate*date = [NSDate date];
    NSDateFormatter*fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy年MM月dd日";
    NSString*str = [fmt stringFromDate:date];
    _mChooseDateLabel.text = str;
    _mChooseDateLabel.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(tapToShowDatePicker)];
    _mChooseDateLabel.userInteractionEnabled = YES;
    [_mChooseDateLabel addGestureRecognizer:tap];
    [self.view addSubview:_mChooseDateLabel];
    
    _mDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-216, self.view.frame.size.width, 216)];
    _mDatePicker.datePickerMode = UIDatePickerModeDate;
    [_mDatePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    _mDatePicker.hidden = YES;
    [self.view addSubview:_mDatePicker];
}

#pragma method - UITextFieldDelegate
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_mMatterTF resignFirstResponder];
    _mDatePicker.hidden = YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_mMatterTF resignFirstResponder];
    _mMatter = _mMatterTF.text;
}

#pragma mark - UIButton
-(void)pressSelectButton
{
    _mChooseView.hidden = !_mChooseView.hidden;
}

#pragma mark - typeTableView
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell = [tableView cellForRowAtIndexPath:indexPath];
    _mType = (int)indexPath.row+1;
    NSString*string = cell.textLabel.text;
    [_mTypeSelectButton setTitle:string forState:UIControlStateNormal];
    _mChooseView.hidden = YES;
}

#pragma mark - DatePicker
-(void)tapToShowDatePicker
{
    _mDatePicker.hidden = !_mDatePicker.hidden;
}

-(void)dateChanged:(id)sender
{
    UIDatePicker*control = (UIDatePicker*)sender;
    NSDate*date = control.date;
    NSDateFormatter*fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy年MM月dd日"];
    NSString*string = [fmt stringFromDate:date];
    _mChooseDateLabel.text = string;
}

#pragma mark - info add to plist
- (NSDate *)dateFromString:(NSString *)string
{
    //2012年1月1日
    if (!string) return nil;
    NSDateFormatter *dateformatter=dateformatter = [[NSDateFormatter alloc] init];
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateformatter setTimeZone:tz];
    [dateformatter setDateFormat:@"yyyy年MM月dd日"];;
    return [dateformatter dateFromString:string];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _mMatter = _mMatterTF.text;
    _mDate = [self dateFromString:_mChooseDateLabel.text];
    if (_mType > 4 || _mType < 1)
    {
        return;
    }
    if ([_mMatter isEqualToString:@""]) {
        return;
    }
    NSDictionary*dic = @{@"matter": _mMatter,
                         @"date":_mDate,
                         @"type":[NSNumber numberWithInt:_mType]
                         };
    AppDelegate*appD = [[UIApplication sharedApplication]delegate];
    [appD writeDictionaryBlock:^{
        if ([_mDate timeIntervalSinceNow]>=0) {
            NSMutableArray*array = [appD.mDictionary objectForKey:@"future"];
            [array addObject:dic];
        }
        else
        {
            NSMutableArray*array = [appD.mDictionary objectForKey:@"memory"];
            [array addObject:dic];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
