//
//  MovementRemindView.m
//  TWatch
//
//  Created by Yingbo on 15/7/4.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "MovementRemindView.h"
#import "StepProgressView.h"
#import "StepView.h"
#import "AppUtils.h"
#import "UserDefaultsUtils.h"
#import "PersonInfoModel.h"
#import "SportModel.h"

#import "SMDatabaseSingleton.h"
#import "SportsDataUtil.h"
#import "SVProgressHUD.h"

@interface MovementRemindView()<UIScrollViewDelegate>
{
//    Sqlite3Utils *sqliteUtils;
    NSDate *selectDate;
    int selectType;
    SMDatabaseSingleton* _smDatabaseSingleton;
}

@property(nonatomic,strong) UIView *topView;

@property(nonatomic,strong) UIImageView *bgView;

@property(nonatomic,strong) UIButton *setupCountButton;

@property(nonatomic,strong) UIButton *sleepCountButton;

@property(nonatomic,strong) UIButton *settingButton;



@property(nonatomic,strong) UIScrollView *timeSelectView;

@property(nonatomic,strong) UIButton *preDataButton;

@property(nonatomic,strong) UIButton *nextDataButton;

@property(nonatomic,strong) UILabel  *timeTitleLabel;

@property(nonatomic,strong) StepProgressView *progressView;

@property(nonatomic,strong) UIView  *importantDataView;

@property(nonatomic,strong) UILabel  *item1Label;

@property(nonatomic,strong) UILabel  *item2Label;

@property(nonatomic,strong) UILabel  *item3Label;

@property(nonatomic,strong) UILabel  *item1ValueLabel;

@property(nonatomic,strong) UILabel  *item2ValueLabel;

@property(nonatomic,strong) UILabel  *item3ValueLabel;

@property(nonatomic,strong) StepView *stepView;

@property(nonatomic,strong) NSDateFormatter *formatter;

@end


@implementation MovementRemindView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
        selectDate = [NSDate date];
        _formatter = [[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"ClearDataInPhone" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSportDataOk) name:@"DownloadFootDataCompletion" object:nil];
        [self layoutView];
    }
    return self;
}

- (void)downloadSportDataOk{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tochangedata];
        [SVProgressHUD dismiss];
        if(_rootView){
            [_rootView.header endRefreshing];
        }
    });
}

-(void)setContentViewOffset
{
    [self.rootView.header endRefreshing];
}
//-(UIImage *)setContentOffset:(CGPoint)point
//{
//    [self.rootView setContentOffset:point];
//}
//- (void)segemenControlAction:(UISegmentedControl*)seg{
//    switch (seg.selectedSegmentIndex) {
//        case 0:
//            seg.selectedSegmentIndex = 0;
//            [self toChangeData:[sqliteUtils queryOneDayByDate:[NSDate date]] type:selectType=2];
//            break;
//        case 1:
//            seg.selectedSegmentIndex = 1;
//            [self toChangeData:[sqliteUtils queryOneDayByDate:[NSDate date]] type:selectType=1];
//        default:
//            break;
//    }
//}
-(UIImage *)TakeScrennShot
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(self.rootView.bounds);
    [self.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;
}
- (void)layoutView
{
//    [self addSubview:self.topView];
//    [self.topView addSubview:self.settingButton];
    
    [self addSubview:self.rootView];
    
    [self.rootView addSubview:self.settingButton];
    [self.rootView addSubview:self.timeSelectView];
    [self.rootView addSubview:self.timeTitleLabel];
    [self.rootView addSubview:self.preDataButton];
    [self.rootView addSubview:self.nextDataButton];
    
    [self.rootView addSubview:self.progressView];
    [self.rootView addSubview:self.importantDataView];
    [self.importantDataView addSubview:self.item1Label];
    [self.importantDataView addSubview:self.item2Label];
    [self.importantDataView addSubview:self.item3Label];
    [self.importantDataView addSubview:self.item1ValueLabel];
    [self.importantDataView addSubview:self.item2ValueLabel];
    [self.importantDataView addSubview:self.item3ValueLabel];
    
    [self.rootView addSubview:self.stepView];
    
//    sqliteUtils=[[Sqlite3Utils alloc]init];
    _smDatabaseSingleton = [SMDatabaseSingleton shareInstance];
    
//    [self toChangeData:[sqliteUtils queryOneDayByDate:selectDate] type:selectType=2];
    [self toChangeData:[_smDatabaseSingleton queryOneDayByDate:selectDate]  type:2];
    
    
    self.rootView.contentSize = CGSizeMake(screen_width, self.stepView.frame.origin.y + self.stepView.frame.size.height + 20);
}

-(void) tochangedata{
//    [self toChangeData:[sqliteUtils queryOneDayByDate:selectDate] type:selectType];
    [self toChangeData:[_smDatabaseSingleton queryOneDayByDate:selectDate]  type:2];
}


-(void)toChangeData:(NSArray*)array type:(int)type{//1是睡眠  2是步数
    int stepCount = 0;
    int timeCount = 0;
    for(SportModel* model in array){
        stepCount += model.sportData;
        timeCount += 5;
    }
    
    
    _item1Label.text=NSLocalizedString(@"活动里程", nil);
    _item2Label.text=NSLocalizedString(@"活动时间", nil);
    _item3Label.text = NSLocalizedString(@"能量消耗", nil);
    
    _item1ValueLabel.text=[NSString stringWithFormat:@"%.1f%@",(stepCount*0.7/1000),NSLocalizedString(@"千米", nil)];
    _item2ValueLabel.text=[NSString stringWithFormat:@"%.1f%@",(float)timeCount/60,NSLocalizedString(@"小时", nil)];
    
    float energy = stepCount * (([self personWeight] - 13.63636) * 0.000693 + 0.00495);
    if (energy < 0) {
        energy = -energy;
    }
    _item3ValueLabel.text=[NSString stringWithFormat:@"%.1f%@",energy,NSLocalizedString(@"千卡", nil)];
    [self.stepView toChangeData:array];
    
    NSInteger target = 0;
    if(![[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey])
    {
        target = 10000;
    }
    else
    {
        target = [[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey];
    }
    NSString* targetFoot = [NSString stringWithFormat:@"%ld%@", (long)target, NSLocalizedString(@"步", nil)];
    [_progressView toChangeViewData:NSLocalizedString(@"总步数", nil) center:[NSString stringWithFormat:@"%i",stepCount] boottom:targetFoot];
    
    _stepView.hidden=NO;
}

- (UIScrollView *)rootView
{
    if (_rootView == nil) {
//        CGFloat y = _topView.frame.origin.y + _topView.frame.size.height;
        CGFloat y = 64;
        _rootView = [[UIScrollView alloc]init];
        MJRefreshNormalHeader* header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            //获取运动数据
            SportsDataUtil* util = [[SportsDataUtil alloc] init];
            if(![BLEAppContext shareBleAppContext].isPaired){
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请连接手表", @"")];
            }else{
                [SVProgressHUD showWithStatus:NSLocalizedString(@"正在刷新数据中...", @"") maskType:SVProgressHUDMaskTypeGradient];
                [util requestSportsDataLength];
            }
            
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self tochangedata];
                            [_rootView.header endRefreshing];
                            [SVProgressHUD dismiss];
                        });
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        _rootView.header = header;
        _rootView.frame = CGRectMake(0,y, screen_width, screen_height - y);
        _rootView.contentSize = CGSizeMake(screen_width, screen_height);
    }
    return _rootView;
}

- (UIImageView *)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIImageView alloc]init];
        _bgView.frame = CGRectMake(0, 0, 170, 35);
        _bgView.center = CGPointMake(screen_width / 2, 22);
        _bgView.image = [UIImage imageNamed:@"tap_bg"];
    }
    return _bgView;
}

- (UIView *)topView
{
    if (_topView == nil) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor greenColor];
        _topView.frame = CGRectMake(0, 84, screen_width, 40);
    }
    return _topView;
}

- (UIButton *)sleepCountButton
{
    if (_sleepCountButton == nil) {
        _sleepCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sleepCountButton.frame = CGRectMake((screen_width/2) , 5, 79.6, 35);
        [_sleepCountButton addTarget:self action:@selector(sleepCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_sleepCountButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_sleepCountButton setTitle:@"睡眠" forState:UIControlStateNormal];
        [_sleepCountButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    return _sleepCountButton;
}

- (UIButton *)setupCountButton
{
    if (_setupCountButton == nil) {
        _setupCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _setupCountButton.frame = CGRectMake(screen_width/2 - 170 / 2, 5, 79.6, 35);
        [_setupCountButton addTarget:self action:@selector(setupCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [_setupCountButton setBackgroundImage:[UIImage imageNamed:@"tap_huakuai"] forState:UIControlStateNormal];
        [_setupCountButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_setupCountButton setTitle:@"日步" forState:UIControlStateNormal];
        [_setupCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _setupCountButton;
}

- (UIButton *)settingButton
{
    if (_settingButton == nil) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingButton.frame = CGRectMake(screen_width - 37, 15, 30, 30);
        [_settingButton setBackgroundImage:[UIImage imageNamed:@"left_icon4"] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(settingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

- (UIScrollView *)timeSelectView
{
    if (_timeSelectView == nil) {
        _timeSelectView=[[UIScrollView alloc]initWithFrame:CGRectMake(70, 10, screen_width - 140, 40)];
        _timeSelectView.contentSize=CGSizeMake(screen_width, 142);
        _timeSelectView.pagingEnabled = YES;
        _timeSelectView.showsHorizontalScrollIndicator=NO;
        _timeSelectView.showsVerticalScrollIndicator=NO;
        _timeSelectView.delegate = self;
    }
    return _timeSelectView;
}

- (UIButton *)preDataButton
{
    if (_preDataButton == nil) {
        _preDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _preDataButton.frame = CGRectMake(40, 20, 20, 27);
        [_preDataButton addTarget:self action:@selector(preDataButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_preDataButton setBackgroundImage:[UIImage imageNamed:@"prev_left_icon"] forState:UIControlStateNormal];
    }
    return _preDataButton;
}

- (UIButton *)nextDataButton
{
    if (_nextDataButton == nil) {
        _nextDataButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextDataButton.frame = CGRectMake(_timeSelectView.frame.origin.x + _timeSelectView.frame.size.width + 0, 20, 20, 27);
        [_nextDataButton addTarget:self action:@selector(nextDataButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_nextDataButton setBackgroundImage:[UIImage imageNamed:@"next_right_icon"] forState:UIControlStateNormal];
    }
    return _nextDataButton;
}

- (UILabel *)timeTitleLabel
{
    if (_timeTitleLabel == nil) {
        _timeTitleLabel = [[UILabel alloc]init];
        _timeTitleLabel.frame = CGRectMake(70, 10, screen_width - 140, 40);
        _timeTitleLabel.textAlignment = NSTextAlignmentCenter;
        _timeTitleLabel.textColor = [UIColor whiteColor];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        _timeTitleLabel.text = [formatter stringFromDate:selectDate];
    }
    return _timeTitleLabel;
}

- (StepProgressView *)progressView
{
    if (_progressView == nil) {
        CGFloat y = _timeSelectView.frame.origin.y + _timeSelectView.frame.size.height + 20;
        _progressView = [[StepProgressView alloc]init];
        _progressView.frame = CGRectMake(0, 0, 180, 180);
        _progressView.center = CGPointMake(screen_width / 2, y+ 100);
    }
    return _progressView;
}

- (UIView *)importantDataView
{
    if (_importantDataView == nil) {
        _importantDataView = [[UIView alloc]init];
        _importantDataView.frame = CGRectMake(20, _progressView.frame.origin.y + _progressView.frame.size.height + 30, screen_width-40, 80);
        
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, 0, screen_width - 40, 20);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16];
        label.text = [NSString stringWithFormat:@"—%@—",NSLocalizedString(@"重要数据",nil)];
        [_importantDataView addSubview:label];
        
        UIView *line1 = [[UIView alloc]init];
        line1.frame = CGRectMake((screen_width-40)/3, 46, 1, 40);
        line1.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [_importantDataView addSubview:line1];
        
        UIView *line2 = [[UIView alloc]init];
        line2.frame = CGRectMake(((screen_width-40)/3)*2, 46, 1, 40);
        line2.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [_importantDataView addSubview:line2];
    }
    return _importantDataView;
}

- (UILabel *)item1Label
{
    if (_item1Label == nil) {
        _item1Label = [[UILabel alloc]init];
        _item1Label.frame = CGRectMake(0, 40, (screen_width - 40)/3, 20);
        _item1Label.textAlignment = NSTextAlignmentCenter;
        _item1Label.textColor = [UIColor whiteColor];
        _item1Label.text = @"活动里程";
    }
    return _item1Label;
}

- (UILabel *)item2Label
{
    if (_item2Label == nil) {
        _item2Label = [[UILabel alloc]init];
        _item2Label.frame = CGRectMake((screen_width - 40)/3, 40, (screen_width - 40)/3, 20);
        _item2Label.textAlignment = NSTextAlignmentCenter;
        _item2Label.textColor = [UIColor whiteColor];
        _item2Label.text = @"活动时间";
    }
    return _item2Label;
}

- (UILabel *)item3Label
{
    if (_item3Label == nil) {
        _item3Label = [[UILabel alloc]init];
        _item3Label.frame = CGRectMake(((screen_width - 40)/3)*2, 40, (screen_width - 40)/3, 20);
        _item3Label.textAlignment = NSTextAlignmentCenter;
        _item3Label.textColor = [UIColor whiteColor];
        _item3Label.text = @"能量消耗";
    }
    return _item3Label;
}

- (UILabel *)item1ValueLabel
{
    if (_item1ValueLabel == nil) {
        _item1ValueLabel = [[UILabel alloc]init];
        _item1ValueLabel.frame = CGRectMake(0, 70, (screen_width - 40)/3, 20);
        _item1ValueLabel.textAlignment = NSTextAlignmentCenter;
        _item1ValueLabel.textColor = RGBColor(56, 153, 233);
        _item1ValueLabel.text = @"0.0公里";
    }
    return _item1ValueLabel;
}

- (UILabel *)item2ValueLabel
{
    if (_item2ValueLabel == nil) {
        _item2ValueLabel = [[UILabel alloc]init];
        _item2ValueLabel.frame = CGRectMake((screen_width - 40)/3, 70, (screen_width - 40)/3, 20);
        _item2ValueLabel.textAlignment = NSTextAlignmentCenter;
        _item2ValueLabel.textColor = RGBColor(56, 153, 233);
        _item2ValueLabel.text = @"0.0小时";
    }
    return _item2ValueLabel;
}

- (UILabel *)item3ValueLabel
{
    if (_item3ValueLabel == nil) {
        _item3ValueLabel = [[UILabel alloc]init];
        _item3ValueLabel.frame = CGRectMake(((screen_width - 40)/3)*2, 70, (screen_width - 40)/3, 20);
        _item3ValueLabel.textAlignment = NSTextAlignmentCenter;
        _item3ValueLabel.textColor = RGBColor(56, 153, 233);
        _item3ValueLabel.text = @"0.0千卡";
    }
    return _item3ValueLabel;
}

- (StepView *)stepView
{
    if (_stepView == nil) {
        _stepView = [[StepView alloc]initWithFrame:CGRectMake(10, _importantDataView.frame.origin.y + _importantDataView.frame.size.height, screen_width - 20, 200)];
    }
    return _stepView;
}

- (void)changeBackgroundImageWithButton:(UIButton*)button
{
    [_setupCountButton setBackgroundImage:nil forState:UIControlStateNormal];
    [_sleepCountButton setBackgroundImage:nil forState:UIControlStateNormal];
    [_setupCountButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_sleepCountButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"tap_huakuai"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setupCountButtonAction:(UIButton*)button
{
    [self changeBackgroundImageWithButton:button];
    
//    [self toChangeData:[sqliteUtils queryOneDayByDate:[NSDate date]] type:selectType=2];
    [self toChangeData:[_smDatabaseSingleton queryOneDayByDate:[NSDate date]] type:2];
}

- (void)seatCountButtonAction:(UIButton*)button
{
    [self changeBackgroundImageWithButton:button];
}

- (void)sleepCountButtonAction:(UIButton*)button
{
    [self changeBackgroundImageWithButton:button];
    
//    [self toChangeData:[sqliteUtils queryOneDayByDate:[NSDate date]] type:selectType=1];
}

- (void)settingButtonAction
{
    //    MovementRemindSettingViewController *viewController = [[MovementRemindSettingViewController alloc]init];
    //    [self.navigationController pushViewController:viewController animated:YES];
    if(self.gotoVc){
        dispatch_sync(dispatch_get_global_queue(0, 0), self.gotoVc);
    }
}

//上一天
- (void)preDataButtonAction:(UIButton*)button
{
    selectDate=[NSDate dateWithTimeIntervalSince1970: [selectDate timeIntervalSince1970]-60*24*60];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    _timeTitleLabel.text = [format stringFromDate:selectDate];
    
//    [self toChangeData:[sqliteUtils queryOneDayByDate:selectDate] type:selectType];
    [self toChangeData:[_smDatabaseSingleton queryOneDayByDate:selectDate] type:2];
}

//下一天
- (void)nextDataButtonAction:(UIButton*)button
{
    NSString* today = [_formatter stringFromDate:[NSDate date]];
    if([_timeTitleLabel.text isEqualToString:today]){
        return;
    }
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    
    selectDate=[NSDate dateWithTimeIntervalSince1970: [selectDate timeIntervalSince1970]+60*24*60];
    
    _timeTitleLabel.text = [format stringFromDate:selectDate];
    
//    [self toChangeData:[sqliteUtils queryOneDayByDate:selectDate] type:selectType];
    [self toChangeData:[_smDatabaseSingleton queryOneDayByDate:selectDate] type:2];
}

- (void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
    for (UIView *view in _timeSelectView.subviews) {
        [view removeFromSuperview];
    }
    for (int i=0;i<dataArray.count;i++) {
        NSDictionary *dic = dataArray[i];
        //        NSString *urlString=dic[@"templetPic"];
        //        NSString *tempColor = dic[@"backgroundColor"];
        //        tempColor = [tempColor  substringWithRange:NSMakeRange(1, tempColor.length-1)];
        
        //        urlString=[urlString substringWithRange:NSMakeRange(1, urlString.length-2)];
        //        UIView *view ;
        //        UIImageView *imageView;
        //        NSInteger count=_scrollViewImage.subviews.count;
        //        if (i>=count) {
        //            view=[[UIImageView alloc]initWithFrame:CGRectMake(i*screen_width, 0, screen_width, 142)];
        //            view.tag = i;
        //            imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 10, screen_width, 100)];
        //            imageView.contentMode=UIViewContentModeScaleAspectFit;
        //            imageView.tag=i;
        //            imageView.image = [UIImage imageNamed:urlString];
        //            [view addSubview:imageView];
        //            [_scrollViewImage addSubview:view];
        //        }else{
        //            imageView=(UIImageView*)[_scrollViewImage.subviews[i] viewWithTag:i];
        //        }
        //
        //        [view setBackgroundColor: [self hexStringToColor:tempColor]];
        //        [view setUserInteractionEnabled:YES];
        //        [imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"image_loading_bg"]];
        //
        //        UITextField *title = [[UITextField alloc]initWithFrame:CGRectMake(0, 115, screen_width, 20)];
        //        title.delegate = self;
        //        title.text =dic[@"title"];
        //        title.tag = 1000+i;
        //        title.textColor = [UIColor whiteColor];
        //        title.font = [UIFont systemFontOfSize:13];
        //        title.textAlignment = NSTextAlignmentCenter;
        //        [view addSubview:title];
        
    }
    _timeSelectView.contentSize = CGSizeMake(screen_width*dataArray.count, 142);
    _timeSelectView.contentOffset = CGPointZero;
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
    int number = [numberString integerValue];
    
    return number;
}

@end
