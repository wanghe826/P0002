//
//  TodayFitnessViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/16.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "TodayFitnessViewController.h"
#import "FetchSportDataUtil.h"
#import "UserDefaultsUtils.h"
#import "Masonry.h"
#import "UMSocial.h"

#import "SVProgressHUD.h"

@interface TodayFitnessViewController () <UIScrollViewDelegate, UMSocialDataDelegate>

// 每天、每周、每月数组
@property (nonatomic, strong) NSMutableArray *arrOfDays;
@property (nonatomic, strong) NSMutableArray *arrOfWeeks;
@property (nonatomic, strong) NSMutableArray *arrOfMounths;

// 共用的对象，天周月的分别个数，不需要传值，自己计算的
@property (nonatomic, assign) NSInteger howMuch;
@property (nonatomic, assign) NSInteger howMuchOld;

// 数组存放天数周数月数的名称、共用
@property (nonatomic, strong) NSMutableArray *mutArr;

// 判断当前处在哪个界面、天数？还是月数？
@property (nonatomic, assign) int DayOrMounth;

// 天数界面的页数
@property (nonatomic, assign) NSInteger pageOfDays;

// 求天数最大值时候用到的数组
@property (nonatomic, strong) __block NSArray *arraya;
// 求周数最大值时候用到的数组
@property (nonatomic, strong) __block NSArray *arrayb;
// 求月数最大值时候用到的数组
@property (nonatomic, strong) __block NSArray *arrayc;

// 周数天数
@property (nonatomic, strong) NSMutableArray* arrayZhou;
// 月数天数
@property (nonatomic, strong) NSMutableArray* arrayYue;

@end

@implementation TodayFitnessViewController

// 懒加载初始化 mutArr 数组
- (NSMutableArray *)mutArr {
    if (!_mutArr) {
        _mutArr = [NSMutableArray new];
    }
    return _mutArr;
}

- (NSMutableArray *)arrOfDays {
    if (!_arrOfDays) {
        _arrOfDays = [[NSMutableArray alloc] init];
    }
    return _arrOfDays;
}

- (NSMutableArray *)arrOfWeeks {
    if (!_arrOfWeeks) {
        _arrOfWeeks = [NSMutableArray new];
    }
    return _arrOfWeeks;
}

- (NSMutableArray *)arrOfMounths {
    if (!_arrOfMounths) {
        _arrOfMounths = [NSMutableArray new];
    }
    return _arrOfMounths;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([BLEAppContext shareBleAppContext].isInsertingData)
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"正在查询数据中...", @"") maskType:SVProgressHUDMaskTypeGradient];
    }
   
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self requestData];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dissSVPHud) name:@"InsertDataCompletion" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData) name:@"DownloadFootDataCompletion" object:nil];
}

- (void) dissSVPHud
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"是" forKey:@"isShowFirstView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 *  获取数据
 */
- (void)requestData {
    
    [self.arrOfDays removeAllObjects];
    [self.arrOfWeeks removeAllObjects];
    [self.arrOfMounths removeAllObjects];
    
    NSArray *jArr = @[@"今天", @"昨天",@"前天"];
    NSArray *zArr = @[@"本周", @"上周"];
    NSArray *yArr = @[@"本月"];
    
    
    self.arrOfDays = [FetchSportDataUtil fetchAllDaysSportData];
    self.arrOfDays = [[NSMutableArray alloc] initWithArray:[[self.arrOfDays reverseObjectEnumerator] allObjects]];
    
    
//    NSArray *tempArr = [NSArray arrayWithArray:[FetchSportDataUtil fetchAllDaysSportData]];
//    for (NSInteger i = 0; i < tempArr.count; i ++) {
//        [self.arrOfDays addObject:tempArr[tempArr.count - i - 1]];
//    }
    NSLog(@"-----❤️-----> %@", self.arrOfDays);
    
    for (NSInteger i = 0; i < self.arrOfDays.count; i ++) {
        
        if (i < 3) {
            self.arrOfDays[i] = @{jArr[i]:[self.arrOfDays[i] objectForKey:[self.arrOfDays[i] allKeys][0]]};
        } else {
            self.arrOfDays[i] = @{[[self.arrOfDays[i] allKeys][0] substringFromIndex:5]:[self.arrOfDays[i] objectForKey:[self.arrOfDays[i] allKeys][0]]};
        }
        
    }
    _arraya = [NSArray arrayWithArray:[self wantArrOfOneToN:self.arrOfDays]];//在for循环里面、强调
    
    NSMutableArray *array1;
    [self.arrOfWeeks addObjectsFromArray:[FetchSportDataUtil fetchAllWeeksSportData:&array1]];
    
    self.arrayZhou = [NSMutableArray arrayWithArray:array1];
    NSLog(@"所有天：%@", self.arrOfDays);
    NSLog(@"所有周: %@", self.arrayZhou);
    
    _arrayb = [NSArray arrayWithArray:[self wantArrOfOneToN:self.arrOfWeeks]];
    for (NSInteger i = 0; i < self.arrOfWeeks.count; i ++) {
        if (i < 2) {
            self.arrOfWeeks[i] = @{zArr[i]:[self.arrOfWeeks[i] objectForKey:[self.arrOfWeeks[i] allKeys][0]]};
        } else {
            break;
        }
    }
    
    NSMutableArray* array2;
    [self.arrOfMounths addObjectsFromArray:[FetchSportDataUtil fetchAllMonthSportData:&array2]];
    
    self.arrayYue = [NSMutableArray array];
    for (NSInteger i = 0; i < array2.count; i ++) {
        [self.arrayYue addObject:array2[array2.count - i - 1]];
    }
    
    NSLog(@"所有月:%@", self.arrayYue);
    _arrayc = [NSArray arrayWithArray:[self wantArrOfOneToN:self.arrOfMounths]];
    for (NSInteger i = 0; i < self.arrOfMounths.count; i ++) {
        if (i < 1) {
            self.arrOfMounths[i] = @{yArr[i]:[self.arrOfMounths[i] objectForKey:[self.arrOfMounths[i] allKeys][0]]};
        } else {
            break;
        }
    }
    
    
    if(self.arrOfDays.count != 0)
    {
        NSLog(@"😭👿");
//        [self performSelectorOnMainThread:@selector(initFitnessUIOfThisView) withObject:nil waitUntilDone:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initFitnessUIOfThisView];
        });
    
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.arrOfDays.count == 0) {
//            
//            NSLog(@"dsdsaadd");
//        } else {
//            //            [self performSelector:@selector(initFitnessUIOfThisView) withObject:nil afterDelay:0];
//            [self initFitnessUIOfThisView];
//        }
//    });
    
}

/**
 *  给一个'数组'做升序、此时的数组元素比较特别，可以自行打印
 *
 *  @param mutArr 传入数组
 *
 *  @return 返回排序的'某个'数组
 */
- (NSArray *)wantArrOfOneToN:(NSMutableArray *)mutArr1 {
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (NSInteger i = 0;  i < mutArr1.count; i ++) {
        [values addObject:[mutArr1[i] objectForKey:[mutArr1[i] allKeys][0]]];
    }
    
    return [values sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 floatValue] > [obj2 floatValue] ) {
            return NSOrderedDescending;
        }
        if ([obj1 floatValue] < [obj2 floatValue] ) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
    
}

/**
 *  重写父类方法
 */
- (void)initFitnessUI {
    
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isShowFirstView"] isEqualToString:@"是"]) {
        
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, screen_width, 2 * screen_height / 3 + 34)];
        scrollView.tag = 1 + 888;
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = NO;
        scrollView.contentOffset = CGPointMake(self.pageOfDays * screen_width, 0);
        [self.view addSubview:scrollView];
        scrollView.scrollEnabled = NO;
        
        UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 2 * screen_height / 3)];
        backgroundView.tag = 3 + 888;
        backgroundView.backgroundColor = RGBColor(0xe1, 0x65, 0x28);
        [scrollView addSubview:backgroundView];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        titleLabel.tag = 23 + 888;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel setFont:[UIFont systemFontOfSize:17]];
        titleLabel.text = NSLocalizedString(@"运动健康", nil);
        titleLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        titleLabel.center = CGPointMake(self.view.center.x, 44);
        [self.view addSubview:titleLabel];
        
        UILabel* today = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        today.tag = 1111 + 888;
        today.text = NSLocalizedString(@"今天记录", nil);
        today.textColor = HexRGBAlpha(0xfdfdfd, 0.5);
        today.textAlignment = NSTextAlignmentCenter;
        [today setFont:[UIFont systemFontOfSize:12]];
        [self.view addSubview:today];
        today.center = CGPointMake(self.view.center.x, 64);
        
        UILabel* todayDetail = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        todayDetail.tag = 2222 + 888;
        todayDetail.text = NSLocalizedString(@" ", nil);
        todayDetail.textColor = HexRGBAlpha(0xfdfdfd, 0.85);
        todayDetail.textAlignment = NSTextAlignmentCenter;
        [todayDetail setFont:[UIFont systemFontOfSize:13]];
        [self.view addSubview:todayDetail];
        todayDetail.center = CGPointMake(self.view.center.x, 95);
        
        
        // 标准线
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 265 * (screen_width / 375.0) - 34 + 40, screen_width, 0.5)];
        lineLabel.tag = 2323 + 888;
        lineLabel.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:lineLabel];
        lineLabel.alpha = 0.1;
        // 标准刻度值
        UILabel *lineLabelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 265 * (screen_width / 375.0) - 49 + 40, screen_width, 30)];
        lineLabelNum.tag = 3232 + 888;
        if ([UserDefaultsUtils valueWithKey:FootTargetKey] == nil) {
            lineLabelNum.text = @"目标步数未设置";
            
            today.text = NSLocalizedString(@"没有记录", nil);
            todayDetail.text = NSLocalizedString(@" ", nil);
            
        } else {
            lineLabelNum.text = [NSString stringWithFormat:@"目标:%@每天", [UserDefaultsUtils valueWithKey:FootTargetKey]];
        }
        
        lineLabelNum.font = [UIFont systemFontOfSize:12];
        lineLabelNum.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        lineLabelNum.textColor = HexRGBAlpha(0xfdfdfd, 0.4);
        lineLabelNum.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lineLabelNum];
        
        
        if ([NSArray arrayWithArray:[FetchSportDataUtil fetchAllDaysSportData]].count == 0) {
            lineLabelNum.text = @"无数据...";
            NSLog(@"没数据👽");
            lineLabelNum.font = [UIFont systemFontOfSize:20];
            lineLabel.alpha = 0;
        } else {
            lineLabelNum.text = @"数据加载中...";
            NSLog(@"数据加载中😍");
            lineLabelNum.font = [UIFont systemFontOfSize:20];
            lineLabel.alpha = 0;
        }
        
        UIView* tabView = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height, screen_width, 34)];
        tabView.tag = 2 + 888;
        tabView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
        [scrollView addSubview:tabView];
        
        UIView* trangleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        trangleView.tag = 24 +888;
        trangleView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
        trangleView.center = CGPointMake(self.view.center.x, backgroundView.frame.size.height - 20);
        [self.view addSubview:trangleView];
        trangleView.transform = CGAffineTransformMakeRotation(M_PI_4);
        
        UIView *leftViewWithBtn = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height-20+5, 42, 27)];
        leftViewWithBtn.tag = 25 + 888;
        leftViewWithBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
        [self.view addSubview:leftViewWithBtn];
        
        UIView *rightViewWithBtn = [[UIView alloc] initWithFrame:CGRectMake(screen_width - 40, backgroundView.frame.size.height-20+5, 42, 27)];
        rightViewWithBtn.tag = 26 + 888;
        rightViewWithBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
        [self.view addSubview:rightViewWithBtn];
        
        //增加日期和+ - 按钮
        UIButton* reduceBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        reduceBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
        [reduceBtn setBackgroundImage:[UIImage imageNamed:@"btn_sport_reduce_yes"] forState:UIControlStateNormal];
        reduceBtn.frame = CGRectMake(10, 0, 24, 24);
//        [reduceBtn addTarget:self action:@selector(reduceAction:) forControlEvents:UIControlEventTouchUpInside];
        [leftViewWithBtn addSubview:reduceBtn];
        
        UIButton* increaseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        increaseBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
        [increaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_sport_increase_yes"] forState:UIControlStateNormal];
        increaseBtn.frame = CGRectMake(10, 0, 24, 24);
//        [increaseBtn addTarget:self action:@selector(increaseAction:) forControlEvents:UIControlEventTouchUpInside];
        [rightViewWithBtn addSubview:increaseBtn];
        reduceBtn.enabled = NO;
        increaseBtn.enabled = NO;
        
        UIView* sportDetailBackview = [[UIView alloc] initWithFrame:CGRectMake(10, tabView.frame.size.height + backgroundView.frame.size.height-10, screen_width-20, 80)];
        sportDetailBackview.tag = 666 + 888;
        sportDetailBackview.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:sportDetailBackview];
        
        
        CGSize fitViewSize = CGSizeMake(sportDetailBackview.frame.size.width/4, sportDetailBackview.frame.size.height);
        FitnessView* fitView1 = [[FitnessView alloc] initWithFrame:CGRectMake(0, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_distance"] withLabel:NSLocalizedString(@"活动里程:米", nil) withResult:0];
        [sportDetailBackview addSubview:fitView1];
        fitView1.tag = 555 + 1 + 888;
        
        FitnessView* fitView2 = [[FitnessView alloc] initWithFrame:CGRectMake(1.5*sportDetailBackview.frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_foot"] withLabel:NSLocalizedString(@"全天步数:步", nil) withResult:0];
        [sportDetailBackview addSubview:fitView2];
        fitView2.tag = 555 + 2 + 888;
        
        FitnessView* fitView3 = [[FitnessView alloc] initWithFrame:CGRectMake(3*sportDetailBackview.frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_calorie"] withLabel:NSLocalizedString(@"能量消耗:卡", nil) withResult:0];
        [sportDetailBackview addSubview:fitView3];
        fitView3.tag = 555 + 3 + 888;
        
        UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
//        [shareButton addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:shareButton];
        [shareButton mas_makeConstraints:^(MASConstraintMaker* maker){
            maker.right.equalTo(self.view).with.offset(-20);
            maker.centerY.equalTo(titleLabel);
            maker.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
    } else {
        
    }
    
}

/**
 *  除去视图
 */
- (void)removeOldView {
    
    [[self.view viewWithTag:1 + 888] removeFromSuperview];
    [[self.view viewWithTag:23 + 888] removeFromSuperview];
    [[self.view viewWithTag:1111 + 888] removeFromSuperview];
    [[self.view viewWithTag:2222 + 888] removeFromSuperview];
    [[self.view viewWithTag:2323 + 888] removeFromSuperview];
    [[self.view viewWithTag:3232 + 888] removeFromSuperview];
    [[self.view viewWithTag:666 + 888] removeFromSuperview];
    [[self.view viewWithTag:25 + 888] removeFromSuperview];
    [[self.view viewWithTag:26 + 888] removeFromSuperview];
    
}

- (void) initFitnessUIOfThisView
{
    self.howMuch = self.arrOfDays.count;
    self.howMuchOld = self.arrOfDays.count;
    
    self.pageOfDays = self.arrOfDays.count / 10 + 2;
    
    CGFloat sportDataWidth = (self.pageOfDays + 1) * screen_width;
    
    for (UIView* view in self.view.subviews) {
        if(view.tag == 2016 || view.tag == 2017) continue;
        [view removeFromSuperview];
    }
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, screen_width, 2 * screen_height / 3 + 34)];
    scrollView.tag = 1;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(sportDataWidth, 0);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.contentOffset = CGPointMake(self.pageOfDays * screen_width, 0);
    [self.view addSubview:scrollView];
    if (self.arrOfDays.count == 0) {
        scrollView.scrollEnabled = NO;
    } else {
        scrollView.scrollEnabled = YES;
    }
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sportDataWidth, 2 * screen_height / 3)];
    backgroundView.tag = 3;
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
    today.tag = 1111;
    today.text = NSLocalizedString(@"没有记录", nil);
    today.textColor = HexRGBAlpha(0xfdfdfd, 0.5);
    today.textAlignment = NSTextAlignmentCenter;
    [today setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:today];
    today.center = CGPointMake(self.view.center.x, 64);
    
    UILabel* todayDetail = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    todayDetail.tag = 2222;
    todayDetail.text = NSLocalizedString(@" ", nil);
    todayDetail.textColor = HexRGBAlpha(0xfdfdfd, 0.85);
    todayDetail.textAlignment = NSTextAlignmentCenter;
    [todayDetail setFont:[UIFont systemFontOfSize:13]];
    [self.view addSubview:todayDetail];
    todayDetail.center = CGPointMake(self.view.center.x, 95);
    
    
    // 标准线
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 265 * (screen_width / 375.0) - 34 + 40, screen_width, 0.5)];
    lineLabel.tag = 2323;
    lineLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineLabel];
    lineLabel.alpha = 0.1;
    // 标准刻度值
    UILabel *lineLabelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 265 * (screen_width / 375.0) - 49 + 40 - 15, screen_width, 30)];
    lineLabelNum.tag = 3232;
    if ([UserDefaultsUtils valueWithKey:FootTargetKey] == nil) {
        lineLabelNum.text = @"目标步数未设置";
        
        today.text = NSLocalizedString(@"没有记录", nil);
        todayDetail.text = NSLocalizedString(@" ", nil);
        
    } else {
        lineLabelNum.text = [NSString stringWithFormat:@"目标:%@每天", [UserDefaultsUtils valueWithKey:FootTargetKey]];
    }
    lineLabelNum.font = [UIFont systemFontOfSize:12];
    lineLabelNum.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    lineLabelNum.textColor = HexRGBAlpha(0xfdfdfd, 0.2);
    lineLabelNum.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lineLabelNum];
    
    UIView* tabView = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height, sportDataWidth, 34)];
    tabView.tag = 2;
    tabView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [scrollView addSubview:tabView];
    
    UIView* trangleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    trangleView.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    trangleView.center = CGPointMake(self.view.center.x, backgroundView.frame.size.height - 20);
    [self.view addSubview:trangleView];
    trangleView.transform = CGAffineTransformMakeRotation(M_PI_4);
    
    // 创建所有视图、日周月共用
    [self sportsDataDetail:tabView withSuperView:backgroundView];
    
    UIView *leftViewWithBtn = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height-20+5, 42, 27)];
    leftViewWithBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [self.view addSubview:leftViewWithBtn];
    
    UIView *rightViewWithBtn = [[UIView alloc] initWithFrame:CGRectMake(screen_width - 40, backgroundView.frame.size.height-20+5, 42, 27)];
    rightViewWithBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [self.view addSubview:rightViewWithBtn];
    
    //增加日期和+ - 按钮
    UIButton* reduceBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reduceBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [reduceBtn setBackgroundImage:[UIImage imageNamed:@"btn_sport_reduce_yes"] forState:UIControlStateNormal];
    reduceBtn.frame = CGRectMake(10, 0, 24, 24);
    [reduceBtn addTarget:self action:@selector(reduceAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftViewWithBtn addSubview:reduceBtn];
    
    UIButton* increaseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    increaseBtn.backgroundColor = RGBColor(0xf3, 0xf3, 0xf3);
    [increaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_sport_increase_yes"] forState:UIControlStateNormal];
    increaseBtn.frame = CGRectMake(10, 0, 24, 24);
    [increaseBtn addTarget:self action:@selector(increaseAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightViewWithBtn addSubview:increaseBtn];
    if (self.arrOfDays.count == 0) {
        reduceBtn.enabled = NO;
        increaseBtn.enabled = NO;
    } else {
        reduceBtn.enabled = YES;
        increaseBtn.enabled = YES;
    }
    
    
    UIView* sportDetailBackview = [[UIView alloc] initWithFrame:CGRectMake(10, tabView.frame.size.height + backgroundView.frame.size.height-10, screen_width-20, 80)];
    sportDetailBackview.tag = 666;
    sportDetailBackview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sportDetailBackview];
    
    
    CGSize fitViewSize = CGSizeMake(sportDetailBackview.frame.size.width/4, sportDetailBackview.frame.size.height);
    FitnessView* fitView1 = [[FitnessView alloc] initWithFrame:CGRectMake(0, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_distance"] withLabel:NSLocalizedString(@"活动里程:米", nil) withResult:1990];
    [sportDetailBackview addSubview:fitView1];
    fitView1.tag = 555 + 1;
    
    FitnessView* fitView2 = [[FitnessView alloc] initWithFrame:CGRectMake(1.5*sportDetailBackview.frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_foot"] withLabel:NSLocalizedString(@"全天步数:步", nil) withResult:1990];
    [sportDetailBackview addSubview:fitView2];
    fitView2.tag = 555 + 2;
    
    FitnessView* fitView3 = [[FitnessView alloc] initWithFrame:CGRectMake(3*sportDetailBackview.frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_calorie"] withLabel:NSLocalizedString(@"能量消耗:卡", nil) withResult:1990];
    [sportDetailBackview addSubview:fitView3];
    fitView3.tag = 555 + 3;
    
    [self displayeDetial:200 andDayOrMounthNum:0];
    
    
    UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.right.equalTo(self.view).with.offset(-20);
        maker.centerY.equalTo(titleLabel);
        maker.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
}

/**
 *  分享按钮
 */
- (void)shareBtn {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"否" forKey:@"isShowFirstView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    
    [UMSocialData defaultData].extConfig.tencentData.shareImage = [UMSocialData defaultData].extConfig.tencentData.shareImage;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:@"Famar"
                                     shareImage:img
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone,UMShareToSina ,nil]
                                       delegate:self];
    
}

//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    [[NSUserDefaults standardUserDefaults] setObject:@"否" forKey:@"isShowFirstView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

- (void)dealloc {
    //    [[NSUserDefaults standardUserDefaults] setObject:@"是" forKey:@"isShowFirstView"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) sportsDataDetail:(UIView*)tabView withSuperView:(UIView*)superView
{
    for (NSInteger i = 0; i < self.howMuch; i ++) {
        // 24、40、60
        // 15、25、35
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pageOfDays * screen_width + (self.view.center.x-kSportDataWidth/2 - (kSportDataWidth + 15) * i), 0, kSportDataWidth, 34)];
        myLabel.tag = 20 + i;
        myLabel.textAlignment = NSTextAlignmentCenter;
        [myLabel setFont:[UIFont systemFontOfSize:12]];
        myLabel.textColor = HexRGBAlpha(0x090909, 0.4);
        [tabView addSubview:myLabel];
        
        // CGFloat rate = [[self.arrOfDays[i] objectForKey:[self.arrOfDays[i] allKeys][0]] floatValue] / 2000.0;
        // CGFloat myHeight = [[self.view viewWithTag:1] viewWithTag:3].frame.size.height - 250 * (screen_width / 375.0);
        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(self.pageOfDays * screen_width + (self.view.center.x-kSportDataWidth/2 - (kSportDataWidth + 15) * i), 1000, kSportDataWidth, 0)];// tabView.frame.origin.y-myHeight+20 + myHeight * (1 - rate) - 34、这边的1000没有什么用处，参考值
        myView.tag = 200 + i;
        myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
        [superView addSubview:myView];
        
        [self someChanged];
        
    }
    
    [self removeOldView];
    
}

/**
 *  减按钮、以及加按钮
 */
- (void) reduceAction:(UIButton*)sender
{
    self.DayOrMounth ++;
    [self someChanged];
    
}

- (void) increaseAction:(UIButton*)sender
{
    self.DayOrMounth --;
    [self someChanged];
    
}

/**
 *  滑动界面相关属性的改变
 */
- (void)someChanged {
    
    
    NSLog(@"进入someChanged");
    if (self.DayOrMounth < 0) {
        self.DayOrMounth = 0;
    }
    else if (self.DayOrMounth > 2) {
        self.DayOrMounth = 2;
    }
    
    [self.mutArr removeAllObjects];
    
    self.howMuchOld = self.howMuch;
    
    if (self.DayOrMounth == 0) {
        if(!self.arrOfDays || self.arrOfDays.count==0) return;
        
        self.howMuch = self.arrOfDays.count;
        [self.mutArr addObjectsFromArray:self.arrOfDays];
        
        // 这一天的步数
        NSString *str = [self.arrOfDays[0] objectForKey:[self.arrOfDays[0] allKeys][0]];
        
        UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
        title1.text = NSLocalizedString(@"今天记录", nil);
        
        UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
        title2.text = [NSString stringWithFormat:@"今天记录 %@步", str];
        
        UILabel *myLineLabel = (UILabel *)[self.view viewWithTag:2323];
        myLineLabel.alpha = 0.1;
        
        UILabel *myLineLabelNum = (UILabel *)[self.view viewWithTag:3232];
        myLineLabelNum.alpha = 0.8;
       NSLog(@"进入someChanged==0");
        [self displayeDetial:200 andDayOrMounthNum:0];
        
    } else if (self.DayOrMounth == 1) {
        if(!self.arrOfWeeks || self.arrOfWeeks.count==0) return;
        self.howMuch = self.arrOfWeeks.count;
        [self.mutArr addObjectsFromArray:self.arrOfWeeks];
        
        // 这一周的步数
        NSString *str = [self.arrOfWeeks[0] objectForKey:[self.arrOfWeeks[0] allKeys][0]];
        
        UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
        title1.text = NSLocalizedString(@"本周记录", nil);
        
        UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
        title2.text = [NSString stringWithFormat:@"本周记录 %@步", str];
        
        UILabel *myLineLabel = (UILabel *)[self.view viewWithTag:2323];
        myLineLabel.alpha = 0;
        
        UILabel *myLineLabelNum = (UILabel *)[self.view viewWithTag:3232];
        myLineLabelNum.alpha = 0.0;
        NSLog(@"进入someChanged==1");
        [self displayeDetial:200 andDayOrMounthNum:1];
        
    } else {
        
        if(!self.arrOfMounths || self.arrOfMounths.count==0) return;
        
        self.howMuch = self.arrOfMounths.count;
        [self.mutArr addObjectsFromArray:self.arrOfMounths];
        
        // 这一个月的步数
        NSString *str = [self.arrOfMounths[0] objectForKey:[self.arrOfMounths[0] allKeys][0]];
        
        UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
        title1.text = NSLocalizedString(@"本月记录", nil);
        
        UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
        title2.text = [NSString stringWithFormat:@"本月记录 %@步", str];
        
        UILabel *myLineLabel = (UILabel *)[self.view viewWithTag:2323];
        myLineLabel.alpha = 0;
        
        UILabel *myLineLabelNum = (UILabel *)[self.view viewWithTag:3232];
        myLineLabelNum.alpha = 0.0;
        NSLog(@"进入someChanged==2");
        [self displayeDetial:200 andDayOrMounthNum:2];
        
    }
    
    NSLog(@"离开someChanged");
    for (NSInteger i = 0 ; i < self.howMuch; i ++) {
        
        UILabel *myLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + i];
        myLabel.adjustsFontSizeToFitWidth = YES;
        UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + i];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOne:)];
        tapGes.numberOfTapsRequired = 1;
        tapGes.numberOfTouchesRequired = 1;
        myView.userInteractionEnabled = YES;
        [myView addGestureRecognizer:tapGes];
        
        if (self.DayOrMounth == 0) {
            [UIView animateWithDuration:1 animations:^{
                
                for (NSInteger k = 0; k < self.howMuch; k++) {
                    
                    UIView *myView1 = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + k];
                    myView1.alpha = 1;
                    myView1.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
                    
                    UILabel *myLabel1 = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + i];
                    myLabel1.alpha = 1;
                    myLabel1.textColor = HexRGBAlpha(0x090909, 0.4);
                    
                }
                
                NSLog(@"日%ld", ((kSportDataWidth + 15) * i));//39 - 24 = 15
                // 目标步数字符串
                NSString *strOfTagerFoots = [NSString new];
                if ([UserDefaultsUtils valueWithKey:FootTargetKey] == nil) {
                    strOfTagerFoots = @"3000步";
                } else {
                    strOfTagerFoots = [UserDefaultsUtils valueWithKey:FootTargetKey];
                }
                
                CGFloat targerFoots = [[strOfTagerFoots substringToIndex:(strOfTagerFoots.length - 0)] floatValue];
                NSLog(@"%lf", targerFoots);
                
                CGFloat rate;
                if (targerFoots >= [_arraya[self.arrOfDays.count - 1] floatValue]) {
                    
                    rate = [[self.arrOfDays[i] objectForKey:[self.arrOfDays[i] allKeys][0]] floatValue] / targerFoots;
                    
                } else {
                    
                    rate = [[self.arrOfDays[i] objectForKey:[self.arrOfDays[i] allKeys][0]] floatValue] / [_arraya[self.arrOfDays.count - 1] floatValue];
                    
                }
                
                CGFloat myHeight = [[self.view viewWithTag:1] viewWithTag:3].frame.size.height - 150 * (screen_width / 375.0);
                myView.frame = CGRectMake(self.pageOfDays * screen_width + (self.view.center.x-kSportDataWidth/2 - (kSportDataWidth + 15) * i), [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - rate) - 20, kSportDataWidth, myHeight + 34);
                
                if (screen_height == 736) {
                    
                    if (targerFoots >= [_arraya[self.arrOfDays.count - 1] floatValue]) {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 45 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 45, myLineLabelNum1.frame.size.width,0.5);
                        
                    } else {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 45 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 45, myLineLabelNum1.frame.size.width,0.5);
                        
                    }
                    
                } else if (screen_height == 667) {
                    
                    if (targerFoots >= [_arraya[self.arrOfDays.count - 1] floatValue]) {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 40 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 40, myLineLabelNum1.frame.size.width,0.5);
                        
                    } else {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 40 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 40, myLineLabelNum1.frame.size.width,0.5);
                        
                    }
                    
                } else if (screen_height == 568) {
                    
                    if (targerFoots >= [_arraya[self.arrOfDays.count - 1] floatValue]) {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 40 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 40, myLineLabelNum1.frame.size.width,0.5);
                        
                    } else {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 40 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 40, myLineLabelNum1.frame.size.width,0.5);
                        
                    }
                    
                } else {
                    
                    if (targerFoots >= [_arraya[self.arrOfDays.count - 1] floatValue]) {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 39 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / targerFoots)) - 39, myLineLabelNum1.frame.size.width,0.5);
                        
                    } else {
                        
                        UILabel *myLineLabelNum1 = (UILabel *)[self.view viewWithTag:3232];
                        myLineLabelNum1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 39 - 15, myLineLabelNum1.frame.size.width, 30);
                        
                        UILabel *myLineLabel1 = (UILabel *)[self.view viewWithTag:2323];
                        myLineLabel1.frame = CGRectMake(0, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - (targerFoots / [_arraya[self.arrOfDays.count - 1] floatValue])) - 39, myLineLabelNum1.frame.size.width,0.5);
                        
                    }
                    
                }
                
                myLabel.frame = CGRectMake(self.pageOfDays * screen_width + (self.view.center.x-kSportDataWidth/2 - (kSportDataWidth + 15) * i) - 7, 0, kSportDataWidth + 14, 34);
                
            }];
            
            myLabel.text = NSLocalizedString([self.mutArr[i] allKeys][0], nil);
            
        } else if (self.DayOrMounth == 1) {
            
            [UIView animateWithDuration:1 animations:^{
                
                for (NSInteger k = self.howMuch; k < self.howMuchOld; k++) {
                    
                    UIView *myView1 = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + k];
                    myView1.alpha = 0;
                    
                    UILabel *myLabel1 = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + k];
                    myLabel1.alpha = 0;
                    
                }
                
                for (NSInteger k = 0; k < self.howMuch; k++) {
                    
                    UIView *myView1 = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + k];
                    myView1.alpha = 1;
                    myView1.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
                    
                    UILabel *myLabel1 = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + k];
                    myLabel1.alpha = 1;
                    myLabel1.textColor = HexRGBAlpha(0x090909, 0.4);
                    
                }
                
                NSLog(@"周%ld", ((kSportDataWidth + 41) * i));//55 - 40 = 25
                CGFloat rate = [[self.arrOfWeeks[i] objectForKey:[self.arrOfWeeks[i] allKeys][0]] floatValue] / [_arrayb[self.arrOfWeeks.count - 1] floatValue];
                CGFloat myHeight = [[self.view viewWithTag:1] viewWithTag:3].frame.size.height - 150 * (screen_width / 375.0);
                
                if (rate > 1.0) {
                    
                } else {
                    
                }
                
                myView.frame = CGRectMake(self.pageOfDays * screen_width + (self.view.center.x-kSportDataWidth/2 - (kSportDataWidth + 41) * i) - 8, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - rate) - 34 + 15, kSportDataWidth * (40/24.0), myHeight + 34);
                
                myLabel.frame = CGRectMake(myView.center.x - kSportDataWidth * (40/24.0) / 2.0 - 12, 0, kSportDataWidth * (40/24.0) + 24, 34);
                
            }];
            
            myLabel.text = NSLocalizedString([self.mutArr[i] allKeys][0], nil);
            
        } else {
            
            [UIView animateWithDuration:1 animations:^{
                
                for (NSInteger k = self.howMuch; k < self.howMuchOld; k++) {
                    
                    UIView *myView1 = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + k];
                    myView1.alpha = 0;
                    
                    UILabel *myLabel1 = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + k];
                    myLabel1.alpha = 0;
                    
                }
                
                for (NSInteger k = 0; k < self.howMuch; k++) {
                    
                    UIView *myView1 = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + k];
                    myView1.alpha = 1;
                    myView1.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
                    
                    UILabel *myLabel1 = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + k];
                    myLabel1.alpha = 1;
                    myLabel1.textColor = HexRGBAlpha(0x090909, 0.4);
                    
                }
                
                
                
                NSLog(@"余额%ld", ((kSportDataWidth + 71) * i));//74 - 60 = 35
                CGFloat rate = [[self.arrOfMounths[i] objectForKey:[self.arrOfMounths[i] allKeys][0]] floatValue] / [_arrayc[self.arrOfMounths.count - 1] floatValue];
                CGFloat myHeight = [[self.view viewWithTag:1] viewWithTag:3].frame.size.height - 200 * (screen_width / 375.0);
                
                if (rate > 1.0) {
                    
                } else {
                    
                }
                
                myView.frame = CGRectMake(self.pageOfDays * screen_width + (self.view.center.x-kSportDataWidth/2 - (kSportDataWidth + 71) * i) - 18, [[self.view viewWithTag:1] viewWithTag:2].frame.origin.y-myHeight+20 + myHeight * (1 - rate) - 34 + 15, kSportDataWidth * (60/24.0), myHeight + 34);
                myLabel.frame = CGRectMake(myView.center.x - kSportDataWidth * (60/24.0) / 2.0 - 17, 0, kSportDataWidth * (60/24.0) + 34, 34);
                
            }];
            
            myLabel.text = NSLocalizedString([self.mutArr[i] allKeys][0], nil);
        }
    }
    
    [(UIScrollView *)[self.view viewWithTag:1] setContentOffset:CGPointMake(screen_width * self.pageOfDays, 0) animated:YES];
    UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200];
    myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
    
    UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20];
    titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
    
}

/**
 *  下方详情显示方法
 */
- (void)displayeDetial:(NSInteger)tag andDayOrMounthNum:(NSInteger)x {
    
    NSArray *arrOf1 = @[@"当天活动里程:千米", @"日均里程:千米", @"日均里程:千米"];
    NSArray* arrOf1_1 = @[@"当天活动里程:米", @"日均里程:米", @"日均里程:米"];
    
    NSArray *arrOf2 = @[@"当天步数:步", @"日均步数:步", @"日均步数:步"];
    NSArray *arrOf3 = @[@"当天能量消耗:千卡", @"日均消耗:千卡", @"日均消耗:千卡"];
    
    // 步数
    CGFloat mySteps;
    // 米数
    CGFloat myKm;
    // 卡路里
    CGFloat myEnergy;
    if (x == 0) {
        
        mySteps = [[self.arrOfDays[tag - 200] objectForKey:[self.arrOfDays[tag - 200] allKeys][0]] integerValue];
        myKm = mySteps * (([super personHeight] * 0.45/100.0)/1000.0);
        myEnergy = mySteps * (([super personWeight] - 13.63636) * 0.000693 + 0.00495);
        
    } else if (x == 1) {
        
        mySteps = ([[self.arrOfWeeks[tag - 200] objectForKey:[self.arrOfWeeks[tag - 200] allKeys][0]] integerValue]/ ([self.arrayZhou[tag - 200] floatValue]));
        myKm = (mySteps * ([super personHeight] * 0.45/100.0)/1000.0);
        NSLog(@"%lf", [self.arrayZhou[tag - 200] floatValue]);
        myEnergy = (mySteps * (([super personWeight] - 13.63636) * 0.000693 + 0.00495) );
        
    } else {
        
        mySteps = ([[self.arrOfMounths[tag - 200] objectForKey:[self.arrOfMounths[tag - 200] allKeys][0]] integerValue]/ ([self.arrayYue[tag - 200] floatValue]));
        myKm = (mySteps * (([super personHeight] * 0.45/100.0)/1000.0));
        myEnergy = (mySteps * (([super personWeight] - 13.63636) * 0.000693 + 0.00495));
        
    }
    
    for (NSInteger l = 0; l < 3; l ++) {
        
        FitnessView *myFitView = [[self.view viewWithTag:666] viewWithTag:(555 + l + 1)];
        [myFitView removeFromSuperview];
        
    }
    CGSize fitViewSize = CGSizeMake([self.view viewWithTag:666].frame.size.width/4, [self.view viewWithTag:666].frame.size.height);
    
    FitnessView* fitView1 = [[FitnessView alloc] initWithFrame:CGRectMake(0, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_distance"] withLabel:myKm<1?NSLocalizedString(arrOf1_1[x], nil):NSLocalizedString(arrOf1[x], nil) withResult:myKm<1?myKm*1000:myKm];
    [[self.view viewWithTag:666] addSubview:fitView1];
    fitView1.tag = 555 + 1;
    
    FitnessView* fitView2 = [[FitnessView alloc] initWithFrame:CGRectMake(1.5*[self.view viewWithTag:666].frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_foot"] withLabel:NSLocalizedString(arrOf2[x], nil) withResult:(int)mySteps];
    [[self.view viewWithTag:666] addSubview:fitView2];
    fitView2.tag = 555 + 2;
    
    FitnessView* fitView3 = [[FitnessView alloc] initWithFrame:CGRectMake(3*[self.view viewWithTag:666].frame.size.width/4, 0, fitViewSize.width, fitViewSize.height) withImg:[UIImage imageNamed:@"icon_sport_calorie"] withLabel:NSLocalizedString(arrOf3[x], nil) withResult:myEnergy];
    [[self.view viewWithTag:666] addSubview:fitView3];
    fitView3.tag = 555 + 3;
    
}

/**
 *  点击手势
 */
- (void)tapOne:(UITapGestureRecognizer *)sender {
    
    for (NSInteger i = 0; i < self.arrOfDays.count; i ++) {
        
        UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + i];
        myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
        
        UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + i];
        titleLabel.textColor = HexRGBAlpha(0x090909, 0.4);
    }
    
    if (self.DayOrMounth == 0) {
        
        [(UIScrollView *)[self.view viewWithTag:1] setContentOffset:CGPointMake(screen_width * self.pageOfDays - (sender.view.tag - 200) * 39, 0) animated:YES];
        UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:sender.view.tag];
        myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
        
        UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:sender.view.tag - 180];
        titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
        
        UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
        title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfDays[sender.view.tag - 200] allKeys][0]];
        
        UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
        title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfDays[sender.view.tag - 200] allKeys][0], [self.arrOfDays[sender.view.tag - 200] objectForKey:[self.arrOfDays[sender.view.tag - 200] allKeys][0]]];
        
        [self displayeDetial:sender.view.tag andDayOrMounthNum:0];
        
    } else if (self.DayOrMounth == 1) {
        
        [(UIScrollView *)[self.view viewWithTag:1] setContentOffset:CGPointMake(screen_width * self.pageOfDays - (sender.view.tag - 200) * 65, 0) animated:YES];
        UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:sender.view.tag];
        myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
        
        UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:sender.view.tag - 180];
        titleLabel.text = [self.arrOfWeeks[sender.view.tag - 200] allKeys][0];
        titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
        
        UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
        title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfWeeks[sender.view.tag - 200] allKeys][0]];
        
        UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
        title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfWeeks[sender.view.tag - 200] allKeys][0], [self.arrOfWeeks[sender.view.tag - 200] objectForKey:[self.arrOfWeeks[sender.view.tag - 200] allKeys][0]]];
        
        [self displayeDetial:sender.view.tag andDayOrMounthNum:1];
        
    } else {
        
        [(UIScrollView *)[self.view viewWithTag:1] setContentOffset:CGPointMake(screen_width * self.pageOfDays - (sender.view.tag - 200) * 95, 0) animated:YES];
        UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:sender.view.tag];
        myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
        
        UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:sender.view.tag - 180];
        titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
        
        UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
        title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfMounths[sender.view.tag - 200] allKeys][0]];
        
        UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
        title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfMounths[sender.view.tag - 200] allKeys][0], [self.arrOfMounths[sender.view.tag - 200] objectForKey:[self.arrOfMounths[sender.view.tag - 200] allKeys][0]]];
        
        [self displayeDetial:sender.view.tag andDayOrMounthNum:2];
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

/**
 *  清除所有色块
 */
- (void)clearEveryViewColor {
    
    for (NSInteger i = 0; i < self.arrOfDays.count; i ++) {
        
        UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + i ];
        myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.4);
        
        UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + i];
        titleLabel.textColor = HexRGBAlpha(0x090909, 0.4);
        
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self clearEveryViewColor];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self animationOfScrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self animationOfScrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

/**
 *  UIScrollView 动画想换逻辑代码
 */
- (void)animationOfScrollView {
    
    UIScrollView *scrollView = [self.view viewWithTag:1];
    
    [self clearEveryViewColor];
    
    if (self.DayOrMounth == 0) {
        
        if (scrollView.contentOffset.x <= screen_width * (self.pageOfDays + 1) - self.howMuch * 39 - 2 * screen_width / 2.0 + 39) {
            
            UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + self.arrOfDays.count - 1];
            myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
            
            [scrollView setContentOffset:CGPointMake(screen_width * (self.pageOfDays + 1) - self.howMuch * 39 - 2 * screen_width / 2.0 + 39, 0) animated:YES];
            
            UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + self.arrOfDays.count - 1];
            titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
            
            UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
            title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfDays[200 + self.arrOfDays.count - 1 - 200] allKeys][0]];
            
            UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
            title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfDays[200 + self.arrOfDays.count - 1 - 200] allKeys][0], [self.arrOfDays[200 + self.arrOfDays.count - 1 - 200] objectForKey:[self.arrOfDays[200 + self.arrOfDays.count - 1 - 200] allKeys][0]]];
            
            [self displayeDetial:(200 + self.arrOfDays.count - 1) andDayOrMounthNum:0];
            
        } else {
            
            if (((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) % 39 < 39) && ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) % 39 > 12)) {
                
                UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1)];
                myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
                
                [scrollView setContentOffset:CGPointMake(screen_width * self.pageOfDays - ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1) * 39, 0) animated:YES];
                
                UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1)];
                titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
                
                UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
                title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1) - 200] allKeys][0]];
                
                UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
                title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1) - 200] allKeys][0], [self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1) - 200] objectForKey:[self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1) - 200] allKeys][0]]];
                
                [self displayeDetial:(200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39 + 1)) andDayOrMounthNum:0];
                
            } else {
                
                UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39)];
                myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
                
                [scrollView setContentOffset:CGPointMake(screen_width * self.pageOfDays - ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39) * 39, 0) animated:YES];
                
                UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39)];
                titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
                
                UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
                title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39) - 200] allKeys][0]];
                
                UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
                title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39) - 200] allKeys][0], [self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39) - 200] objectForKey:[self.arrOfDays[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39) - 200] allKeys][0]]];
                
                [self displayeDetial:(200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 39)) andDayOrMounthNum:0];
                
            }
            
        }
        
    } else if (self.DayOrMounth == 1) {
        
        if (scrollView.contentOffset.x <= screen_width * (self.pageOfDays + 1) - self.howMuch * 65 - 2 * screen_width / 2.0 + 65) {
            
            UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + self.arrOfWeeks.count - 1];
            myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
            
            [scrollView setContentOffset:CGPointMake(screen_width * (self.pageOfDays + 1) - self.howMuch * 65 - 2 * screen_width / 2.0 + 65, 0) animated:YES];
            
            UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + self.arrOfWeeks.count - 1];
            titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
            
            UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
            title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfWeeks[200 + self.arrOfWeeks.count - 1 - 200] allKeys][0]];
            
            UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
            title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfWeeks[200 + self.arrOfWeeks.count - 1 - 200] allKeys][0], [self.arrOfWeeks[200 + self.arrOfWeeks.count - 1 - 200] objectForKey:[self.arrOfWeeks[200 + self.arrOfWeeks.count - 1 - 200] allKeys][0]]];
            
            [self displayeDetial:(200 + self.arrOfWeeks.count - 1) andDayOrMounthNum:1];
            
        } else {
            
            if (((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) % 65 < 65) && ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) % 65 > 20)) {
                
                UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1)];
                myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
                
                [scrollView setContentOffset:CGPointMake(screen_width * self.pageOfDays - ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1) * 65, 0) animated:YES];
                
                UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1)];
                titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
                
                UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
                title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1) - 200] allKeys][0]];
                
                UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
                title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1) - 200] allKeys][0], [self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1) - 200] objectForKey:[self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1) - 200] allKeys][0]]];
                
                [self displayeDetial:(200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65 + 1)) andDayOrMounthNum:1];
                
            } else {
                
                UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65)];
                myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
                
                [scrollView setContentOffset:CGPointMake(screen_width * self.pageOfDays - ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65) * 65, 0) animated:YES];
                
                UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65)];
                titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
                
                UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
                title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65) - 200] allKeys][0]];
                
                UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
                title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65) - 200] allKeys][0], [self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65) - 200] objectForKey:[self.arrOfWeeks[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65) - 200] allKeys][0]]];
                
                [self displayeDetial:(200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 65)) andDayOrMounthNum:1];
                
            }
            
        }
        
    } else {
        
        if (scrollView.contentOffset.x <= screen_width * (self.pageOfDays + 1) - self.howMuch * 95 - 2 * screen_width / 2.0 + 95) {
            
            UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + self.arrOfMounths.count - 1];
            myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
            
            [scrollView setContentOffset:CGPointMake(screen_width * (self.pageOfDays + 1) - self.howMuch * 95 - 2 * screen_width / 2.0 + 95, 0) animated:YES];
            
            UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + self.arrOfMounths.count - 1];
            titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
            
            
            UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
            title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfMounths[200 + self.arrOfMounths.count - 1 - 200] allKeys][0]];
            
            UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
            title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfMounths[200 + self.arrOfMounths.count - 1 - 200] allKeys][0], [self.arrOfMounths[200 + self.arrOfMounths.count - 1 - 200] objectForKey:[self.arrOfMounths[200 + self.arrOfMounths.count - 1 - 200] allKeys][0]]];
            
            [self displayeDetial:(200 + self.arrOfMounths.count - 1) andDayOrMounthNum:2];
            
        } else {
            
            if (((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) % 65 < 95) && ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) % 95 > 30)) {
                
                UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1)];
                myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
                
                [scrollView setContentOffset:CGPointMake(screen_width * self.pageOfDays - ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1) * 95, 0) animated:YES];
                
                UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1)];
                titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
                
                UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
                title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1) - 200] allKeys][0]];
                
                UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
                title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1) - 200] allKeys][0], [self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1) - 200] objectForKey:[self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1) - 200] allKeys][0]]];
                
                [self displayeDetial:(200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95 + 1)) andDayOrMounthNum:2];
                
            } else {
                
                UIView *myView = (UIView *)[[[self.view viewWithTag:1] viewWithTag:3] viewWithTag:200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95)];
                myView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.8);
                
                [scrollView setContentOffset:CGPointMake(screen_width * self.pageOfDays - ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95) * 95, 0) animated:YES];
                
                UILabel *titleLabel = (UILabel *)[[[self.view viewWithTag:1] viewWithTag:2] viewWithTag:20 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95)];
                titleLabel.textColor = HexRGBAlpha(0x090909, 0.8);
                
                UILabel *title1 = (UILabel *)[self.view viewWithTag:1111];
                title1.text = [NSString stringWithFormat:@"%@记录", [self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95) - 200] allKeys][0]];
                
                UILabel *title2 = (UILabel *)[self.view viewWithTag:2222];
                title2.text = [NSString stringWithFormat:@"%@记录 %@步", [self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95) - 200] allKeys][0], [self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95) - 200] objectForKey:[self.arrOfMounths[200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95) - 200] allKeys][0]]];
                
                [self displayeDetial:(200 + ((NSInteger)(-(scrollView.contentOffset.x - screen_width * self.pageOfDays)) / 95)) andDayOrMounthNum:2];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
