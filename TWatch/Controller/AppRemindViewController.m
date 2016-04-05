//
//  AppRemidViewController.m
//  TWatch
//
//  Created by Bob on 15/6/6.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "AppRemindViewController.h"
#import "UserDefaultsUtils.h"
#import "SVProgressHUD.h"

#define POSITION_Y 45
#define LABLE_POSITION_Y 50
#define SWITCH_POSITION_Y 44

@interface AppRemindViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong) UISwitch *qqSwitch;

@property(nonatomic,strong) UISwitch *weixinSwitch;

@property(nonatomic,strong) UISwitch *weiboSwitch;

//新添加
@property(nonatomic,strong) UISwitch *skypeSwitch;

@property(nonatomic,strong) UISwitch *sinaWiboSwitch;

@property(nonatomic,strong) UISwitch *facebookSwitch;

@property(nonatomic,strong) UISwitch *twitterSwitch;

@property(nonatomic,strong) UISwitch *whatsappSwitch;

@property(nonatomic,strong) UISwitch *lineSwitch;

@property(nonatomic,strong) UISwitch *otherSwitch;

@property(nonatomic,strong) UISwitch *missedCallSwitch;
@property(nonatomic,strong) UISwitch *reservedSwitch;
@property(nonatomic,strong) UISwitch *calenderSwitch;





@property(nonatomic,strong) UILabel *qqLabel;

@property(nonatomic,strong) UILabel *weixinLabel;

@property(nonatomic,strong) UILabel *weiboLabel;

//新添加
@property(nonatomic,strong) UILabel *skypeLabel;
@property(nonatomic,strong) UILabel *sinaLabel;
@property(nonatomic,strong) UILabel *facebookLabel;
@property(nonatomic,strong) UILabel *twitterLabel;
@property(nonatomic,strong) UILabel *whatsappLabel;
@property(nonatomic,strong) UILabel *lineLabel;
@property(nonatomic,strong) UILabel *otherLabel;

/*
 w07新添加的
 
 12：未接来电1000
 13：日历事件2000
 14：Reserved
 */
@property(nonatomic,strong) UILabel *missedCall;
@property(nonatomic,strong) UILabel *calendalEvent;
@property(nonatomic,strong) UILabel *reserved;


//ImageView
@property(nonatomic,strong) UIImageView* qqImage;
@property(nonatomic,strong) UIImageView* micChatImage;
@property(nonatomic,strong) UIImageView* tencentWeiboImage;
@property(nonatomic,strong) UIImageView* skypeImage;
@property(nonatomic,strong) UIImageView* sinaWeiboImage;
@property(nonatomic,strong) UIImageView* facebookImage;
@property(nonatomic,strong) UIImageView* twitterImage;
@property(nonatomic,strong) UIImageView* whatsappImage;
@property(nonatomic,strong) UIImageView* lineImage;
@property(nonatomic,strong) UIImageView* otherImage;

@end

@implementation AppRemindViewController

-(UIImageView*)qqImage
{
    if(_qqImage == nil){
        NSString* str = @"app_qq_icon";
        if([UserDefaultsUtils boolValueWithKey:QQRemindStatus]){
            str = @"app_qq_icon2";
        }
        _qqImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _qqImage.frame = CGRectMake(15, POSITION_Y, 30, 30);
    }
    return _qqImage;
}

-(UIImageView*)micChatImage
{
    if(_micChatImage == nil){
        NSString* str = @"app_wechat_icon";
        if([UserDefaultsUtils boolValueWithKey:WeixinRemindStatus]){
            str = @"app_wechat_icon2";
        }
        _micChatImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _micChatImage.frame = CGRectMake(15, POSITION_Y+40, 30, 30);
    }
    return _micChatImage;
}
-(UIImageView*)tencentWeiboImage
{
    if(_tencentWeiboImage == nil){
        NSString* str = @"app_t_icon";
        if([UserDefaultsUtils boolValueWithKey:WeiboRemindStatus]){
            str = @"app_t_icon2";
        }
        _tencentWeiboImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _tencentWeiboImage.frame = CGRectMake(15, POSITION_Y+160, 30, 30);
        //t(15, 165, 30, 30)
    }
    return _tencentWeiboImage;
}
-(UIImageView*)skypeImage
{
    if(_skypeImage == nil){
        NSString* str = @"app_skype_icon";
        if([UserDefaultsUtils boolValueWithKey:SkypeRemindStatus]){
            str = @"app_skype_icon2";
        }
        _skypeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _skypeImage.frame = CGRectMake(15, POSITION_Y+80, 30, 30);
        //(15, 205, 30, 30)
    }
    return _skypeImage;
}

-(UIImageView*)sinaWeiboImage
{
    if(_sinaWeiboImage == nil){
        NSString* str = @"app_weibo_icon";
        if([UserDefaultsUtils boolValueWithKey:SinaWeiboRemindStatus]){
            str = @"app_weibo_icon2";
        }
        _sinaWeiboImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _sinaWeiboImage.frame = CGRectMake(15, POSITION_Y+120, 30, 30);
        //s(15, 245, 30, 30)
    }
    return _sinaWeiboImage;
}

-(UIImageView*)facebookImage
{
    if(_facebookImage == nil){
        NSString* str = @"app_facebook_icon";
        if([UserDefaultsUtils boolValueWithKey:FacebookRemindStatus]){
            str = @"app_facebook_icon2";
        }
        _facebookImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _facebookImage.frame = CGRectMake(15, POSITION_Y+200, 30, 30);
    }
    return _facebookImage;
}
-(UIImageView*)twitterImage
{
    if(_twitterImage == nil){
        NSString* str = @"app_twitter_icon";
        if([UserDefaultsUtils boolValueWithKey:TwitterRemindStatus]){
            str = @"app_twitter_icon2";
        }
        _twitterImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _twitterImage.frame = CGRectMake(15,POSITION_Y+240, 30, 30);
    }
    return _twitterImage;
}
-(UIImageView*)whatsappImage
{
    if(_whatsappImage == nil){
        NSString* str = @"app_whatsapp_icon";
        if([UserDefaultsUtils boolValueWithKey:WhatsappRemindStatus]){
            str = @"app_whatsapp_icon2";
        }
        _whatsappImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _whatsappImage.frame = CGRectMake(15, POSITION_Y+280, 30, 30);
    }
    return _whatsappImage;
}

-(UIImageView*)lineImage
{
    if(_lineImage == nil){
        NSString* str = @"app_line_icon";
        if([UserDefaultsUtils boolValueWithKey:LineRemindStatus]){
            str = @"app_line_icon2";
        }
        _lineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _lineImage.frame = CGRectMake(15, POSITION_Y+320, 30, 30);
    }
    return _lineImage;
}

-(UIImageView*)otherImage
{
    if(_otherImage == nil){
        NSString* str = @"app_other_icon";
        if([UserDefaultsUtils boolValueWithKey:OtherRemindStatus]){
            str = @"app_other_icon2";
        }
        _otherImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
        _otherImage.frame = CGRectMake(15, POSITION_Y+360, 30, 30);
    }
    return _otherImage;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = NSLocalizedString(@"APP提醒", nil);
    [self initNavigationBarView];
    [self layoutSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = RGBColor(53, 151, 243);
    BOOL flag;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:QQRemindStatus]) {
        flag = [UserDefaultsUtils boolValueWithKey:QQRemindStatus];
        _qqSwitch.on = flag;
    }else{
        _qqSwitch.on = NO;
        [self qqSwitchAction:_qqSwitch]; //默认关闭
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:WeixinRemindStatus]) {
        flag = [UserDefaultsUtils boolValueWithKey:WeixinRemindStatus];
        _weixinSwitch.on = flag;
    }else{
        _weixinSwitch.on = NO;
        [self weixinSwitchAction:_weixinSwitch]; //默认关闭
    }
    
    flag = [UserDefaultsUtils boolValueWithKey:WeiboRemindStatus];
    _weiboSwitch.on = flag;
    
    _skypeSwitch.on = [UserDefaultsUtils boolValueWithKey:SkypeRemindStatus];
    _sinaWiboSwitch.on = [UserDefaultsUtils boolValueWithKey:SinaWeiboRemindStatus];
    _facebookSwitch.on = [UserDefaultsUtils boolValueWithKey:FacebookRemindStatus];
    _twitterSwitch.on = [UserDefaultsUtils boolValueWithKey:TwitterRemindStatus];
    _whatsappSwitch.on = [UserDefaultsUtils boolValueWithKey:WhatsappRemindStatus];
    _lineSwitch.on = [UserDefaultsUtils boolValueWithKey:LineRemindStatus];
    _otherSwitch.on = [UserDefaultsUtils boolValueWithKey:OtherRemindStatus];
    _reservedSwitch.on = [UserDefaultsUtils boolValueWithKey:ReservedStatus];
    _missedCallSwitch.on = [UserDefaultsUtils boolValueWithKey:MissedCallStatus];
    _calenderSwitch.on = [UserDefaultsUtils boolValueWithKey:CalenderStatus];
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
}

- (void)commit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil];
}

- (void)back
{
    [self commit];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UISwitch *)qqSwitch
{
    if (_qqSwitch == nil) {
        _qqSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y, 220, 20)];
        _qqSwitch.tag = 6;
        [_qqSwitch setOn:YES];
        [_qqSwitch addTarget:self action:@selector(qqSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qqSwitch;
}

- (UISwitch *)weixinSwitch
{
    if (_weixinSwitch == nil)
    {
        _weixinSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+40, 220, 20)];
        _weixinSwitch.tag = 3;
        [_weixinSwitch setOn:YES];
        [_weixinSwitch addTarget:self action:@selector(weixinSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weixinSwitch;
}

- (UISwitch *)weiboSwitch
{
    if (_weiboSwitch == nil) {
        _weiboSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+160, 220, 20)];
        //(screen_width - 70, 164, 220, 20)
        _weiboSwitch.tag = 4;
        [_weiboSwitch setOn:YES];
        [_weiboSwitch addTarget:self action:@selector(weiboSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weiboSwitch;
}

- (UISwitch*)skypeSwitch
{
    if (_skypeSwitch == nil) {
        _skypeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+80, 220, 20)];
        //(screen_width - 70, 204, 220, 20)
        _skypeSwitch.tag = 2;
        _skypeSwitch.on = YES;
        [_skypeSwitch addTarget:self action:@selector(skypeSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skypeSwitch;
}

- (UISwitch*)sinaWiboSwitch
{
    if (_sinaWiboSwitch == nil) {
        _sinaWiboSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+120, 220, 20)];
        //(screen_width - 70, 244, 220, 20)
        _sinaWiboSwitch.tag = 1;
        _sinaWiboSwitch.on = YES;
        [_sinaWiboSwitch addTarget:self action:@selector(sinaWeiboSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sinaWiboSwitch;
}

- (UISwitch*)facebookSwitch
{
    if(_facebookSwitch == nil){
        _facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+200, 220, 20)];
        _facebookSwitch.on = YES;
        [_facebookSwitch addTarget:self action:@selector(facebookSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _facebookSwitch;
}

- (UISwitch*)twitterSwitch
{
    if(_twitterSwitch == nil){
        _twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+240, 220, 20)];
        _twitterSwitch.on = YES;
        [_twitterSwitch addTarget:self action:@selector(twitterSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _twitterSwitch;
}

- (UISwitch*)whatsappSwitch
{
    if(_whatsappSwitch == nil){
        _whatsappSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+280, 220, 20)];
        _whatsappSwitch.on = YES;
        [_whatsappSwitch addTarget:self action:@selector(whatsappSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _whatsappSwitch;
}

- (UISwitch*)lineSwitch
{
    if(_lineSwitch == nil){
        _lineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+320, 220, 20)];
        _lineSwitch.on = YES;
        [_lineSwitch addTarget:self action:@selector(lineSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lineSwitch;
}

- (UISwitch*)otherSwitch
{
    if(_otherSwitch == nil){
        _otherSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+360, 220, 20)];
        _otherSwitch.on = YES;
        [_otherSwitch addTarget:self action:@selector(otherSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherSwitch;
}

- (UISwitch*)missedCallSwitch
{
    if(_missedCallSwitch == nil){
        _missedCallSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+400, 220, 20)];
        _missedCallSwitch.on = YES;
        [_missedCallSwitch addTarget:self action:@selector(misseedCallSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _missedCallSwitch;
}

- (UISwitch*)reservedSwitch
{
    if(_reservedSwitch == nil){
        _reservedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+440, 220, 20)];
        _reservedSwitch.on = YES;
        [_reservedSwitch addTarget:self action:@selector(reservedSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reservedSwitch;
}

- (UISwitch*)calenderSwitch
{
    if(_calenderSwitch == nil){
        _calenderSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screen_width - 70, SWITCH_POSITION_Y+480, 220, 20)];
        _calenderSwitch.on = YES;
        [_calenderSwitch addTarget:self action:@selector(calenderSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _calenderSwitch;
}



/////////////-------->label
- (UILabel *)qqLabel
{
    if (_qqLabel == nil) {
        _qqLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y, 120, 20)];
        _qqLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _qqLabel.textColor = [UIColor whiteColor];
        _qqLabel.textAlignment = NSTextAlignmentLeft;
        _qqLabel.text = NSLocalizedString(@"QQ", nil);
    }
    return _qqLabel;
}

- (UILabel *)weixinLabel
{
    if (_weixinLabel == nil) {
        _weixinLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+40, 120, 20)];
        _weixinLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _weixinLabel.textColor = [UIColor whiteColor];
        _weixinLabel.textAlignment = NSTextAlignmentLeft;
        _weixinLabel.text = NSLocalizedString(@"微信", nil);
    }
    return _weixinLabel;
}

- (UILabel *)weiboLabel
{
    if (_weiboLabel == nil) {
        _weiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+160, 120, 20)];
        //(60, 170, 120, 20)
        _weiboLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _weiboLabel.textColor = [UIColor whiteColor];
        _weiboLabel.textAlignment = NSTextAlignmentLeft;
        _weiboLabel.text = NSLocalizedString(@"腾讯微博", nil);
    }
    return _weiboLabel;
}

- (UILabel*)skypeLabel
{
    if (_skypeLabel == nil) {
        _skypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+80, 120, 20)];
        //(60, 210, 120, 20)
        _skypeLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _skypeLabel.textColor = [UIColor whiteColor];
        _skypeLabel.textAlignment = NSTextAlignmentLeft;
        _skypeLabel.text = NSLocalizedString(@"Skype", nil);
    }
    return _skypeLabel;
}

- (UILabel*)sinaLabel
{
    if (_sinaLabel == nil) {
        _sinaLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+120, 120, 20)];
        //(60, 250, 120, 20)
        _sinaLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _sinaLabel.textColor = [UIColor whiteColor];
        _sinaLabel.textAlignment = NSTextAlignmentLeft;
        _sinaLabel.text = NSLocalizedString(@"新浪微博", nil);
    }
    return _sinaLabel;
}

- (UILabel*)facebookLabel
{
    if (_facebookLabel == nil) {
        _facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+200, 120, 20)];
        _facebookLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _facebookLabel.textColor = [UIColor whiteColor];
        _facebookLabel.textAlignment = NSTextAlignmentLeft;
        _facebookLabel.text = NSLocalizedString(@"Facebook", nil);
    }
    return _facebookLabel;
}

- (UILabel*)twitterLabel
{
    if (_twitterLabel == nil) {
        _twitterLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+240, 120, 20)];
        _twitterLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _twitterLabel.textColor = [UIColor whiteColor];
        _twitterLabel.textAlignment = NSTextAlignmentLeft;
        _twitterLabel.text = NSLocalizedString(@"Twitter", nil);
    }
    return _twitterLabel;
}

- (UILabel*)whatsappLabel
{
    if (_whatsappLabel == nil) {
        _whatsappLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+280, 120, 20)];
        _whatsappLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _whatsappLabel.textColor = [UIColor whiteColor];
        _whatsappLabel.textAlignment = NSTextAlignmentLeft;
        _whatsappLabel.text = NSLocalizedString(@"Whatsapp", nil);
    }
    return _whatsappLabel;
}

- (UILabel*)lineLabel
{
    if (_lineLabel == nil) {
        _lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+320, 120, 20)];
        _lineLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _lineLabel.textColor = [UIColor whiteColor];
        _lineLabel.textAlignment = NSTextAlignmentLeft;
        _lineLabel.text = NSLocalizedString(@"Line", nil);
    }
    return _lineLabel;
}

- (UILabel*)otherLabel
{
    if (_otherLabel == nil) {
        _otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+360, 120, 20)];
        _otherLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _otherLabel.textColor = [UIColor whiteColor];
        _otherLabel.textAlignment = NSTextAlignmentLeft;
        _otherLabel.text = NSLocalizedString(@"其它", nil);
    }
    return _otherLabel;
}

- (UILabel*)missedCall
{
    if (_missedCall == nil) {
        _missedCall = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+400, 120, 20)];
        _missedCall.font = [UIFont boldSystemFontOfSize:15.0];
        _missedCall.textColor = [UIColor whiteColor];
        _missedCall.textAlignment = NSTextAlignmentLeft;
        _missedCall.text = NSLocalizedString(@"未接来电", nil);
    }
    return _missedCall;
}

- (UILabel*)reserved
{
    if (_reserved == nil) {
        _reserved = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+440, 120, 20)];
        _reserved.font = [UIFont boldSystemFontOfSize:15.0];
        _reserved.textColor = [UIColor whiteColor];
        _reserved.textAlignment = NSTextAlignmentLeft;
        _reserved.text = NSLocalizedString(@"Reserved", nil);
    }
    return _reserved;
}

- (UILabel*)calendalEvent
{
    if (_calendalEvent == nil) {
        _calendalEvent = [[UILabel alloc] initWithFrame:CGRectMake(60, LABLE_POSITION_Y+480, 120, 20)];
        _calendalEvent.font = [UIFont boldSystemFontOfSize:15.0];
        _calendalEvent.textColor = [UIColor whiteColor];
        _calendalEvent.textAlignment = NSTextAlignmentLeft;
        _calendalEvent.text = NSLocalizedString(@"日历事件", nil);
    }
    return _calendalEvent;
}

- (void)layoutSubView
{
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, screen_width, screen_height)];
    scrollView.contentSize = CGSizeMake(screen_width, screen_height+50);
    scrollView.scrollEnabled = YES;
    scrollView.bounces = YES;
    [self.view addSubview:scrollView];
    [scrollView addSubview:self.qqImage];
    [scrollView addSubview:self.qqLabel];
    [scrollView addSubview:self.qqSwitch];
    
    [scrollView addSubview:self.micChatImage];
    [scrollView addSubview:self.weixinLabel];
    [scrollView addSubview:self.weixinSwitch];
    
    [scrollView addSubview:self.tencentWeiboImage];
    [scrollView addSubview:self.weiboLabel];
    [scrollView addSubview:self.weiboSwitch];
    
    [scrollView addSubview:self.skypeImage];
    [scrollView addSubview:self.skypeSwitch];
    [scrollView addSubview:self.skypeLabel];
    
    [scrollView addSubview:self.sinaWeiboImage];
    [scrollView addSubview:self.sinaWiboSwitch];
    [scrollView addSubview:self.sinaLabel];
    
    [scrollView addSubview:self.facebookImage];
    [scrollView addSubview:self.facebookSwitch];
    [scrollView addSubview:self.facebookLabel];
    
    [scrollView addSubview:self.twitterImage];
    [scrollView addSubview:self.twitterSwitch];
    [scrollView addSubview:self.twitterLabel];
    
    [scrollView addSubview:self.whatsappImage];
    [scrollView addSubview:self.whatsappSwitch];
    [scrollView addSubview:self.whatsappLabel];
    
    [scrollView addSubview:self.lineImage];
    [scrollView addSubview:self.lineSwitch];
    [scrollView addSubview:self.lineLabel];
    
    [scrollView addSubview:self.otherImage];
    [scrollView addSubview:self.otherSwitch];
    [scrollView addSubview:self.otherLabel];
    
//    [scrollView addSubview:self.missedCall];
//    [scrollView addSubview:self.missedCallSwitch];
//    
//    [scrollView addSubview:self.reserved];
//    [scrollView addSubview:self.reservedSwitch];
//    
//    [scrollView addSubview:self.calendalEvent];
//    [scrollView addSubview:self.calenderSwitch];
}

- (void)qqSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:QQRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_qq_icon";
        if(sender.on){
            str = @"app_qq_icon2";
        }
        NSLog(@"---->%@", str);
        self.qqImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)weixinSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:WeixinRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_wechat_icon";
        if(sender.on){
            str = @"app_wechat_icon2";
        }
        
        self.micChatImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)weiboSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:WeiboRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_t_icon";
        if(sender.on){
            str = @"app_t_icon2";
        }
        
        self.tencentWeiboImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

//新添加
- (void)skypeSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:SkypeRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_skype_icon";
        if(sender.on){
            str = @"app_skype_icon2";
        }
        
        self.skypeImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)sinaWeiboSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:SinaWeiboRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_weibo_icon";
        if(sender.on){
            str = @"app_weibo_icon2";
        }
        
        self.sinaWeiboImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)facebookSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:FacebookRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_facebook_icon";
        if(sender.on){
            str = @"app_facebook_icon2";
        }
        self.facebookImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)twitterSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:TwitterRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_twitter_icon";
        if(sender.on){
            str = @"app_twitter_icon2";
        }
        self.twitterImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)whatsappSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:WhatsappRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_whatsapp_icon";
        if(sender.on){
            str = @"app_whatsapp_icon2";
        }
        self.whatsappImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)lineSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:LineRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_line_icon";
        if(sender.on){
            str = @"app_line_icon2";
        }
        self.lineImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil userInfo:@{BLESwitchStateKey: [NSNumber numberWithUnsignedShort:switches]}];
//    }
}

- (void)otherSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:OtherRemindStatus];
//    if ([BLEAppContext shareBleAppContext].isPaired) {
        NSString* str = @"app_other_icon";
        if(sender.on){
            str = @"app_other_icon2";
        }
        self.otherImage.image = [UIImage imageNamed:str];
        NSInteger index = ((UIButton *)sender).tag;
        UInt16 switches = [BLEAppContext shareBleAppContext].switches;
        switches ^= (1 << index);
        [BLEAppContext shareBleAppContext].switches = switches;
}


- (void)misseedCallSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:MissedCallStatus];
}

- (void)reservedSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:ReservedStatus];
}

- (void)calenderSwitchAction:(UISwitch*)sender
{
    [UserDefaultsUtils saveBoolValue:sender.on withKey:CalenderStatus];
}

@end
