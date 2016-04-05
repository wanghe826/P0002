//
//  FitnessViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/7.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "FitnessViewController.h"
#import "Masonry.h"
#import "FetchSportDataUtil.h"
#import "SportModel.h"
#import "PersonInfoModel.h"
#import "UMSocial.h"

@implementation FitnessViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"是" forKey:@"isShowFirstView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _sportDatas = [[NSArray alloc] init];
    _views = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOneDayUI) name:@"DownloadFootDataCompletion" object:nil];
}


- (void) refreshOneDayUI
{
    _sportDatas = [FetchSportDataUtil fetchOneDaySportData:[NSDate date]];
    UIView* superView = [self.view viewWithTag:826];
    if(superView)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showSportDataDetail:superView];
        });
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    _sportDatas = [FetchSportDataUtil fetchOneDaySportData:[NSDate date]];
    [self initFitnessUI];
}

- (void) initFitnessUI
{
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, screen_width, 2*screen_height/3+34)];
    //    scrollView.contentSize = CGSizeMake(screen_width + 7*screen_width/5, 0);
    scrollView.contentSize = CGSizeMake(kContentViewWidth, 0);
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    //    scrollView.contentOffset = CGPointMake(4*screen_width/5, 0);
    scrollView.contentOffset = CGPointMake(kContentViewWidth/3, 0);
    [self.view addSubview:scrollView];
    
    //    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 12*screen_width/5, 2*screen_height/3)];
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, kContentViewWidth, 2*screen_height/3)];
    backgroundView.tag = 826;
    backgroundView.backgroundColor = RGBColor(0xe1, 0x65, 0x28);
    [scrollView addSubview:backgroundView];
    
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont systemFontOfSize:17]];
    titleLabel.text = NSLocalizedString(@"运动健康", nil);
    titleLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
    titleLabel.center = CGPointMake(self.view.center.x, 44);
    [self.view addSubview:titleLabel];
    
    
    
    UILabel* today = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    today.text = NSLocalizedString(@"今日记录", nil);
    today.textColor = HexRGBAlpha(0xfdfdfd, 0.5);
    today.textAlignment = NSTextAlignmentCenter;
    [today setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:today];
    today.center = CGPointMake(self.view.center.x, 64);
    
    
    UIView* tabView = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height, kContentViewWidth, 34)];
    tabView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [backgroundView addSubview:tabView];
    
    int labelWidth = kContentViewWidth/12;
    for (int i=0; i<12; i++) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(i*labelWidth, backgroundView.frame.size.height-20, labelWidth, tabView.frame.size.height)];
        label.textColor = HexRGBAlpha(0x090909, 0.4);
        label.textAlignment = NSTextAlignmentLeft;
        [label setFont:[UIFont systemFontOfSize:12]];
        if(2*i<10)
        {
            label.text = [NSString stringWithFormat:@"0%d:00",2*i];
        }
        else
        {
            label.text = [NSString stringWithFormat:@"%d:00",2*i];
        }
        
        [scrollView addSubview:label];
    }
    
    UIView* sportDetailBackview = [[UIView alloc] initWithFrame:CGRectMake(10, tabView.frame.size.height + tabView.frame.origin.y+10, screen_width-20, 80)];
    sportDetailBackview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sportDetailBackview];
    
    [self showSportDataDetail:backgroundView];
    
    
    CGSize fitViewSize = CGSizeMake(sportDetailBackview.frame.size.width/4, sportDetailBackview.frame.size.height);
    FitnessView* fitView1 = [[FitnessView alloc] initWithFrame:CGRectMake(0, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_distance"] withLabel:_allFootKm<1?NSLocalizedString(@"活动里程:米", nil):NSLocalizedString(@"活动里程:千米", nil) withResult:_allFootKm<1?_allFootKm*1000:_allFootKm];
    [sportDetailBackview addSubview:fitView1];
    
    FitnessView* fitView2 = [[FitnessView alloc] initWithFrame:CGRectMake(sportDetailBackview.frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_foot"] withLabel:NSLocalizedString(@"全天步数:步", nil) withResult:_allFootData];
    [sportDetailBackview addSubview:fitView2];
    
    FitnessView* fitView3 = [[FitnessView alloc] initWithFrame:CGRectMake(sportDetailBackview.frame.size.width/2, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_time"] withLabel:NSLocalizedString(@"活动时间:分", nil) withResult:_allFootTime];
    [sportDetailBackview addSubview:fitView3];
    
    FitnessView* fitView4 = [[FitnessView alloc] initWithFrame:CGRectMake(3*sportDetailBackview.frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_calorie"] withLabel:NSLocalizedString(@"能量消耗:千卡", nil) withResult:_allFootKcal];
    [sportDetailBackview addSubview:fitView4];
    
    
    _currentSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    //    _currentSelectLabel.text = @"12:40~12:50记录 680步";
    _currentSelectLabel.textAlignment = NSTextAlignmentCenter;
    [_currentSelectLabel setFont:[UIFont systemFontOfSize:12]];
    _currentSelectLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
    [self.view addSubview:_currentSelectLabel];
    _currentSelectLabel.center = CGPointMake(self.view.center.x, 100);
    
    UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.right.equalTo(self.view).with.offset(-20);
        maker.centerY.equalTo(titleLabel);
        maker.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    NSLog(@"-------%d", _scrollViewOffset);
    if(_scrollViewOffset>50)
    {
        scrollView.contentOffset = CGPointMake(_scrollViewOffset-50, 0);
    }
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    _allFootKm = 0;
//    _allFootTime = 0;
//    _allFootKcal = 0;
//}

- (void) showSportDataDetail:(UIView*)superView
{
    if(_views && _views.count!=0)
    {
        for(UIView* view in _views)
        {
            [view removeFromSuperview];
        }
        [_views removeAllObjects];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSCalendar* calendar=[NSCalendar currentCalendar];
    NSCalendarUnit unitHour = NSCalendarUnitHour;
    NSCalendarUnit unitMin = NSCalendarUnitMinute;
    
    int array[144];
    for(int i=0; i<144; i++)
    {
        array[i] = 0;
    }
    
    _allFootData = 0;
    if(_sportDatas && _sportDatas.count!=0)
    {
        for(SportModel* model in _sportDatas)
        {
            NSString* sportTime = model.sportTime;
            
            NSDate* date = [formatter dateFromString:sportTime];
            NSInteger hour = [calendar component:unitHour fromDate:date];
            NSInteger min = [calendar component:unitMin fromDate:date];
            
            int minIndex = (int)(min/10);
            int index = (int)hour*6+minIndex;
            
            array[index] += model.sportData;
            
            _allFootData += model.sportData;
        }
        
        _allFootTime = 0;
        for(SportModel* model in _sportDatas)
        {
            if(model.sportData >= 150)
            {
                _allFootTime += 5;
            }
        }
        
        
        _allFootKm = (_allFootData*((float)[self personHeight]*0.45/100)/1000);
        
        float energy = _allFootData * (([self personWeight] - 13.63636) * 0.000693 + 0.00495);
        if (energy < 0) {
            energy = -energy;
        }
        _allFootKcal = energy;
        
        
        int max = 0;
        for(int i=0; i<144; ++i)
        {
            if(array[i] > max)
            {
                max = array[i];
            }
        }
        
        //计算scrollView的偏移量
        for(int i=143; i>=0; i--)
        {
            if(array[i] != 0)
            {
                _scrollViewOffset = i*(k10MinuteWidth+1);
                break;
            }
        }
        
        _rateHeight = (superView.frame.size.height*2/3)/max;
        
        for(int i=0; i<144; ++i)
        {
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake(i*(k10MinuteWidth+1), superView.frame.size.height-array[i]*_rateHeight, k10MinuteWidth, array[i]*_rateHeight)];
            view.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
            [superView addSubview:view];
            
            MyTapGestureRecognizer* gesture = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(sportViewSelected:)];
            gesture.sportData = array[i];
            gesture.sportViewIndex = i;
            [view addGestureRecognizer:gesture];
            
            [_views addObject:view];
        }
    } else {
        _allFootKm = 0;
        _allFootTime = 0;
        _allFootKcal = 0;
    }
}

- (void) sportViewSelected:(MyTapGestureRecognizer*)gesture
{
    for(UIView* view in _views)
    {
        view.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
    }
    int sportData = gesture.sportData;
    int hour = gesture.sportViewIndex/6;
    int min = gesture.sportViewIndex%6;
    
    int minDeadTime = min+1;
    int hourDeadTime = hour;
    if(min==5)
    {
        hourDeadTime = hour+1;
        minDeadTime = 0;
    }
    
    if(hour<10)
    {
        if(min == 0)
        {
            _currentSelectLabel.text = [NSString stringWithFormat:@"0%d:00~0%d:10%@ %d%@",hour,hourDeadTime,NSLocalizedString(@"记录",nil), sportData, NSLocalizedString(@"步", nil)];
        }
        else
        {
            _currentSelectLabel.text = [NSString stringWithFormat:@"0%d:%d0~0%d:%d0%@ %d%@", hour, min, hourDeadTime, minDeadTime,NSLocalizedString(@"记录", nil), sportData, NSLocalizedString(@"步", nil)];
        }
    }
    else
    {
        if(min == 0)
        {
            _currentSelectLabel.text = [NSString stringWithFormat:@"%d:00~%d:10%@ %d%@",hour,hour,NSLocalizedString(@"记录", nil), sportData,NSLocalizedString(@"步", nil)];
        }
        else
        {
            _currentSelectLabel.text = [NSString stringWithFormat:@"%d:%d0~%d:%d0%@ %d%@", hour, min, hourDeadTime, minDeadTime,NSLocalizedString(@"记录", nil), sportData, NSLocalizedString(@"步", nil)];
        }
    }
    gesture.view.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
}

- (void) shareBtnPressed
{
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    CGRect rect = [keyWindow bounds];
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [keyWindow.layer renderInContext:context];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    
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


@end


@implementation FitnessView

- (instancetype) initWithFrame:(CGRect)frame
                       withImg:(UIImage*)image
                     withLabel:(NSString*)str
                    withResult:(float)rsult
{
    _image = image;
    _title = str;
    self.result = rsult;
    self.backgroundColor = [UIColor whiteColor];
    return [self initWithFrame:frame];
}


- (instancetype) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        
    }
    return self;
}



- (void)layoutSubviews
{
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2-17.5, self.frame.size.width, 35)];
    titleLabel.text = _title;
    titleLabel.adjustsFontSizeToFitWidth = YES;// 这一句话需要添加、让文字自适应，解决不同设备适配问题
    titleLabel.textColor = HexRGBAlpha(0x090909, 0.5);
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    UIImageView* iv = [[UIImageView alloc] initWithImage:_image];
    iv.frame = CGRectMake(5+(self.frame.size.width - self.frame.size.width/2)/2, 0, self.frame.size.height/2-10, self.frame.size.height/2-10);
    [self addSubview:iv];
    
    UILabel* resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-titleLabel.frame.size.height/2-15, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    resultLabel.adjustsFontSizeToFitWidth = YES;// 这一句话需要添加、让文字自适应，解决不同设备适配问题
    
    NSRange range = [_title rangeOfString:NSLocalizedString(@"步", nil)];
    
    if(range.length != 0)
    {
        resultLabel.text = [NSString stringWithFormat:@"%d", (int)self.result];
    }
    else
    {
        resultLabel.text = [NSString stringWithFormat:@"%.1f", self.result];
    }
    [resultLabel setFont:[UIFont systemFontOfSize:20]];
    resultLabel.textColor = RGBColor(0x09, 0x09, 0x09);
    resultLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:resultLabel];
    
}

@end


@implementation MyTapGestureRecognizer

@end
