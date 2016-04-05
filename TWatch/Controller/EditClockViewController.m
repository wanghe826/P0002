//
//  EditClockViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/13.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "EditClockViewController.h"
#import "XLFormViewController.h"
#import "ClockModel.h"
#import "AppUtils.h"
#import "SVProgressHUD.h"
#import "Constants.h"

@interface EditClockViewController ()
{
    NSArray* _tagArray;
    NSArray* _dateArray;
    ClockModel* _myModel;
    NSDateFormatter* _formatter;
    
    NSMutableArray<XLFormRowDescriptor*> * rowArray;        //一个星期的所有行
}


@end

@implementation EditClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = SeparatorColor;
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"HH:mm";        //HH表示24小时制，mm表示0~59，否则转换失败
    _myModel = [[ClockModel alloc] init];
    _myModel.clockDate = [[NSMutableString alloc] initWithCapacity:60];
    _dateArray = @[NSLocalizedString(@"周日 ", nil),NSLocalizedString(@"周一 ", nil),NSLocalizedString(@"周二 ", nil),NSLocalizedString(@"周三 ", nil),
                   NSLocalizedString(@"周四 ", nil),NSLocalizedString(@"周五 ", nil),NSLocalizedString(@"周六 ", nil)];
    _tagArray = @[@"mon",@"tus",@"wed",@"thu",@"fri",@"sta",@"sun"];
    
    UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, screen_height-45, screen_width, 45)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.layer.borderColor = [UIColor grayColor].CGColor;
    backBtn.frame = CGRectMake(0, screen_height-46, 60, 35);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    backBtn.center = view.center;
    [backBtn addTarget:self action:@selector(saveClock) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height-45, screen_width, 1)];
    separator.backgroundColor = SeparatorColor;
    [self.view addSubview:separator];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.currentModel)
    {
        _myModel = self.currentModel;
    }
    [self initialFormView];
    [self.tableView reloadData];
}

- (void)initialFormView
{
    XLFormDescriptor* form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor* timeSection = [XLFormSectionDescriptor formSection];
    [form addFormSection:timeSection];
    
    XLFormRowDescriptor* clockSwitch = [XLFormRowDescriptor formRowDescriptorWithTag:XLFORMROW_TAG_CLOCK_SWITCH rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"闹钟开关", nil)];
    if(self.currentModel)
    {
        BOOL status = [self.currentModel.isClockOpen boolValue];
//        [clockSwitch.cellConfig setObject:@(status) forKey:@"on"];
        clockSwitch.value = @(status);
    }
    [timeSection addFormRow:clockSwitch];
    XLFormRowDescriptor* clockTimeRow = [XLFormRowDescriptor formRowDescriptorWithTag:XLFORMROW_TAG_CLOCK_TIME rowType:XLFormRowDescriptorTypeTime title:NSLocalizedString(@"闹钟时间", @"")];
    if(self.currentModel)
    {
        
        clockTimeRow.value = [_formatter dateFromString:self.currentModel.clockTime];
    }
    [timeSection addFormRow:clockTimeRow];
    
    XLFormSectionDescriptor* repeatSection = [XLFormSectionDescriptor formSectionWithTitle:nil];
    [form addFormSection:repeatSection];
    
    XLFormRowDescriptor* clockRepeatRow = [XLFormRowDescriptor formRowDescriptorWithTag:XLFORMROW_TAG_ONCE rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"重复", @"")];
    if(self.currentModel)
    {
        BOOL status = [self.currentModel.isClockRepeat boolValue];
        clockRepeatRow.value = @(status);
    }
    [repeatSection addFormRow:clockRepeatRow];
    
    
    rowArray = [[NSMutableArray alloc] init];
    for(int i=0; i<7; ++i)
    {
        XLFormRowDescriptor* row = [XLFormRowDescriptor formRowDescriptorWithTag:[_tagArray objectAtIndex:i] rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString([_dateArray objectAtIndex:i], @"")];
        if([clockRepeatRow.value boolValue])
        {
            row.disabled = @(NO);
            [row.cellConfig setObject:[UIColor blackColor] forKey:@"textLabel.textColor"];
        }
        else
        {
            row.disabled = @(YES);
            [row.cellConfig setObject:[UIColor grayColor] forKey:@"textLabel.textColor"];
        }
        [repeatSection addFormRow:row];
        [rowArray addObject:row];
    }
    
    if(self.currentModel)
    {

        if([self.currentModel.clockDate rangeOfString:@"周日 "].length != 0)
        {
            [rowArray objectAtIndex:0].value = @(YES);
        }
        if([self.currentModel.clockDate rangeOfString:@"周一 "].length != 0)
        {
            [rowArray objectAtIndex:1].value = @(YES);
        }
        if([self.currentModel.clockDate rangeOfString:@"周二 "].length != 0)
        {
            [rowArray objectAtIndex:2].value = @(YES);
        }
        if([self.currentModel.clockDate rangeOfString:@"周三 "].length != 0)
        {
            [rowArray objectAtIndex:3].value = @(YES);
        }
        if([self.currentModel.clockDate rangeOfString:@"周四 "].length != 0)
        {
            [rowArray objectAtIndex:4].value = @(YES);
        }
        if([self.currentModel.clockDate rangeOfString:@"周五 "].length != 0)
        {
            [rowArray objectAtIndex:5].value = @(YES);
        }
        if([self.currentModel.clockDate rangeOfString:@"周六 "].length != 0)
        {
            [rowArray objectAtIndex:6].value = @(YES);
        }
    }
    
    self.form = form;
}

- (void) saveClock
{
    if([_myModel.isClockRepeat boolValue] && !_myModel.clockDate.length)
    {
        [SVProgressHUD showErrorWithStatus:@"请选择重复日期"];
        return;
    }
    
    if(![_myModel.isClockRepeat boolValue]){
        NSRange range = NSMakeRange(0, _myModel.clockDate.length);
        [_myModel.clockDate replaceCharactersInRange:range withString:@""];
    }
    
    if(_editClock!=nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _editClock(_myModel);
        });
    }
    if(_addClock!=nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _addClock(_myModel);
        });
    }
    
    NSMutableString* dateStr = [NSMutableString new];
    if([_myModel.clockDate rangeOfString:NSLocalizedString(@"周日 ", nil)].length!=0)
    {
        [dateStr appendString:NSLocalizedString(@"周日 ", nil)];
    }
    if([_myModel.clockDate rangeOfString:NSLocalizedString(@"周一 ", nil)].length!=0)
    {
        [dateStr appendString:NSLocalizedString(@"周一 ", nil)];
    }
    if([_myModel.clockDate rangeOfString:NSLocalizedString(@"周二 ", nil)].length!=0)
    {
        [dateStr appendString:NSLocalizedString(@"周二 ", nil)];
    }
    if([_myModel.clockDate rangeOfString:NSLocalizedString(@"周三 ", nil)].length!=0)
    {
        [dateStr appendString:NSLocalizedString(@"周三 ", nil)];
    }
    if([_myModel.clockDate rangeOfString:NSLocalizedString(@"周四 ", nil)].length!=0)
    {
        [dateStr appendString:NSLocalizedString(@"周四 ", nil)];
    }
    if([_myModel.clockDate rangeOfString:NSLocalizedString(@"周五 ", nil)].length!=0)
    {
        [dateStr appendString:NSLocalizedString(@"周五 ", nil)];
    }
    if([_myModel.clockDate rangeOfString:NSLocalizedString(@"周六 ", nil)].length!=0)
    {
        [dateStr appendString:NSLocalizedString(@"周六 ", nil)];
    }
    _myModel.clockDate = dateStr;
    
    [self syncAlarmToWatch];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)syncAlarmToWatch
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data0 = [self assembleClockData:self.clockIndex];
        if([BLEAppContext shareBleAppContext].isConnected){
            if(data0){
                [ApplicationDelegate logForData:data0 prefix:@"OUT"];
                [ApplicationDelegate.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data0];
            }
        }
    });
}

- (NSData*) assembleClockData:(int)index
{
    //    ClockModel* model = [self.clockModelArray objectAtIndex:index];
    ClockModel* model = _myModel;
    Byte clock1[12] = {'$', 0x09, 0x02, 0x09, 0x01};
    NSArray* array = [model.clockTime componentsSeparatedByString:@":"];
    int hour = [[array objectAtIndex:0] intValue];
    NSString* hourStr = [NSString stringWithFormat:@"%x", hour];
    //先以16为参数告诉strtoul字符串参数表示16进制数字，然后使用0x%X转为数字类型
    UInt16 hourHex = strtoul([hourStr UTF8String],0,16);
    clock1[5] = hourHex;
    //    strtoul如果传入的字符开头是“0x”,那么第三个参数是0，也是会转为十六进制的,这样写也可以：
    //    unsigned long red = strtoul([@"0x6587" UTF8String],0,0);
    
    int minute = [[array objectAtIndex:1] intValue];
    NSString* minuteStr = [NSString stringWithFormat:@"%x", minute];
    UInt16 minuteHex = strtoul([minuteStr UTF8String], 0, 16);
    clock1[6] = minuteHex;
    
    UInt16 dayHex = 0x00;
    NSArray* array2 = [model.clockDate componentsSeparatedByString:@" "];
    for(NSString* dayStr in array2){
        if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
        {
            if([dayStr isEqualToString:@"Mon"]){
                dayHex |= 0x40;
            }else if([dayStr isEqualToString:@"Tus"]){
                dayHex |= 0x20;
            }else if([dayStr isEqualToString:@"Wed"]){
                dayHex |= 0x10;
            }else if ([dayStr isEqualToString:@"Thu"]){
                dayHex |= 0x08;
            }else if([dayStr isEqualToString:@"Fri"]){
                dayHex |= 0x04;
            }else if([dayStr isEqualToString:@"Sat"]){
                dayHex |= 0x02;
            }else if([dayStr isEqualToString:@"Sun"]){
                dayHex |= 0x80;
            }
        }
        else
        {
            if([dayStr isEqualToString:@"周一"]){
                dayHex |= 0x40;
            }else if([dayStr isEqualToString:@"周二"]){
                dayHex |= 0x20;
            }else if([dayStr isEqualToString:@"周三"]){
                dayHex |= 0x10;
            }else if ([dayStr isEqualToString:@"周四"]){
                dayHex |= 0x08;
            }else if([dayStr isEqualToString:@"周五"]){
                dayHex |= 0x04;
            }else if([dayStr isEqualToString:@"周六"]){
                dayHex |= 0x02;
            }else if([dayStr isEqualToString:@"周日"]){
                dayHex |= 0x80;
            }
        }
        NSLog(@"--->--- %@", [AppUtils getCurrentLanguagesStr]);
        
    }
    clock1[7] = dayHex;
    if([model.isClockRepeat boolValue]){
        clock1[8] = 0x01;
    }else{
        clock1[8] = 0x00;
    }
    
    if(index == 0){
        clock1[9] = 0x01;
    }else if (index == 1){
        clock1[9] = 0x02;
    }else{
        clock1[9] = 0x03;
    }
    if([model.isClockOpen boolValue]){
        clock1[10] = 0x01;
    }else{
        clock1[10] = 0x00;
    }
    UInt16 checkSum = clock1[3] + clock1[4] + clock1[5] + clock1[6] + clock1[7] + clock1[8] + clock1[9] + clock1[10];
    clock1[11] = checkSum;
    NSData* data = [NSData dataWithBytes:clock1 length:12];
    return data;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue{
    if([formRow.tag isEqualToString:XLFORMROW_TAG_ONCE])
    {
        _myModel.isClockRepeat = [NSNumber numberWithBool:[newValue boolValue]];
        for(XLFormRowDescriptor* row in rowArray)
        {
            if([newValue boolValue])
            {
                row.disabled = @(NO);
                [row.cellConfig setObject:[UIColor blackColor] forKey:@"textLabel.textColor"];
            }
            else
            {
                row.disabled = @(YES);
                [row.cellConfig setObject:[UIColor grayColor] forKey:@"textLabel.textColor"];
            }
        }
        [self.tableView reloadData];
        return;
    }
    if([formRow.tag isEqualToString:XLFORMROW_TAG_CLOCK_SWITCH])
    {
        _myModel.isClockOpen = [NSNumber numberWithBool:[newValue boolValue]];
        return;
    }
    if([formRow.tag isEqualToString:XLFORMROW_TAG_CLOCK_TIME])
    {
        _myModel.clockTime = [_formatter stringFromDate:(NSDate*)newValue];
        return;
    }
    if([formRow.tag isEqualToString:[_tagArray objectAtIndex:0]])
    {
        //星期一
        NSRange range = [_myModel.clockDate rangeOfString:NSLocalizedString(@"周日 ", @"")];
        if([newValue boolValue])
        {
            //Monday、Tuesday、Wednesday、Thursday、Friday、Saturday、Sunday、
            //周一、周二、周三、周四、周五、周六、周日
            if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
            {
                range = NSMakeRange(0, 6);
            }
            else
            {
                range = NSMakeRange(0, 2);
            }
            [_myModel.clockDate appendString:NSLocalizedString(@"周日 ", @"")];
        }
        else
        {
            if(range.length != 0)
            {
                [_myModel.clockDate replaceCharactersInRange:range withString:@""];
            }
        }
        return;
    }
    if([formRow.tag isEqualToString:[_tagArray objectAtIndex:1]])
    {
        //星期二
        NSRange range = [_myModel.clockDate rangeOfString:NSLocalizedString(@"周一 ", @"")];
        if([newValue boolValue])
        {
            if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
            {
                range = NSMakeRange(7, 14);
            }
            else
            {
                range = NSMakeRange(3, 5);
            }
            [_myModel.clockDate appendString:NSLocalizedString(@"周一 ", @"")];
        }
        else
        {
            if(range.length != 0)
            {
                [_myModel.clockDate replaceCharactersInRange:range withString:@""];
            }
        }
        return;
    }
    if([formRow.tag isEqualToString:[_tagArray objectAtIndex:2]])
    {
        //星期三
        NSRange range = [_myModel.clockDate rangeOfString:NSLocalizedString(@"周二 ", @"")];
        if([newValue boolValue])
        {
            if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
            {
                range = NSMakeRange(15, 24);
            }
            else
            {
                range = NSMakeRange(6, 8);
            }
            [_myModel.clockDate appendString:NSLocalizedString(@"周二 ", @"")];
        }
        else
        {
            if(range.length != 0)
            {
                [_myModel.clockDate replaceCharactersInRange:range withString:@""];
            }
        }
        return;
    }
    if([formRow.tag isEqualToString:[_tagArray objectAtIndex:3]])
    {
        //星期四
        NSRange range = [_myModel.clockDate rangeOfString:NSLocalizedString(@"周三 ", @"")];
        if([newValue boolValue])
        {
            if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
            {
                range = NSMakeRange(25, 33);
            }
            else
            {
                range = NSMakeRange(9, 11);
            }
            [_myModel.clockDate appendString:NSLocalizedString(@"周三 ", @"")];
        }
        else
        {
            if(range.length != 0)
            {
                [_myModel.clockDate replaceCharactersInRange:range withString:@""];
            }
        }
        return;
    }
    if([formRow.tag isEqualToString:[_tagArray objectAtIndex:4]])
    {
        //星期五
        NSRange range = [_myModel.clockDate rangeOfString:NSLocalizedString(@"周四 ", @"")];
        if([newValue boolValue])
        {
            if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
            {
                range = NSMakeRange(34, 40);
            }
            else
            {
                range = NSMakeRange(12, 14);
            }
            [_myModel.clockDate appendString:NSLocalizedString(@"周四 ", @"")];
        }
        else
        {
            if(range.length != 0)
            {
                [_myModel.clockDate replaceCharactersInRange:range withString:@""];
            }
        }
        return;
    }
    if([formRow.tag isEqualToString:[_tagArray objectAtIndex:5]])
    {
        //星期六
        NSRange range = [_myModel.clockDate rangeOfString:NSLocalizedString(@"周五 ", @"")];
        if([newValue boolValue])
        {
            if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
            {
                range = NSMakeRange(41, 49);
            }
            else
            {
                range = NSMakeRange(15, 17);
            }
            [_myModel.clockDate appendString:NSLocalizedString(@"周五 ", @"")];
        }
        else
        {
            if(range.length != 0)
            {
                [_myModel.clockDate replaceCharactersInRange:range withString:@""];
            }
        }
        return;
    }
    if([formRow.tag isEqualToString:[_tagArray objectAtIndex:6]])
    {
        //星期日
        NSRange range = [_myModel.clockDate rangeOfString:NSLocalizedString(@"周六 ", @"")];
        if([newValue boolValue])
        {
            if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
            {
                range = NSMakeRange(50, 56);
            }
            else
            {
                range = NSMakeRange(18, 20);
            }
            [_myModel.clockDate appendString:NSLocalizedString(@"周六 ", @"")];
        }
        else
        {
            if(range.length != 0)
            {
                [_myModel.clockDate replaceCharactersInRange:range withString:@""];
            }
        }
        return;
    }
}


@end
