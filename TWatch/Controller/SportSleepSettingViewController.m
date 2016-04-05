//
//  SportSleepSettingViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/8/1.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//
#import "BLEAppContext.h"
#import "SportSleepSettingViewController.h"
#import "XLForm.h"
#import "UserDefaultsUtils.h"
#import "SVProgressHUD.h"
#import "AppUtils.h"
#import "Constants.h"
static NSString* const XLFormRowTypeClearButton = @"XLFormRowTypeClearButton";


@interface SportSleepSettingViewController ()

@property(nonatomic,strong) XLFormRowDescriptor* sportsMode;
@property(nonatomic,strong) XLFormRowDescriptor* footTarget;
@property(nonatomic,strong) XLFormRowDescriptor* sleepTarget;
@property(nonatomic,strong) XLFormRowDescriptor* jiuzuoSwitch;
@property(nonatomic,strong) XLFormRowDescriptor* jiuzuoBegin;
@property(nonatomic,strong) XLFormRowDescriptor* jiuzuoEnd;
@property(nonatomic,strong) XLFormRowDescriptor* jiuzuiHintTime;
@property(nonatomic,strong) XLFormRowDescriptor* clearSportData;
@end

@implementation SportSleepSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBarView];
    [self initialForm];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchLongSitDataFromWatch];
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
    [self.tableView reloadData];
}

- (XLFormRowDescriptor*)footTarget{
    if (_footTarget==nil) {
        NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:60];
        for(int i=500; i<=30000;i+=500){
            [array addObject:[NSString stringWithFormat:@"%d%@",i,NSLocalizedString(@"步每天", nil)]];
        }
        _footTarget = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeSelectorPickerView title:NSLocalizedString(@"步数目标", nil)];
        
        NSInteger target = 0;
        if(![[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey])
        {
            target = 10000;
        }
        else
        {
            target = [[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey];
        }
        _footTarget.value = [NSString stringWithFormat:@"%ld%@", (long)target, NSLocalizedString(@"步", nil)];
        [_footTarget.cellConfig setObject:[UIImage imageNamed:@"icon_sportset_target"] forKey:@"image"];
        
        _footTarget.selectorOptions = array;
    }
    return _footTarget;
}

-(XLFormRowDescriptor*)jiuzuoSwitch{
    if(_jiuzuoSwitch == nil){
        NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:60];
        for(int i=0; i<=120;i+=5){
            [array addObject:[NSString stringWithFormat:@"%d%@",i,NSLocalizedString(@"分钟", nil)]];
        }
        
        _jiuzuoSwitch = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeSelectorPickerView title:NSLocalizedString(@"久坐提醒", nil)];
        _jiuzuoSwitch.selectorOptions = array;
        
        NSString* text = @"0Min";
        if([UserDefaultsUtils valueWithKey:JiuzuoStatusKey])
        {
            text = [NSString stringWithFormat:@"%dMin", [[UserDefaultsUtils valueWithKey:JiuzuoStatusKey] intValue]];
        }
        
        _jiuzuoSwitch.value = text;
        if([_jiuzuoSwitch.value isEqualToString:@"0Min"])
        {
            [_jiuzuoSwitch.cellConfig setObject:[UIImage imageNamed:@"icon_sportset_sit_avr"] forKey:@"image"];
        }
        else
        {
            [_jiuzuoSwitch.cellConfig setObject:[UIImage imageNamed:@"icon_sportset_sit_sel"] forKey:@"image"];
        }
        
        
    }
    return _jiuzuoSwitch;
}


-(XLFormRowDescriptor*)clearSportData{
    if(_clearSportData != nil){
        return _clearSportData;
    }
    _clearSportData = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowTypeClearButton title:nil];
    return _clearSportData;
}

- (void)initialForm{
    self.tableView.separatorColor = SeparatorColor;
    
    XLFormDescriptor* form = [XLFormDescriptor formDescriptor];
    
    XLFormSectionDescriptor* sec2 = [XLFormSectionDescriptor formSection];
//    sec2.title = NSLocalizedString(@"运动设置", nil);
    [sec2 addFormRow:self.jiuzuoSwitch];
    [sec2 addFormRow:self.footTarget];
    [form addFormSection:sec2];

    XLFormSectionDescriptor* sec4 = [XLFormSectionDescriptor formSection];
//    sec4.title = NSLocalizedString(@"清除数据", nil);
    [sec4 addFormRow:self.clearSportData];
    [form addFormSection:sec4];
    
    self.form = form;
    
}

- (void)initNavigationBarView
{
    
    self.title = NSLocalizedString(@"运动设置", nil);
    self.tableView.separatorColor = SeparatorColor;
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
    
    UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, screen_height-45, screen_width, 45)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.layer.borderColor = [UIColor grayColor].CGColor;
    backBtn.frame = CGRectMake(0, screen_height-46, screen_width, 35);
//    [backBtn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    backBtn.center = view.center;
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height-45, screen_width, 1)];
    separator.backgroundColor = SeparatorColor;
    [self.view addSubview:separator];
    
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    if (formRow == self.footTarget)
    {  //步数目标
        NSString* foot = [(NSString*)newValue substringToIndex:[(NSString*)newValue length]-2];
        NSLog(@"--d-d-d-%@", foot);
        NSString *pureNumbers = [[newValue componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
        NSLog(@"--s-d纯数字%@", pureNumbers);
        [[NSUserDefaults standardUserDefaults] setInteger:[pureNumbers integerValue] forKey:FootTargetKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(formRow == self.jiuzuoSwitch)
    { //久坐开关
        if(![newValue isEqualToString:@"0分钟"])
        {
            [_jiuzuoSwitch.cellConfig setObject:[UIImage imageNamed:@"icon_sportset_sit_sel"] forKey:@"image"];
        }
        else
        {
            [_jiuzuoSwitch.cellConfig setObject:[UIImage imageNamed:@"icon_sportset_sit_avr"] forKey:@"image"];
        }

        [UserDefaultsUtils saveValue:[NSNumber numberWithInt:[(NSString*)newValue intValue]] forKey:JiuzuoStatusKey];
        [self.tableView reloadData];
        
        if([BLEAppContext shareBleAppContext].isAuthorized == YES)
        {
            [self writeLongSitDataToWatch];
        }
    }
}

- (void) fetchLongSitDataFromWatch
{
//    0x24,长度(1),0x02,0x0A,0x01,0x06,校验(1)
    if([BLEAppContext shareBleAppContext].isAuthorized != YES)
    {
        return;
    }
    
    Byte longSit[7] = {'$', 4, 0x02, 0x0a, 0x01, 0x06, 0x11};
    [[JGBLEManager sharedManager] writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:[NSData dataWithBytes:longSit length:7]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString* text = @"0分钟";
        if([UserDefaultsUtils valueWithKey:JiuzuoStatusKey])
        {
            text = [NSString stringWithFormat:@"%d分钟", [[UserDefaultsUtils valueWithKey:JiuzuoStatusKey] intValue]];
        }
        
        _jiuzuoSwitch.value = text;
        if([_jiuzuoSwitch.value isEqualToString:@"0分钟"])
        {
            [_jiuzuoSwitch.cellConfig setObject:[UIImage imageNamed:@"icon_sportset_sit_avr"] forKey:@"image"];
        }
        else
        {
            [_jiuzuoSwitch.cellConfig setObject:[UIImage imageNamed:@"icon_sportset_sit_sel"] forKey:@"image"];
        }
    });
}


- (void) writeLongSitDataToWatch
{
//    0x24,长度(1),0x02,0x0A,0x01,0x05,分钟数(1),校验(1)
    int time = [[UserDefaultsUtils valueWithKey:JiuzuoStatusKey] intValue];
    NSString* hexStr = [ApplicationDelegate ToHex:time];
    UInt16 minHex = strtoul([hexStr UTF8String], 0, 16);
    
    
    Byte longSit[8] = {'$', 5, 0x02, 0x0a, 0x01, 0x05, minHex};
    UInt16 checkSum = 0x0a + 0x01 + 0x05 + minHex ;
    longSit[7] = checkSum;
    [[JGBLEManager sharedManager] writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:[NSData dataWithBytes:longSit length:8]];
}


@end


@implementation CustomFormRowCell

+(void)load{
    //NSStringFromClass([CustomFormRowCell class])
    NSString * xibName;
    if ([[AppUtils getCurrentLanguagesStr]isEqualToString:@"en-CN"])
    {
        xibName = @"CustomClearXLFormRowEn";
    }else xibName = @"CustomClearXLFormRow";
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:xibName forKey:XLFormRowTypeClearButton];
}


-(void)configure{
    
     
    [super configure];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
}

-(void)update
{
    [super update];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"是否清除运动量数据", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    [alertView show];
}

- (IBAction)clearAction:(id)sender {
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否清除运动量数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        if([BLEAppContext shareBleAppContext].isConnected){
            [[NSNotificationCenter defaultCenter] postNotificationName:BLEClearDataNotification object:nil];
        }
        
        BOOL flag1 = [[SMDatabaseSingleton shareInstance] clearAllData];
        
        [UIView animateWithDuration:0.5f animations:^{
//            self.customImage.transform = CGAffineTransformMakeRotation(M_PI);
            self.customImage.layer.transform = CATransform3DMakeRotation(M_PI_4, 0.8, 0.8, 0.5);
        }completion:^(BOOL flag){
//            self.customImage.transform = CGAffineTransformIdentity;
            self.customImage.layer.transform = CATransform3DIdentity;
            if(flag1){
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"清除成功", nil)];
            }else{
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"清除成功", nil)];
            }
        }];
    }
}
@end
