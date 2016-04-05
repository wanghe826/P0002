//
//  HistoryViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 16/3/2.
//  Copyright © 2016年 ZeroSoft. All rights reserved.
//

#import "HistoryViewController.h"
#import "FetchSportDataUtil.h"
#import "Masonry.h"
#import "FitnessViewController.h"
#import "SportDetailView.h"
#import "UMSocial.h"

#import "PersonInfoModel.h"

#define DAY_TAG 1
#define WEEK_TAG 2
#define MONTH_TAG 3

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray* _allDays;
    NSArray* _allMonths;
    NSArray* _allWeeks;
    
    UITableView* _tableView;
    
    float _rateOfDay;
    float _rateOfWeek;
    float _rateOfMonth;
    
    NSUInteger _currentTag;
    
    NSArray* _daysOfEveryWeek;
    NSArray* _daysOfEveryMonth;
    
    NSIndexPath* _currentSelectIndex;
    
    UILabel* _dateLabel;
    UILabel* _dateDataLabel;
    
    SportDetailView* _detailView;
    
    
    void (^_refreshView)(UILabel* dateLabel, UILabel* dateDataLabel);
    
}
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
    
    _allDays = @[@{NSLocalizedString(@"今天", nil):@(0)}];
    _allMonths = @[@{NSLocalizedString(@"本月", nil):@(0)}];
    _allWeeks = @[@{NSLocalizedString(@"本周", nil):@(0)}];
    
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void) layoutUI
{
    self.navigationController.navigationBarHidden = YES;
    
    CGFloat backViewHeight = 0;
    
    if(screen_height==667 || screen_height==736)
    {
        backViewHeight = screen_height/1.2 - 15;
    }
    else
    {
        backViewHeight = screen_height/1.2 - 50;
    }
    
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, screen_width, backViewHeight)];
    backgroundView.backgroundColor = RGBColor(0xe1, 0x65, 0x28);
    [self.view addSubview:backgroundView];
    
    UIView* tabView = [[UIView alloc] initWithFrame:CGRectZero];
    tabView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [self.view addSubview:tabView];
    [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backgroundView.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(@(35));
    }];
    
    
    
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont systemFontOfSize:17]];
    titleLabel.text = NSLocalizedString(@"运动健康", nil);
    titleLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
    titleLabel.center = CGPointMake(self.view.center.x, 44);
    [self.view addSubview:titleLabel];
    
    UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
            [shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.right.equalTo(self.view).with.offset(-20);
        maker.centerY.equalTo(titleLabel);
        maker.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _dateLabel.text = NSLocalizedString(@"今日", nil);
    _dateLabel.textColor = HexRGBAlpha(0xfdfdfd, 0.5);
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    [_dateLabel setFont:[UIFont systemFontOfSize:12]];
    _dateLabel.hidden = YES;
    [self.view addSubview:_dateLabel];
    _dateLabel.center = CGPointMake(self.view.center.x, 64);
    
    _dateDataLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _dateDataLabel.textColor = [UIColor whiteColor];
    [_dateDataLabel setFont:[UIFont systemFontOfSize:13]];
    _dateDataLabel.textAlignment = NSTextAlignmentCenter;
    _dateDataLabel.hidden = YES;
    [_dateDataLabel sizeToFit];
    [self.view addSubview:_dateDataLabel];
    [_dateDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(_dateLabel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    
    CGFloat tableViewWidth = screen_height/1.5;
    if(screen_height==480)
    {
        tableViewWidth = screen_height/1.5-70;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, tableViewWidth, screen_width) style:UITableViewStylePlain];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.center = CGPointMake(self.view.center.x, self.view.center.y);
    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    
    UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableViewWidth, screen_width/2)];
    _tableView.tableHeaderView = headView;
    _tableView.tableFooterView = headView;
    
    [self.view addSubview:_tableView];
    
#pragma 增加-按钮
    UIView* decreaseView = [[UIView alloc] initWithFrame:CGRectZero];
    decreaseView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [self.view addSubview:decreaseView];
//    [self.view bringSubviewToFront:decreaseView];
    
    [decreaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tabView.mas_left).offset(0);
        make.centerY.mas_equalTo(tabView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    UIButton* decreaseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [decreaseBtn setImage:[UIImage imageNamed:@"btn_sport_reduce_yes"] forState:UIControlStateNormal];
    [decreaseBtn addTarget:self action:@selector(decreaseAction) forControlEvents:UIControlEventTouchUpInside];
    [decreaseView addSubview:decreaseBtn];
    [decreaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(decreaseView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
#pragma 增加+按钮
    UIView* increaseView = [[UIView alloc] initWithFrame:CGRectZero];
    increaseView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [self.view addSubview:increaseView];
    
    [increaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(tabView.mas_right).offset(0);
        make.centerY.mas_equalTo(tabView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    UIButton* increaseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [increaseBtn setImage:[UIImage imageNamed:@"btn_sport_increase_yes"] forState:UIControlStateNormal];
    [increaseBtn addTarget:self action:@selector(increaseAction) forControlEvents:UIControlEventTouchUpInside];
    [increaseView addSubview:increaseBtn];
    [increaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(increaseView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    UIView* trangleView = [[UIView alloc] initWithFrame:CGRectZero];
    trangleView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [self.view insertSubview:trangleView belowSubview:_tableView];
    [trangleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(tabView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.bottom.mas_equalTo(tabView.mas_bottom).offset(-15);
    }];
    trangleView.transform = CGAffineTransformMakeRotation(M_PI_4);
    
    [self createSportDetailView:tabView];
    
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, backViewHeight - 20 - 19, screen_width, 1)];
    lineLabel.backgroundColor = HexRGBAlpha(0xffffff, 1.0f);
    lineLabel.tag = 328001;
    lineLabel.alpha = 0.2;
    [self.view addSubview:lineLabel];
    
    UILabel *lineTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, screen_width, 20)];
    lineTextLabel.tag = 328002;
    lineTextLabel.font = [UIFont systemFontOfSize:12];
    lineTextLabel.textColor = HexRGBAlpha(0xffffff, 1.0f);
    lineTextLabel.text = [NSString stringWithFormat:@"%@ %ld %@", NSLocalizedString(@"目标", nil) ,[[[NSUserDefaults standardUserDefaults] objectForKey:FootTargetKey] integerValue], NSLocalizedString(@"步", nil)];
    lineTextLabel.textAlignment = NSTextAlignmentCenter;
    [lineLabel addSubview:lineTextLabel];
}

- (void) createSportDetailView:(UIView*)tabView;
{
    UIView* containView = [[UIView alloc] initWithFrame:CGRectZero];
    containView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containView];
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-40);
        make.top.mas_equalTo(tabView.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
    }];
    
    
    _detailView = [SportDetailView sportDetailViewWithFrame:CGRectMake(0, 0, screen_width, 100)];
    _detailView.backgroundColor = [UIColor whiteColor];
    [containView addSubview:_detailView];
    [_detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(containView);
        make.edges.mas_equalTo(UIEdgeInsetsMake(-5, 5, -5, 5));
    }];
    
}

- (void) rotationTheTableView:(NSDictionary*)dic withIndex:(NSInteger)index
{
    [_tableView setContentOffset:CGPointMake(0, _allDays.count*50-25) animated:YES];
    _dateDataLabel.hidden = NO;
    _dateLabel.hidden = NO;
    _dateLabel.text = [[dic allKeys] firstObject];
    _dateDataLabel.text = [NSString stringWithFormat:@"%ld %@", [[[dic allValues] firstObject] integerValue],NSLocalizedString(@"步", nil)];
    [self refreshSportDetailView:dic withIndex:0];
}

- (void) initData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _allDays = [FetchSportDataUtil fetchAllDaysSportData];
        _rateOfDay = [self heightRate:_allDays];
        _currentTag = DAY_TAG;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            
            NSDictionary* dic = _allDays[0];
            NSUInteger index = 0;
            for(NSDictionary* dictionary in _allDays)
            {
                if([[dictionary.allKeys firstObject] isEqualToString:@"今天"])
                {
                    dic = dictionary;
                    index = [_allDays indexOfObject:dictionary];
                    break;
                }
            }
            [self rotationTheTableView:dic withIndex:index];
        });
        
        NSMutableArray* array1 = nil;
        _allWeeks = [[[FetchSportDataUtil fetchAllWeeksSportData:&array1] reverseObjectEnumerator] allObjects];
        _daysOfEveryWeek = [[array1 reverseObjectEnumerator] allObjects];
        NSLog(@"---allWeeks-->%@", _allWeeks);
        NSLog(@"---array --> %@", _daysOfEveryWeek);
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
        NSMutableArray* array2 = nil;
        _allMonths = [[[FetchSportDataUtil fetchAllMonthSportData:&array2] reverseObjectEnumerator] allObjects];
        _daysOfEveryMonth  = array2;
        NSLog(@"---allWeeks-->%@", _allMonths);
        NSLog(@"---array --> %@", _daysOfEveryMonth);
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
    });

    
}

#pragma mark TableView delegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* ID = @"reuseId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 40, 30)];
        label.tag = 119;
        [label setFont:[UIFont systemFontOfSize:10]];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.text = [[_allDays[indexPath.row] allKeys] firstObject];
        [cell addSubview:label];
        label.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        MyView* view = [[MyView alloc] initWithFrame:CGRectMake(60, 0, [[[_allDays[indexPath.row] allObjects] firstObject] intValue]*_rateOfDay, 30)];
       
        view.tag = 120;
        view.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
        [cell addSubview:view];
        
        UIView *lineViewA = [self.view viewWithTag:328001];
        UIView *lineTextLabelA = [self.view viewWithTag:328002];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:FootTargetKey] == nil) {
            
        } else {
            lineViewA.frame = CGRectMake(0, (_dateDataLabel.frame.origin.y + 30) + ([[[NSUserDefaults standardUserDefaults] objectForKey:FootTargetKey] integerValue] * _rateOfDay) + (screen_width - ([[[NSUserDefaults standardUserDefaults] objectForKey:FootTargetKey] integerValue] * _rateOfDay - 24) * 2), screen_width, 1);
            lineTextLabelA.frame = CGRectMake(0, -20, screen_width, 20);
        }
    }
    UILabel* label = [cell viewWithTag:119];
    CGFloat width = 0;
    NSDictionary* dic = nil;
    switch (_currentTag) {
        case DAY_TAG:
            if([[[_allDays[indexPath.row] allKeys] firstObject] length]<=5)
            {
                label.text = [[_allDays[indexPath.row] allKeys] firstObject];
            }
            else
            {
                label.text = [[[_allDays[indexPath.row] allKeys] firstObject] substringFromIndex:5];
            }
            
            width = [[[_allDays[indexPath.row] allObjects] firstObject] intValue]*_rateOfDay;
            dic = _allDays[indexPath.row];
            break;
        case WEEK_TAG:
            if([[[_allWeeks[indexPath.row] allKeys] firstObject] length] <= 5)
            {
                label.text = [[_allWeeks[indexPath.row] allKeys] firstObject];
            }
            else
            {
                label.text = [[[_allWeeks[indexPath.row] allKeys] firstObject] substringFromIndex:5];
            }
            width = [[[_allWeeks[indexPath.row] allObjects] firstObject] intValue]*_rateOfDay;
            dic = _allWeeks[indexPath.row];
            break;
        case MONTH_TAG:
            label.text = [[_allMonths[indexPath.row] allKeys] firstObject];
            width = [[[_allMonths[indexPath.row] allObjects] firstObject] intValue]*_rateOfDay;
            dic = _allMonths[indexPath.row];
            break;
        default:
            break;
    }
    
    MyView* view = [cell viewWithTag:120];
    view.refreshView = ^(NSDictionary* dic){
        if(!dic) return ;
        _dateDataLabel.hidden = NO;
        _dateLabel.hidden = NO;
        _dateLabel.text = [[dic allKeys] firstObject];
        _dateDataLabel.text = [NSString stringWithFormat:@"%ld %@", [[[dic allValues] firstObject] integerValue],NSLocalizedString(@"步", nil)];
        [self refreshSportDetailView:dic withIndex:indexPath.row];
    };
    
    view.dataDic = dic;
    view.frame = CGRectMake(35, 10, width, 30);
    return cell;
}

- (void) refreshSportDetailView:(NSDictionary*)dic withIndex:(NSInteger)index
{
    if(!dic) return;
    NSUInteger data = [[[dic allValues] firstObject] integerValue];
    float energy ;
    
    if(_currentTag==DAY_TAG)
    {
        energy = data * (([self personWeight] - 13.63636) * 0.000693 + 0.00495);
        if (energy < 0) {
            energy = -energy;
        }
    }
    else if (_currentTag==WEEK_TAG)
    {
        data = (data/[_daysOfEveryWeek[index] integerValue]);
       energy = data * (([self personWeight] - 13.63636) * 0.000693 + 0.00495);
        if (energy < 0) {
            energy = -energy;
        }
    }
    else
    {
        data = (data/[_daysOfEveryMonth[index] integerValue]);
        energy = data * (([self personWeight] - 13.63636) * 0.000693 + 0.00495);
        if (energy < 0) {
            energy = -energy;
        }
    }
    _detailView.sportDataLabel.text = [NSString stringWithFormat:@"%.1f",(float)data*((float)[self personHeight]*0.45/100)];
    _detailView.footDataLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)data];
    
    if(energy>=1000)
    {
        [_detailView.calorieDataLabel setFont:[UIFont systemFontOfSize:10]];
    }
    else
    {
        [_detailView.calorieDataLabel setFont:[UIFont systemFontOfSize:14]];
    }
    _detailView.calorieDataLabel.text = [NSString stringWithFormat:@"%.1f", energy];
    NSLog(@"---> %d", data);
    NSLog(@"--!!!%f", energy);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_currentTag==DAY_TAG)
    {
        return _allDays.count;
    }
    else if (_currentTag==WEEK_TAG)
    {
        return _allWeeks.count;
    }
    else
    {
        return _allMonths.count;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (float) heightRate:(NSArray*)array
{
    int max = 0;
    for(int i=0; i<array.count; ++i)
    {
        if([[[array[i] allObjects] firstObject] intValue] > max)
        {
            max = [[[array[i] allObjects] firstObject] intValue];
        }
    }
    if(max==0) return 0;
    return (float)screen_height/1.6/max;
}

-(int)personWeight{
    if([[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo]){
        NSData* data = [[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo];
        PersonInfoModel* personInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSString* weightStr = personInfo.weight;
        return [self findNumFromStr:weightStr];
    }else{
        return 60;
    }
}

-(int)personHeight
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo]){
        NSData* data = [[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo];
        PersonInfoModel* personInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSString* weightStr = personInfo.height;
        return [self findNumFromStr:weightStr];
    }else{
        return 170;
    }
}

-(int)findNumFromStr:(NSString*)str
{
    
    // Intermediate
    NSMutableString *numberString = [[NSMutableString alloc] init];
    NSString *tempStr;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (![scanner isAtEnd]) {
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        [numberString appendString:tempStr];
        tempStr = @"";
    }
    // Result.
    int number = [numberString intValue];
    
    return number;
}

#pragma Button Action
- (void) shareAction
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    
    [UMSocialData defaultData].extConfig.tencentData.shareImage = [UMSocialData defaultData].extConfig.tencentData.shareImage;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:@"Famar"
                                     shareImage:img
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone, UMShareToSina, nil]
                                       delegate:self];
}

- (void) increaseAction
{
    if(_currentTag==DAY_TAG)
    {
        return;
    }else if(_currentTag==WEEK_TAG)
    {
        _currentTag = DAY_TAG;
        
        _detailView.sportLabel.text =  NSLocalizedString(@"当天活动里程:千米", nil);
        _detailView.footLabel.text =  NSLocalizedString(@"当天步数:步", nil) ;
        _detailView.calorieLabel.text = NSLocalizedString(@"当天能量消耗:千卡", nil) ;
    }
    else
    {
        _currentTag = WEEK_TAG;
        
        _detailView.sportLabel.text = NSLocalizedString(@"日均里程:千米", nil);
        _detailView.footLabel.text = NSLocalizedString(@"日均步数:步", nil);
        _detailView.calorieLabel.text = NSLocalizedString(@"日均消耗:千卡", nil);
    }
    [_tableView reloadData];
    
}
- (void) decreaseAction
{
    if(_currentTag==MONTH_TAG)
    {
        return;
    }
    else if(_currentTag==WEEK_TAG)
    {
        _currentTag = MONTH_TAG;
    }
    else
    {
        _currentTag = WEEK_TAG;
    }
    _detailView.sportLabel.text = NSLocalizedString(@"日均里程:千米", nil);
    _detailView.footLabel.text = NSLocalizedString(@"日均步数:步", nil);
    _detailView.calorieLabel.text = NSLocalizedString(@"日均消耗:千卡", nil);
    [_tableView reloadData];
}


#pragma ScrollView delegate
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}

@end

@implementation MyView

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
    
    if(self.refreshView && self.dataDic)
    {
        _refreshView(self.dataDic);
    }
    
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.refreshView)
    {
        _refreshView(nil);
    }
    self.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
    if(self.refreshView)
    {
        _refreshView(nil);
    }
}

@end
