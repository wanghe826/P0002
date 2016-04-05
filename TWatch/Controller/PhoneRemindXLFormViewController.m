//
//  PhoneRemindXLFormViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/7/29.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "PhoneRemindXLFormViewController.h"
#import "XLForm.h"
#import "UserDefaultsUtils.h"
#import "SVProgressHUD.h"


@interface PhoneRemindXLFormViewController ()

@property(nonatomic,strong) XLFormSectionDescriptor* section;

@property(nonatomic,strong) XLFormRowDescriptor* notDisturbRow;
@property(nonatomic,strong) XLFormRowDescriptor* startTimeRow;
@property(nonatomic,strong) XLFormRowDescriptor* endTimeRow;

@property(nonatomic,strong) XLFormRowDescriptor* callRemindRow;
@property(nonatomic,strong) XLFormRowDescriptor* msgRemindRow;
@property(nonatomic,strong) XLFormRowDescriptor* fobidLostRow;

@property(nonatomic,strong) XLFormRowDescriptor* wechatRow;
@property(nonatomic,strong) XLFormRowDescriptor* weboRow;
@property(nonatomic,strong) XLFormRowDescriptor* qqRow;
@property(nonatomic,strong) XLFormRowDescriptor* momoRow;
@end


@implementation PhoneRemindXLFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBarView];
    [self initForm];
    
    UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, screen_height-35, screen_width, 35)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.layer.borderColor = [UIColor grayColor].CGColor;
    backBtn.frame = CGRectMake(0, screen_height-46, screen_width, 35);
//    [backBtn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    backBtn.center = view.center;
    [backBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void) returnBack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) notDisturbRow:(XLFormDescriptor*)xlform
{
    XLFormSectionDescriptor* disturbSec = [XLFormSectionDescriptor formSection];
    
    
    self.notDisturbRow = [XLFormRowDescriptor formRowDescriptorWithTag:NOTDISTURB rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedStringFromTable(@"勿扰模式", @"Localizable", nil)];
    
    if([UserDefaultsUtils boolValueWithKey:NotDisturbSwitch]){
        self.notDisturbRow.value = @(YES);
        [self.notDisturbRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_disturb_sel"] forKey:@"image"];
    }else{
        self.notDisturbRow.value = @(NO);
        [self.notDisturbRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_disturb_avr"] forKey:@"image"];
    }
    [disturbSec addFormRow:self.notDisturbRow];
    
//    
//    self.startTimeRow = [XLFormRowDescriptor formRowDescriptorWithTag:STARTTIME rowType:XLFormRowDescriptorTypeTime title:[NSString stringWithFormat:@"            %@",NSLocalizedString(@"开始时间", nil)]];
//    
//    if(![UserDefaultsUtils valueWithKey:StartTimeUserDefaultsKey]){
//        self.startTimeRow.value = [NSDate date];
//    }else{
//        self.startTimeRow.value = [UserDefaultsUtils valueWithKey:StartTimeUserDefaultsKey];
//    }
//    
//    self.startTimeRow.hidden = [NSString stringWithFormat:@"$%@.value == 0", self.notDisturbRow];
//    self.endTimeRow = [XLFormRowDescriptor formRowDescriptorWithTag:ENDTIME rowType:XLFormRowDescriptorTypeTime title:[NSString stringWithFormat:@"            %@",NSLocalizedString(@"结束时间", nil)]];
//    if(![UserDefaultsUtils valueWithKey:EndTimeUserDefaultsKey]){
//        self.endTimeRow.value = [NSDate date];
//    }else{
//        self.endTimeRow.value = [UserDefaultsUtils valueWithKey:EndTimeUserDefaultsKey];
//    }
//    
//    self.endTimeRow.hidden = [NSString stringWithFormat:@"$%@.value == 0", self.notDisturbRow];
//    if([UserDefaultsUtils boolValueWithKey:NotDisturbSwitch]){
//        [disturbSec addFormRow:self.startTimeRow];
//        [disturbSec addFormRow:self.endTimeRow];
//    }
    [xlform addFormSection:disturbSec];
}


- (void) addSocialReminder:(XLFormDescriptor*)xlform
{
    XLFormSectionDescriptor* section = [XLFormSectionDescriptor formSection];
    self.wechatRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"微信", nil)];
    [self.wechatRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_wechat_avr"] forKey:@"image"];
    BOOL wechat = [UserDefaultsUtils boolValueWithKey:WeixinRemindStatus];
    self.wechatRow.value = @(wechat);
    if(wechat)
    {
        [self.wechatRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_wechat_sel"] forKey:@"image"];
    }
    [section addFormRow:self.wechatRow];
    
    
    self.weboRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"微博", nil)];
    [self.weboRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_sina_avr"] forKey:@"image"];
    BOOL webo = [UserDefaultsUtils boolValueWithKey:SinaWeiboRemindStatus];
    self.weboRow.value = @(webo);
    if(webo)
    {
        [self.weboRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_sina_sel"] forKey:@"image"];
    }
    [section addFormRow:self.weboRow];
    
    self.qqRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"QQ", nil)];
    [self.qqRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_qq_avr"] forKey:@"image"];
    BOOL qq = [UserDefaultsUtils boolValueWithKey:QQRemindStatus];
    self.qqRow.value = @(qq);
    if(qq)
    {
        [self.qqRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_qq_sel"] forKey:@"image"];
    }
    [section addFormRow:self.qqRow];

    self.momoRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"陌陌", nil)];
    [self.momoRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_momo_avr"] forKey:@"image"];
    BOOL momo = [UserDefaultsUtils boolValueWithKey:LineRemindStatus];
    self.momoRow.value = @(momo);
    if(momo)
    {
        [self.momoRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_momo_sel"] forKey:@"image"];
    }
    [section addFormRow:self.momoRow];
    [xlform addFormSection:section];
}

- (void)initForm
{
    XLFormDescriptor* xlform = [XLFormDescriptor formDescriptorWithTitle:nil];
    self.section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    
    //勿扰模式
    [self notDisturbRow:xlform];
    
    self.callRemindRow = [XLFormRowDescriptor formRowDescriptorWithTag:CALLREMIND rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedStringFromTable(@"来电提醒", @"Localizable", nil)];
    
    if([UserDefaultsUtils boolValueWithKey:CallRemindSwitch]){
        self.callRemindRow.value = @"1";
        [self.callRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_phone_sel"] forKey:@"image"];
    }else{
        self.callRemindRow.value = @"0";
        [self.callRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_phone_avr"] forKey:@"image"];
    }
    [self.section addFormRow:self.callRemindRow];

    
    self.msgRemindRow = [XLFormRowDescriptor formRowDescriptorWithTag:MSGREMIND rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedStringFromTable(@"信息提醒", @"Localizable", nil)];
    
    if([UserDefaultsUtils boolValueWithKey:MsgRemindSwitch]){
        self.msgRemindRow.value = @"1";
        [self.msgRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_messege_sel"] forKey:@"image"];
    }else{
        self.msgRemindRow.value = @"0";
        [self.msgRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_messege_avr"] forKey:@"image"];
    }
    [self.section addFormRow:self.msgRemindRow];
    
    self.fobidLostRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedStringFromTable(@"断开提醒", @"Localizable", nil)];
    BOOL lostSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:ForbidMobileLostSwitch];
    self.fobidLostRow.value = @(lostSwitch);
    if(lostSwitch)
    {
        [self.fobidLostRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_lost_sel"] forKey:@"image"];
    }
    else
    {
        [self.fobidLostRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_lost_avr"] forKey:@"image"];
    }
    [self.section addFormRow:self.fobidLostRow];
    [xlform addFormSection:self.section];
    
    [self addSocialReminder:xlform];

    
    self.tableView.separatorColor = SeparatorColor;
    self.form = xlform;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
     self.navigationController.navigationBar.barTintColor = RGBColor(53, 151, 243);
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
}

- (void)initNavigationBarView
{
    self.title = NSLocalizedString(@"手机提醒", nil);
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    self.navigationController.navigationBarHidden = NO;
}
- (void)back
{
    [self commit];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)commit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLENotDisturbNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    NSString* rowTag = formRow.tag;
    if([rowTag isEqualToString:NOTDISTURB]){                        //勿扰模式
//        if([[newValue valueData] isEqualToNumber:@(0)]){
//            [UserDefaultsUtils saveBoolValue:NO withKey:NotDisturbSwitch];
//            [self.notDisturbRow.cellConfig setObject:[UIImage imageNamed:@"xianzhi_icon"] forKey:@"image"];
//        }else{
//            if(self.section.formRows.count <=3){
//                [self.section addFormRow:self.startTimeRow afterRow:self.notDisturbRow];
//                [self.section addFormRow:self.endTimeRow afterRow:self.startTimeRow];
//            }
//            [self.notDisturbRow.cellConfig setObject:[UIImage imageNamed:@"xianzhi_icon2"] forKey:@"image"];
//            [UserDefaultsUtils saveBoolValue:YES withKey:NotDisturbSwitch];
//        }
        if([newValue boolValue])
        {
            [self.notDisturbRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_disturb_sel"] forKey:@"image"];
        }
        else
        {
            [self.notDisturbRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_disturb_avr"] forKey:@"image"];
        }
        [UserDefaultsUtils saveBoolValue:[newValue boolValue] withKey:NotDisturbSwitch];
        [[NSNotificationCenter defaultCenter] postNotificationName:BLENotDisturbNotification object:nil];
    }else if([rowTag isEqualToString:CALLREMIND]){                  //来电提醒
        if([[newValue valueData] isEqualToNumber:@(0)]){
            [self.callRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_phone_avr"] forKey:@"image"];
            [UserDefaultsUtils saveBoolValue:NO withKey:CallRemindSwitch];
        }else{
            [self.callRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_phone_sel"] forKey:@"image"];
            [UserDefaultsUtils saveBoolValue:YES withKey:CallRemindSwitch];
        }
    }else if ([rowTag isEqualToString:MSGREMIND]){                  //短信提醒
        if([[newValue valueData] isEqualToNumber:@(0)]){
            [self.msgRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_messege_avr"] forKey:@"image"];
            [UserDefaultsUtils saveBoolValue:NO withKey:MsgRemindSwitch];
        }else{
            [self.msgRemindRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_messege_sel"] forKey:@"image"];
            [UserDefaultsUtils saveBoolValue:YES withKey:MsgRemindSwitch];
        }
    }
    else if(formRow == self.fobidLostRow){                          //防丢提醒
        if([newValue boolValue])
        {
            [self.fobidLostRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_lost_sel"] forKey:@"image"];
        }
        else
        {
            [self.fobidLostRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_lost_avr"] forKey:@"image"];
        }
        [UserDefaultsUtils saveBoolValue:[newValue boolValue] withKey:ForbidMobileLostSwitch];
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEForbidMobileLostNotification object:nil];
    }
    else if (formRow == self.wechatRow){                            //微信提醒
        if([newValue boolValue])
        {
            [self.wechatRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_wechat_sel"] forKey:@"image"];
        }
        else
        {
            [self.wechatRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_wechat_avr"] forKey:@"image"];
        }
        [UserDefaultsUtils saveBoolValue:[newValue boolValue] withKey:WeixinRemindStatus];
    }
    else if(formRow == self.weboRow){                               //微博提醒
        if([newValue boolValue])
        {
            [self.weboRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_sina_sel"] forKey:@"image"];
        }
        else
        {
            [self.weboRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_sina_avr"] forKey:@"image"];
        }
        [UserDefaultsUtils saveBoolValue:[newValue boolValue] withKey:SinaWeiboRemindStatus];
    }
    else if(formRow == self.qqRow){                                 //qq提醒
        if([newValue boolValue])
        {
            [self.qqRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_qq_sel"] forKey:@"image"];
        }
        else
        {
            [self.qqRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_qq_avr"] forKey:@"image"];
        }
        [UserDefaultsUtils saveBoolValue:[newValue boolValue] withKey:QQRemindStatus];
    }
    else if(formRow == self.momoRow){                               //陌陌提醒
        if([newValue boolValue])
        {
            [self.momoRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_momo_sel"] forKey:@"image"];
        }
        else
        {
            [self.momoRow.cellConfig setObject:[UIImage imageNamed:@"icon_reminder_momo_avr"] forKey:@"image"];
        }
        [UserDefaultsUtils saveBoolValue:[newValue boolValue] withKey:LineRemindStatus];
    }
//    else if([rowTag isEqualToString:STARTTIME]){
//        if([newValue isKindOfClass:[NSDate class]]){
//            [UserDefaultsUtils saveValue:newValue forKey:StartTimeUserDefaultsKey];
//            NSLog(@"设置的开始时间是:%@", newValue);
//        }
//    }else if([rowTag isEqualToString:ENDTIME]){
//        if([newValue isKindOfClass:[NSDate class]]){
//            [UserDefaultsUtils saveValue:newValue forKey:EndTimeUserDefaultsKey];
//            NSLog(@"设置的结束时间是:%@", newValue);
//        }
//    }
    [self.tableView reloadData];
}

/*
- (NSDate*)alreadSavedTime:(NSString*)withKey
{
    NSDate* date = [UserDefaultsUtils valueWithKey:withKey];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh";
    NSString* hourStr = [formatter stringFromDate:date];
    NSLog(@"小时:%@", hourStr);
    formatter.dateFormat = @"mm";
    NSString* minStr = [formatter stringFromDate:date];
    NSLog(@"分钟:%@", minStr);
    NSString* dateString = [NSString stringWithFormat:@"%@%@",hourStr,minStr];
    formatter.dateFormat = @"HH-MM";
    NSDate* retDate = [formatter dateFromString:dateString];
    return retDate;
}
 */
@end
