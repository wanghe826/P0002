//
//  FunctionViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//
#import <PgySDK/PgyManager.h>
#import "SportsDataUtil.h"
#import "FunctionViewController.h"
#import "PersonInfoSettingViewController.h"
#import "ClockViewController.h"
#import "AboutSystemViewController.h"
#import "TimingViewController.h"
#import "Masonry.h"
#import "PhoneRemindXLFormViewController.h"
#import "PairedViewController.h"
#import "FitnessViewController.h"
#import "TodayFitnessViewController.h"
#import "StepProgressView.h"
#import "YALContextMenuTableView.h"

#import "CustomMenuItem.h"
#import "SportSleepSettingViewController.h"
#import "FXBlurView.h"
#import "PersonInfoModel.h"
#import "FetchSportDataUtil.h"
#import "SportModel.h"
#import "LineProgressView.h"
#import "UserDefaultsUtils.h"
#import "HelpViewController.h"
#import "PersonInfoModel.h"
#import "MenuView.h"
#import "SVProgressHUD.h"
#import "AppUtils.h"

#import "TakePhotoViewController.h"

#import "HistoryViewController.h"

@interface FunctionViewController()<UITableViewDataSource,UITableViewDelegate,YALContextMenuTableViewDelegate>

@property (nonatomic, strong) FXBlurView* blurView;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;
@property (nonatomic, strong) NSArray *photoArr;        //存储照片
@property (nonatomic, strong) MenuView *menuView;

@end

@implementation FunctionViewController

// 懒加载初始化 menuView
//- (MenuView *)menuView {
//    if (!_menuView) {
//        _menuView = [MenuView new];
//        _menuView.backgroundColor = [UIColor clearColor];
//        _menuView.frame = CGRectMake(0, 0, screen_width, screen_height);
//        __block id anObject = self;
//        _menuView.returnBlock = ^(NSInteger row){
//            [anObject returnBlockBack:row];
//        };
//    }
//    return _menuView;
//}

- (void)returnBlockBack:(NSInteger)row {
    int num = (int)row;
    if(num == 3)
    {
        if([BLEAppContext shareBleAppContext].isConnected)
        {
            //断开连接
            //            [[NSNotificationCenter defaultCenter] postNotificationName:BLESelfDisconnectNotification object:nil];
            //            [[JGBLEManager sharedManager] cancelDeviceConnect];
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"确定断开蓝牙连接吗？", nil) message:NSLocalizedString(@"断开连接后请前往设置手动删掉该蓝牙的配对信息", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
            [alertView show];
            return;
        }
        else
        {
            //手表配对
            BOOL BleStateOn = [ApplicationDelegate checkBleStateOn];
            if (BleStateOn)
            {
                PairedViewController* pariVc = [[PairedViewController alloc] init];
                [self.navigationController pushViewController:pariVc animated:YES];
            }
            return;
            
        }
    }
    
    //    [tableView dismisWithIndexPath:indexPath];
//    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    //
    //
    //    [self.blurView removeFromSuperview];
    //    self.blurView = nil;
    
    switch (num)
    {
        case 0:
        {
            //个人信息
            PersonInfoSettingViewController* personVc = [[PersonInfoSettingViewController alloc] init];
            [self.navigationController pushViewController:personVc animated:YES];
            break;
        }
        case 1:
        {
            //智能闹钟
            ClockViewController* clockVc = [[ClockViewController alloc] init];
            clockVc.clockModelArray = ApplicationDelegate.clockModels;
            [self.navigationController pushViewController:clockVc animated:YES];
            break;
        }
        case 2:
        {
            //智能校时
            TimingViewController* autoVc = [[TimingViewController alloc] init];
            [self.navigationController pushViewController:autoVc animated:YES];
            break;
        }
            
        case 4:
        {
            //运动设置
            SportSleepSettingViewController* sportSettingVc = [[SportSleepSettingViewController alloc] init];
            [self.navigationController pushViewController:sportSettingVc animated:YES];
            break;
        }
        case 5:
        {
            //关于系统
            AboutSystemViewController* aboutVc = [[AboutSystemViewController alloc] init];
            [self.navigationController pushViewController:aboutVc animated:YES];
            break;
        }
        case 6:
        {
            //帮助
            HelpViewController* help = [HelpViewController new];
            [self.navigationController pushViewController:help animated:YES];
            break;
        }
        default: {
            [UIView animateWithDuration:0.5f animations:^{
                _menuView.alpha = 0;
                _blurView.alpha = 0;
            } completion:^(BOOL finished) {
                _menuView = nil;
                _blurView = nil;
            }];
        }
            break;
    }
}

-(void)reConn{
    JGBLEManager* bleMgr = [JGBLEManager sharedManager];
    
    if(![BLEAppContext shareBleAppContext].isInSearchVC && ![BLEAppContext shareBleAppContext].isConnected && ![BLEAppContext shareBleAppContext].isSelfDisconnect)
    {
        NSLog(@"-----------尝试重连-------!!");
        [bleMgr connectDeviceByIdentifier:bleMgr.preConnectedDevice.identifier timeout:5];
    }
}

- (void) startReconnect
{
    JGBLEManager* bleMgr = [JGBLEManager sharedManager];
//    //如果之前有已经配对好的蓝牙设备，则直接连接
//    if ([bleMgr isSystemConnectedBlesContain: [bleMgr preConnectedDevice].identifier]) {
//        NSLog(@"之前有配对");
//        [self performSelector:@selector(reConn) withObject:self afterDelay:5];
//    }else{
//        NSLog(@"之前无配对");
//    }
    [bleMgr retrievePeriphralBySystem];               //保持app和手表的连接状态 与 系统和手表的连接状态同步
    
    [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(reConn) userInfo:nil repeats:YES];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    ApplicationDelegate.isInFunctionVc = YES;
    
    //获取当前语言环境
    if([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
    {
        _photoArr = [NSArray arrayWithObjects:@"btn_reminder_en",@"btn_sport副本",@"btn_camera_en",nil];
    }
    else
    {
        _photoArr = [NSArray arrayWithObjects:@"btn_reminder",@"btn_sport",@"btn_camera", nil];
    }
    
    [self startReconnect];
   [[PgyManager sharedPgyManager] checkUpdate];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _sportDatas = [FetchSportDataUtil fetchOneDaySportData:[NSDate date]];
    });
    
    self.view.userInteractionEnabled = YES;
    if (screen_height == 568)
    {
        _logoSize = 230;
    }
    else if (screen_height == 667)
    {
        _logoSize = 280;
    }
    else if(screen_height == 736)
    {
        _logoSize = 300;
    }
    else
    {
        _logoSize = 200;
    }
    [self initUI];
    [self initNavigationView];
    [self initiateMenuOptions];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:BLEDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProgressView) name:@"DownloadFootDataCompletion" object:nil];
}

- (void) initiateMenuOptions
{
    self.menuTitles = @[NSLocalizedStringFromTable(@"个人信息", @"Localizable", nil), NSLocalizedStringFromTable(@"智能闹钟", @"Localizable", nil), NSLocalizedStringFromTable(@"智能校时", @"Localizable", nil), NSLocalizedStringFromTable(@"手表配对", @"Localizable", nil),  NSLocalizedStringFromTable(@"运动设置", @"Localizable", nil), NSLocalizedStringFromTable(@"关于系统", @"Localizable", nil),  NSLocalizedStringFromTable(@"帮助", @"Localizable", nil)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"shishishuaxin" object:nil];
    
    PersonInfoModel* model = nil;
    if([[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo]){
        NSData* data = [[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo];
        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if(model)
    {
        _userNameLabel.text = model.username;
    }
    else
    {
        _userNameLabel.text = NSLocalizedString(@"华唛智能", nil);
    }
}

- (void)refreshView
{
    if([BLEAppContext shareBleAppContext].isConnected)
    {
        _connectLabel.text = NSLocalizedString(@"已连接", nil);
    }
    else
    {
        _connectLabel.text = NSLocalizedString(@"未连接", nil);
    }
    
//    [self.contextMenuTableView reloadData];
    [self.menuView refreshUIMenu];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ApplicationDelegate.isInFunctionVc = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void) initNavigationView
{
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    titleLabel.text = NSLocalizedString(@"华唛智能", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.center = CGPointMake(self.view.center.x, 40);
    [self.view addSubview:titleLabel];
    
    _connectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];   //修改_connectLabel的frame；
    
    
    if([BLEAppContext shareBleAppContext].isConnected)
    {
        _connectLabel.text = NSLocalizedString(@"已连接", nil);
    }
    else
    {
        _connectLabel.text = NSLocalizedString(@"未连接", nil);
    }
    
    _connectLabel.textAlignment = NSTextAlignmentCenter;
    [_connectLabel setFont:[UIFont systemFontOfSize:12]];
    _connectLabel.center = CGPointMake(self.view.center.x, 70);
    _connectLabel.textColor = HexRGBAlpha(0xfdfdfd, 0.6);
    [self.view addSubview:_connectLabel];
    
    _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 20, 24, 24)];
    _leftBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_leftBtn setImage:[UIImage imageNamed:@"icon_sport_data"] forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(sportMenuAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leftBtn];
    [self.view bringSubviewToFront:_leftBtn];
    
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.size.mas_equalTo(CGSizeMake(44, 44));
        maker.left.mas_equalTo(self.view.mas_left).with.offset(5);
        maker.centerY.mas_equalTo(titleLabel);
    }];
    
    
    UIButton* rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(screen_width-39, 20, 24, 24)];
    rightBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    [rightBtn setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    [self.view bringSubviewToFront:rightBtn];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.size.mas_equalTo(CGSizeMake(44, 44));
        maker.right.mas_equalTo(self.view.mas_right).with.offset(-5);
        maker.centerY.mas_equalTo(titleLabel);
    }];
    
}

- (void)sportMenuAction
{
//    TodayFitnessViewController* todayFitVc = [[TodayFitnessViewController alloc] init];
    HistoryViewController* todayFitVc = [HistoryViewController new];
    
    [self.navigationController pushViewController:todayFitVc animated:YES];
}

//- (FXBlurView*)blurView
//{
//    if(!_blurView)
//    {
//        _blurView = [[FXBlurView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        _blurView.dynamic = NO;
//        _blurView.blurRadius = 15;
//        _blurView.tintColor = [UIColor clearColor];
//    }
//    return _blurView;
//}

- (void)moreAction:(UIButton*)sender
{
    sender.enabled = NO;
    ApplicationDelegate.isInFunctionVc = NO;
    
    _blurView = [[FXBlurView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _blurView.dynamic = NO;
    _blurView.blurRadius = 15;
    _blurView.tintColor = [UIColor clearColor];
    [self.view addSubview:self.blurView];
    _blurView.alpha = 0;
    
    
    _menuView = [MenuView new];
    _menuView.backgroundColor = [UIColor clearColor];
    _menuView.frame = CGRectMake(0, 0, screen_width, screen_height);
    __block id anObject = self;
    _menuView.returnBlock = ^(NSInteger row){
        [anObject returnBlockBack:row];
    };
    [self.view addSubview:self.menuView];
    
    _menuView.alpha = 0;
    NSLog(@"%lf", _scrollView.contentOffset.x);
    
    [UIView animateWithDuration:0.5f animations:^{
        _menuView.alpha = 1;
        _blurView.alpha = 1;
    } completion:^(BOOL finished) {
//        _menuView.frame = CGRectMake(self.contextMenuTableView.contentOffset.x, 0, screen_width, screen_height);
//        _blurView.frame = CGRectMake(100, 0, screen_width, screen_height);
    }];
    
//    [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
//    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

- (YALContextMenuTableView*)contextMenuTableView
{
    if(!_contextMenuTableView)
    {
        _contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        _contextMenuTableView.animationDuration = 0.05;
        //optional - implement custom YALContextMenuTableView custom protocol
        _contextMenuTableView.yalDelegate = self;
        _contextMenuTableView.separatorColor = HexRGBAlpha(0xfdfdfd, 0.1);
        _contextMenuTableView.scrollEnabled = NO;
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 80)];
        //        self.contextMenuTableView.tableFooterView = view;
        _contextMenuTableView.tableHeaderView = view;
        
        UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(screen_width-48, 40, 30, 30);
        [closeButton setBackgroundImage:[UIImage imageNamed:@"icon_cross"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeTableView:) forControlEvents:UIControlEventTouchUpInside];
        [_contextMenuTableView addSubview:closeButton];
    }
    return _contextMenuTableView;
}


- (void) closeTableView:(UIButton*)sender
{
    if(_pageControl.currentPage==1)
    {
        ApplicationDelegate.isInFunctionVc = YES;
    }
    
    sender.enabled = NO;
    [self.blurView removeFromSuperview];
    self.blurView = nil;
    [self.contextMenuTableView dismisWithIndexPath:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

- (void) initUI
{
    //    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, screen_width, screen_height-100)];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    _scrollView.scrollEnabled = YES;
    _scrollView.contentSize = CGSizeMake(screen_width*3, 0);
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentOffset = CGPointMake(screen_width, 0);
    [_scrollView addSubview:[self phoneRemindView]];
    [_scrollView addSubview:[self fitnessView]];
    [_scrollView addSubview:[self remotePhotoView]];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, screen_height-110, screen_width, 30)];
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 1;
    _pageControl.pageIndicatorTintColor = HexRGBAlpha(0xfdfdfd, 0.3);
    _pageControl.currentPageIndicatorTintColor = HexRGBAlpha(0xfdfdfd, 0.8);
    [self.view addSubview:_pageControl];
    
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height-75, screen_width, 75)];
    _bottomView.backgroundColor = HexRGBAlpha(0xfdfdfd, 0.25);
    [self.view addSubview:_bottomView];
    
    _bottomBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _bottomBtn.frame = CGRectMake(0, 0, 150, 35);
    [_bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_sport"] forState:UIControlStateNormal];
    _bottomBtn.center = _bottomView.center;
    [_bottomBtn addTarget:self action:@selector(functionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bottomBtn];
    
}


- (void) functionAction
{
    int pageIndex = (int)_pageControl.currentPage;
    
    /*
     fade     //交叉淡化过渡(不支持过渡方向)
     push     //新视图把旧视图推出去
     moveIn   //新视图移到旧视图上面
     reveal   //将旧视图移开,显示下面的新视图
     cube     //立方体翻滚效果
     oglFlip  //上下左右翻转效果
     suckEffect   //收缩效果，如一块布被抽走(不支持过渡方向)
     rippleEffect //滴水效果(不支持过渡方向)
     pageCurl     //向上翻页效果
     pageUnCurl   //向下翻页效果
     cameraIrisHollowOpen  //相机镜头打开效果(不支持过渡方向)
     cameraIrisHollowClose //相机镜头关上效果(不支持过渡方向)
     */
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    switch (pageIndex) {
        case 0:
        {
            [animation setType:@"rippleEffect"];
            PhoneRemindXLFormViewController* phoneVc = [[PhoneRemindXLFormViewController alloc] init];
            [self.navigationController pushViewController:phoneVc animated:YES];
            break;
        }
        case 1:
        {
//            if(!_fitVc)
//            {
//                _fitVc = [[FitnessViewController alloc] init];
//            }
//            _fitVc.sportDatas = _sportDatas;
//            [self.navigationController pushViewController:_fitVc animated:YES];
            FitnessViewController* fit = [FitnessViewController new];
            [self.navigationController pushViewController:fit animated:YES];
            break;
        }
        case 2:
        {
            [animation setType:@"cameraIrisHollowOpen"];
            
            JGBLEManager *manager = [JGBLEManager sharedManager];
            if(manager->_hasReadytoDownloadSportData)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"正在同步数据，请稍后", nil)];
                return;
            }
//            [self.navigationController.view.layer addAnimation:animation forKey:nil];
//            SCNavigationController *nav = [[SCNavigationController alloc] init];
//            nav.scNaigationDelegate = self;
//            [nav showCameraWithParentController:self];
            TakePhotoViewController* takePhotoVc = [[TakePhotoViewController alloc] init];
//            [self.navigationController pushViewController:takePhotoVc animated:YES];
            [self.navigationController presentViewController:takePhotoVc animated:YES completion:nil];
            
            break;
        }
        default:
            break;
    }
}


- (UIView*)phoneRemindView
{
    UIView* phoneRemindView = [[UIView alloc] initWithFrame:CGRectMake(0, -44, screen_width, screen_height+44)];
    phoneRemindView.backgroundColor = RGBColor(0x1f, 0x94, 0xf3);
    
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width/2-_logoSize/2, (screen_height-_logoSize)/2, _logoSize, _logoSize)];
    iv.image = [UIImage imageNamed:@"img_reminder"];
    iv.userInteractionEnabled = YES;
    //    iv.center = CGPointMake(phoneRemindView.center.x, phoneRemindView.center.y);
    [phoneRemindView addSubview:iv];
    
    
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 50)];
    label.textColor = [UIColor whiteColor];
    label.adjustsFontSizeToFitWidth = YES;
    [label setFont:[UIFont boldSystemFontOfSize:20]];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(iv.center.x, iv.center.y+110);
    [phoneRemindView addSubview:label];
    _userNameLabel = label;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reminderAction:)];
    [iv addGestureRecognizer:tapGesture];
    return phoneRemindView;
}

- (UIView*)fitnessView
{
    NSDictionary* dataDic = [self caculateData];
    int footData = 0;
    float footKm = 0;
    float footKcal = 0;
    if(dataDic)
    {
        footData = [[dataDic objectForKey:@"footData"] intValue];
        footKm = [[dataDic objectForKey:@"footKm"] floatValue];
        footKcal = [[dataDic objectForKey:@"footKcal"] floatValue];
    }
    
    
    //    UIView* fitnessView = [[UIView alloc] initWithFrame:CGRectMake(screen_width, -44, screen_width, screen_height-100)];
    UIView* fitnessView = [[UIView alloc] initWithFrame:CGRectMake(screen_width, -44, screen_width, screen_height+44)];
    fitnessView.backgroundColor = RGBColor(0xe1, 0x65, 0x28);
    
    _fitnessCircleView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width/2-_logoSize/2, (screen_height-_logoSize)/2, _logoSize, _logoSize)];
    _fitnessCircleView.tag = 678;
    _fitnessCircleView.userInteractionEnabled = YES;
    _fitnessCircleView.image = [UIImage imageNamed:@"img_sport_circle"];
    [fitnessView addSubview:_fitnessCircleView];
    
    
    float target = 0.0f;
    if(![[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey])
    {
        target = 10000;
    }
    else
    {
        target = [[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey];
    }
    float rate = (float)footData / target;
    [self addProgressViewAnimation:rate];
    
    UILabel* stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    stepLabel.text = NSLocalizedString(@"今日总步数", nil);
    stepLabel.textAlignment = NSTextAlignmentCenter;
    stepLabel.textColor = HexRGBAlpha(0xfdfdfd, 0.3);
    [stepLabel setFont:[UIFont systemFontOfSize:18]];
    stepLabel.center = CGPointMake(105, _fitnessCircleView.frame.size.height/3);
    [_fitnessCircleView addSubview:stepLabel];

    
    _allStep = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 70)];
    _allStep.text = [NSString stringWithFormat:@"%d", footData];
    _allStep.textColor = HexRGBAlpha(0xfdfdfd, 0.8);
    _allStep.textAlignment = NSTextAlignmentCenter;
    [_allStep setFont:[UIFont systemFontOfSize:40]];
    _allStep.center = CGPointMake(105, stepLabel.frame.size.height+60);
    [_fitnessCircleView addSubview:_allStep];
    [_allStep mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.center.equalTo(_fitnessCircleView);
        maker.size.mas_equalTo(CGSizeMake(180,70));
    }];
    
    [stepLabel mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.size.mas_equalTo(CGSizeMake(100, 50));
        maker.bottom.mas_equalTo(_allStep.mas_top).with.offset(20);
        maker.centerX.mas_equalTo(_allStep.mas_centerX);
    }];
    
    _energyAndKm = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 70)];
    
    if(footKm<1)
    {
        _energyAndKm.text = [NSString stringWithFormat:@"%.0f%@  %.0f%@", footKm,NSLocalizedString(@"米", nil), footKcal*1000,NSLocalizedString(@"千卡",nil)];
    }
    else
        
    {
        _energyAndKm.text = [NSString stringWithFormat:@"%.0f%@  %.0f%@", footKm,NSLocalizedString(@"千米", nil), footKcal,NSLocalizedString(@"千卡",nil)];
    }
    _energyAndKm.textColor = HexRGBAlpha(0xfdfdfd, 0.3);
    [_energyAndKm setFont:[UIFont systemFontOfSize:18]];
    _energyAndKm.adjustsFontSizeToFitWidth = YES;
    _energyAndKm.textAlignment = NSTextAlignmentCenter;
    [_fitnessCircleView addSubview:_energyAndKm];
    [_energyAndKm mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.size.mas_equalTo(CGSizeMake(120, 70));
        maker.top.mas_equalTo(_allStep.mas_bottom).with.offset(-22);
        maker.centerX.mas_equalTo(_allStep.mas_centerX);
    }];
    
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fitnessAction:)];
    [[fitnessView viewWithTag:678] addGestureRecognizer:gesture];
    return fitnessView;
}


- (void) refreshProgressView
{
     _sportDatas = [FetchSportDataUtil fetchOneDaySportData:[NSDate date]];
    
    NSDictionary* dataDic = [self caculateData];
    int footData = 0;
    float footKm = 0;
    float footKcal = 0;
    if(dataDic)
    {
        footData = [[dataDic objectForKey:@"footData"] intValue];
        footKm = [[dataDic objectForKey:@"footKm"] floatValue];
        footKcal = [[dataDic objectForKey:@"footKcal"] floatValue];
    }
    
    float target = 0.0f;
    if(![[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey])
    {
        target = 10000;
    }
    else
    {
        target = [[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey];
    }
    float rate = (float)footData / target;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addProgressViewAnimation:rate];
        _allStep.text = [NSString stringWithFormat:@"%d", footData];
        _energyAndKm.text = [NSString stringWithFormat:@"%.0f%@  %.0f%@", footKm<1?footKm*1000:footKm,footKm<1?NSLocalizedString(@"米", nil):NSLocalizedString(@"千米", nil), footKcal,NSLocalizedString(@"千卡",nil)];
    });
}



- (void) addProgressViewAnimation:(float)rate
{
    if(_lineProgressView==nil)
    {
        _lineProgressView = [[LineProgressView alloc] initWithFrame:CGRectMake(0,0, _logoSize, _logoSize)];
        _lineProgressView.clipsToBounds = YES;
        _lineProgressView.layer.cornerRadius = _lineProgressView.frame.size.width / 2.0;
        _lineProgressView.backgroundColor = RGBColor(0xe1, 0x65, 0x28);
        _lineProgressView.delegate = self;
        _lineProgressView.total = 189;
        _lineProgressView.color = HexRGBAlpha(0xfdfdfd, 0.2);
        _lineProgressView.radius = 123;
        _lineProgressView.innerRadius = 104;
        //    lineProgressView.startAngle = M_PI * 0.72;
        //    lineProgressView.endAngle = M_PI * 2.28;
        
        _lineProgressView.startAngle = -M_PI_2;
        _lineProgressView.endAngle = M_PI*2 - M_PI_2;
        
        _lineProgressView.animationDuration = 1.0;
        _lineProgressView.layer.shouldRasterize = YES;
        [_fitnessCircleView addSubview:_lineProgressView];
    }
    
    if(rate == 0)
    {
        rate = 0;
    }
    else
    {
        rate += 0.02;
    }
    
    if(rate >= 1.0)
    {
        rate = 1.0;
    }

    [_lineProgressView setCompleted:rate*_lineProgressView.total animated:YES];
}



- (NSDictionary*) caculateData
{
    
    int allFootData = 0;
    float allFootKm = 0;
    float allFootKcal = 0;
    for(SportModel* model in _sportDatas)
    {
        allFootData += model.sportData;
    }
    
    allFootKm = ((float)allFootData*((float)[self personHeight]*0.45/100)/1000);
    
    float energy = allFootData * (([self personWeight] - 13.63636) * 0.000693 + 0.00495);
    if (energy < 0) {
        energy = -energy;
    }
    allFootKcal = energy;
    return @{@"footData":@(allFootData),@"footKm":@(allFootKm),@"footKcal":@(allFootKcal)};
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





- (UIView*)remotePhotoView
{
    UIView* remotePhotoView = [[UIView alloc] initWithFrame:CGRectMake(screen_width*2, -44, screen_width, screen_height+44)];
    remotePhotoView.backgroundColor = RGBColor(0x0d, 0x00, 0x56);
    
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width/2-_logoSize/2, (screen_height-_logoSize)/2, _logoSize, _logoSize)];
    iv.userInteractionEnabled = YES;
    iv.image = [UIImage imageNamed:@"img_camera"];
    [remotePhotoView addSubview:iv];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takephotoAction:)];
    [iv addGestureRecognizer:tapGesture];
    return remotePhotoView;
}

- (void)changePage
{
    CGSize viewSize = _scrollView.frame.size;
    CGRect rect = CGRectMake(_pageControl.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [_scrollView scrollRectToVisible:rect animated:YES];
}

#pragma  mark-UIScrollView Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger current = (offsetX + screen_width / 2)/screen_width;
    _pageControl.currentPage = current;
    if(current == 0)
    {
        [_bottomBtn setBackgroundImage:[UIImage imageNamed:_photoArr[0]] forState:UIControlStateNormal];
        _leftBtn.hidden = YES;
        ApplicationDelegate.isInFunctionVc = NO;
    }
    
    if(current == 1 )
    {
        [_bottomBtn setBackgroundImage:[UIImage imageNamed:_photoArr[1]] forState:UIControlStateNormal];
        _leftBtn.hidden = NO;
        ApplicationDelegate.isInFunctionVc = YES;
        [self refreshProgressView];
    }
    
    if(current == 2)
    {
        [_bottomBtn setBackgroundImage:[UIImage imageNamed:_photoArr[2]] forState:UIControlStateNormal];
        _leftBtn.hidden = YES;
        ApplicationDelegate.isInFunctionVc = NO;
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger current = (offsetX + screen_width / 2)/screen_width;
    _lastPage = current;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x / screen_width >= 0.5 && scrollView.contentOffset.x / screen_width <= 1.5) {
        if(_lastPage == _pageControl.currentPage) return;
        NSLog(@"请求运动数据");
        [[JGBLEManager sharedManager] fetchSportData];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}



#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int num = (int)indexPath.row;
    if(num == 3)
    {
        if([BLEAppContext shareBleAppContext].isConnected)
        {
            //断开连接
            //            [[NSNotificationCenter defaultCenter] postNotificationName:BLESelfDisconnectNotification object:nil];
            //            [[JGBLEManager sharedManager] cancelDeviceConnect];
             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"确定断开蓝牙连接吗？", nil) message:NSLocalizedString(@"断开连接后请前往设置手动删掉该蓝牙的配对信息", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
             [alertView show];
            return;
        }
        else
        {
            //手表配对
            BOOL BleStateOn = [ApplicationDelegate checkBleStateOn];
            if (BleStateOn)
            {
                PairedViewController* pariVc = [[PairedViewController alloc] init];
                [self.navigationController pushViewController:pariVc animated:YES];
            }
            return;
            
        }
    }
    
//    [tableView dismisWithIndexPath:indexPath];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
//    
//    
//    [self.blurView removeFromSuperview];
//    self.blurView = nil;
    
    switch (num)
    {
        case 0:
        {
            //个人信息
            PersonInfoSettingViewController* personVc = [[PersonInfoSettingViewController alloc] init];
            [self.navigationController pushViewController:personVc animated:YES];
            break;
        }
        case 1:
        {
            //智能闹钟
            ClockViewController* clockVc = [[ClockViewController alloc] init];
            clockVc.clockModelArray = ApplicationDelegate.clockModels;
            [self.navigationController pushViewController:clockVc animated:YES];
            break;
        }
        case 2:
        {
            //智能校时
            TimingViewController* autoVc = [[TimingViewController alloc] init];
            [self.navigationController pushViewController:autoVc animated:YES];
            break;
        }
            
        case 4:
        {
            //运动设置
            SportSleepSettingViewController* sportSettingVc = [[SportSleepSettingViewController alloc] init];
            [self.navigationController pushViewController:sportSettingVc animated:YES];
            break;
        }
        case 5:
        {
            //关于系统
            AboutSystemViewController* aboutVc = [[AboutSystemViewController alloc] init];
            [self.navigationController pushViewController:aboutVc animated:YES];
            break;
        }
        case 6:
        {
            //帮助
            HelpViewController* help = [HelpViewController new];
            [self.navigationController pushViewController:help animated:YES];
            
        }
        default:
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomMenuItem* cell = [CustomMenuItem customMenuItem:tableView];
    cell.menuTitle.text = [self.menuTitles objectAtIndex:indexPath.row];
    if(indexPath.row==3)
    {
        if([BLEAppContext shareBleAppContext].isConnected)
        {
            cell.menuTitle.text = NSLocalizedString(@"断开连接", nil);
        }
    }
    return cell;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[JGBLEManager sharedManager] cancelDeviceConnect];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
            [BLEAppContext shareBleAppContext].isSelfDisconnect = YES;
        });
    }
}


- (void) fitnessAction:(id)sender
{
//    if(!_fitVc)
//    {
//       _fitVc = [[FitnessViewController alloc] init];
//    }
//    _fitVc.sportDatas = _sportDatas;
//    [self.navigationController pushViewController:_fitVc animated:YES];
    FitnessViewController* fitvc = [FitnessViewController new];
    [self.navigationController pushViewController:fitvc animated:YES];
}

- (void) reminderAction:(id)sender
{
    PhoneRemindXLFormViewController* phoneVc = [[PhoneRemindXLFormViewController alloc] init];
    [self.navigationController pushViewController:phoneVc animated:YES];
}

- (void) takephotoAction:(id)sender
{
    JGBLEManager *manager = [JGBLEManager sharedManager];
    if(manager->_hasReadytoDownloadSportData)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"正在同步数据，请稍后", nil)];
        return;
    }
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setType:@"cameraIrisHollowOpen"];
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
//    SCNavigationController *nav = [[SCNavigationController alloc] init];
//    nav.scNaigationDelegate = self;
//    [nav showCameraWithParentController:self];
    TakePhotoViewController* takeVc = [TakePhotoViewController new];
    [self.navigationController presentViewController:takeVc animated:YES completion:nil];
}

@end
