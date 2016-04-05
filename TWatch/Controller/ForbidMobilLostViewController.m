//
//  ForbidMobilLostViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/7/29.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "ForbidMobilLostViewController.h"
#import "UserDefaultsUtils.h"
#import "Masonry.h"
#import "AppUtils.h"
@interface ForbidMobilLostViewController (){
    NSTimer* _timer;
    BOOL _currentStatus;
}
@property (nonatomic, strong) UISwitch* forbidLostTag;
@property (nonatomic, strong) UIImageView* lostIv;
@end

@implementation ForbidMobilLostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentStatus = NO;
    
    self.title = NSLocalizedString(@"手机防丢", nil);
    [self initNavigationBarView];
    [self layoutSubviews];
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view from its nib.

}

- (void)sendSwitch{
    if(self.forbidLostTag.on != _currentStatus){
        [UserDefaultsUtils saveBoolValue:self.forbidLostTag.on withKey:ForbidMobileLostSwitch];
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEForbidMobileLostNotification object:nil];
        _currentStatus = self.forbidLostTag.on;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = RGBColor(53, 151, 243);
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendSwitch) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(_timer){
        if([_timer isValid]){
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView*)lostIv
{
    if(_lostIv == nil){
        NSString* str = @"lost_fangdiu_icon";
        if(self.forbidLostTag.on){
            str = @"lost_fangdiu_icon2";
        }
//        _lostIv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 30, 30)];
        _lostIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
//        _lostIv.image = [UIImage imageNamed:str];
    }
    return _lostIv;
}

- (void)layoutSubviews
{
    [self.view addSubview:self.lostIv];
    [self.lostIv mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.top.mas_equalTo(self.view.mas_top).with.offset(80);
        maker.left.mas_equalTo(self.view.mas_left).with.offset(20);
        maker.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    UILabel* label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"手机防丢", nil);
//    if ([[AppUtils getCurrentLanguagesStr]isEqualToString:@"en"])
//    {
//        label.font = [UIFont systemFontOfSize:10];
//    }
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.centerY.mas_equalTo(self.lostIv.mas_centerY);
        maker.left.mas_equalTo(self.lostIv.mas_left).with.offset(50);
        maker.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    [self.view addSubview:self.forbidLostTag];
    [self.forbidLostTag mas_makeConstraints:^(MASConstraintMaker* maker){
        maker.centerY.mas_equalTo(self.lostIv.mas_centerY);
        maker.right.mas_equalTo(self.view.mas_right).with.offset(-20);
        maker.size.mas_equalTo(CGSizeMake(50, 30));
    }];
}

- (void)initNavigationBarView
{
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:@"navagation_back_nor"] forState:UIControlStateNormal];
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    
   
    self.navigationController.navigationBarHidden = NO;
    //    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UISwitch*)forbidLostTag
{
    if(_forbidLostTag==nil){
        _forbidLostTag = [[UISwitch alloc] init]; //WithFrame:CGRectMake(270, 80, 50, 30)]
        _forbidLostTag.on = [[NSUserDefaults standardUserDefaults] boolForKey:ForbidMobileLostSwitch];
        [_forbidLostTag addTarget:self action:@selector(switchTag:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forbidLostTag;
}

- (void)switchTag:(UISwitch*)swi
{
    NSString* str = @"lost_fangdiu_icon";
    if(swi.on){
        str = @"lost_fangdiu_icon2";
    }
    self.lostIv.image = [UIImage imageNamed:str];
}

@end
