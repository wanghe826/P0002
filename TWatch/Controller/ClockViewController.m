//
//  ClockViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/12.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//
#import "EditClockViewController.h"
#import "ClockViewController.h"
#import "BLEAppContext.h"
#import "Constants.h"
#import "AppUtils.h"
#import "SVProgressHUD.h"
@interface ClockViewController ()
{
    void (^_editClock)(ClockModel* model);
    void (^_addClock)(ClockModel* model);
    
    BOOL _clock0Status;
    BOOL _clock1Status;
    BOOL _clock2Status;
    
    int _recClockCount;         //  -1表示蓝牙断开，不发送；  1表示已经收到1个，2表示已经收到2个。。。。
    
    UITableView* _tableView;
}

@end

@implementation ClockViewController

- (void)viewDidLoad {
    _recClockCount = 0;
    [super viewDidLoad];
//    self.title = NSLocalizedString(@"智能闹钟", nil);
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height-124) style:UITableViewStylePlain];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = SeparatorColor;
    [self.view addSubview:_tableView];
    
    [self requestSyncClock];
}

- (void) requestSyncClock
{
    //请求闹钟数据
    if([BLEAppContext shareBleAppContext].isAuthorized){
        [SVProgressHUD showWithStatus:NSLocalizedString(@"正在获取闹钟设置...", @"") maskType:SVProgressHUDMaskTypeGradient];
    }
    
    [self requestClockData:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //10秒超时（10秒后都会dismiss）
        [SVProgressHUD dismiss];
    });
}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"智能闹钟", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshClockView:) name:@"RefreshClockData" object:nil];
    [self initData]; 
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void) requestClockData:(int)index{
    if(![BLEAppContext shareBleAppContext].isAuthorized){
        _recClockCount = -1;
        return;
    }
    Byte byte[7] = {'$', 0x04, 0x02, 0x09, 0x02};
    if(index==1){
        byte[5] = 0x01;
        byte[6] = 0x0c;
    }else if (index==2){
        byte[5] = 0x02;
        byte[6] = 0x0d;
    }else{
        byte[5] = 0x03;
        byte[6] = 0x0e;
    }
    NSData* data = [NSData dataWithBytes:byte length:7];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ApplicationDelegate.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
    });
}

- (void) refreshClockView:(NSNotification*)notification{
    if(!notification){
        return;
    }
    NSDictionary* dic = (NSDictionary*)notification.userInfo;
    ClockModel* model = (ClockModel*)[dic objectForKey:@"clock"];
    int index = [[dic objectForKey:@"index"] intValue];
    
    if(index==1){
        _recClockCount = 1;
        if(self.clockModelArray.count>=1){
            [self.clockModelArray replaceObjectAtIndex:0 withObject:model];
        }
        NSLog(@"请求第二个闹钟-----> ");
        [self requestClockData:2];
    }else if(index==2){
        _recClockCount = 2;
        if(self.clockModelArray.count>=2){
            [self.clockModelArray replaceObjectAtIndex:1 withObject:model];
        }
        [self requestClockData:3];
    }else if(index==3){
        _recClockCount = 3;
        if(self.clockModelArray.count>=3){
            [SVProgressHUD dismiss];
            [self.clockModelArray replaceObjectAtIndex:2 withObject:model];
        }
    }
    
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

-(void) returnBack
{
    [self back];
}


- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
    [self saveData];
//    NSData *data0 = nil, *data1 = nil, *data2 = nil;
//    if(self.clockModelArray.count>0){
//        data0 = [self assembleClockData:0];
//    }
//    if(self.clockModelArray.count>1){
//        data1 = [self assembleClockData:1];
//    }
//    if(self.clockModelArray.count>2){
//        data2 = [self assembleClockData:2];
//    }
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        if([BLEAppContext shareBleAppContext].isPaired){
//            if(data0){
//                [ApplicationDelegate logForData:data0 prefix:@"OUT"];
//                [ApplicationDelegate.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data0];
//            }
//            if(data1){
//                [ApplicationDelegate logForData:data1 prefix:@"OUT"];
//                [ApplicationDelegate.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data1];
//            }
//            if(data2){
//                [ApplicationDelegate logForData:data2 prefix:@"OUT"];
//                [ApplicationDelegate.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data2];
//            }
//        }
//    });
}

- (void)saveData
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.clockModelArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:ClockArrayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIView*) initialFootview
{
    UIView* addView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 60)];
    addView.backgroundColor = [UIColor blackColor];
    UIButton* addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addButton addTarget:self action:@selector(addClock:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(0, 0, 100, 100);
    addButton.center = CGPointMake(addView.center.x, addView.center.y-20);
    [addView addSubview:addButton];
    return addView;
}

- (void) addClock:(UIButton*)sender
{
    __weak __block id anyObject = self;
    __block UITableView* tableView = _tableView;
    _addClock = ^(ClockModel* model){
        if(!model)
        {
            return ;
        }
        [((ClockViewController*)anyObject).clockModelArray addObject:model];
        [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    };
    
    EditClockViewController* editClockVc = [[EditClockViewController alloc] init];
    editClockVc.addClock = _addClock;
    editClockVc.title = NSLocalizedString(@"添加闹钟", @"");
    UINavigationController* naviController = [[UINavigationController alloc] initWithRootViewController:editClockVc];
    [self presentViewController:naviController animated:YES completion:nil];
}

- (void) initData
{
    if(self.clockModelArray.count==0){
        //        self.clockModelArray = [[NSMutableArray alloc] init];
        NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:ClockArrayKey];
        if(data)
        {
            self.clockModelArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            for (int i=0; i<self.clockModelArray.count; ++i) {
                if(i==0){
                    _clock0Status = [[self.clockModelArray objectAtIndex:0].isClockOpen boolValue];
                }
                if(i==1){
                    _clock1Status = [[self.clockModelArray objectAtIndex:1].isClockOpen boolValue];
                }
                if(i==2){
                    _clock2Status = [[self.clockModelArray objectAtIndex:2].isClockOpen boolValue];
                }
            }
            
            return;
        }
        ClockModel* model1 = [[ClockModel alloc] init];
        model1.clockTime = @"08:00";
        model1.isClockOpen = @(NO);
        model1.isClockRepeat = @(NO);
        model1.clockDate = [[NSMutableString alloc] initWithCapacity:5];
        _clock0Status = NO;
        [self.clockModelArray addObject:model1];
        
        ClockModel* model2 = [[ClockModel alloc] init];
        model2.clockTime = @"08:00";
        model2.isClockOpen = @(NO);
        model2.isClockRepeat = @(NO);
        model2.clockDate = [[NSMutableString alloc] initWithCapacity:5];
        _clock1Status = NO;
        [self.clockModelArray addObject:model2];
        
        ClockModel* model3 = [[ClockModel alloc] init];
        model3.clockTime = @"08:00";
        model3.isClockOpen = @(NO);
        model3.isClockRepeat = @(NO);
        model3.clockDate = [[NSMutableString alloc] initWithCapacity:5];
        _clock2Status = NO;
        [self.clockModelArray addObject:model3];
    }else{
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClockModel* model = [self.clockModelArray objectAtIndex:indexPath.row];
    ClockViewCell* cell = [ClockViewCell createCustomTableViewCell:tableView];
    cell.timeLabel.text = model.clockTime;
    
    if(![model.isClockRepeat boolValue])
    {
        cell.repeatDateLabel.text = NSLocalizedString(@"单次", nil);
    }
    else
    {
        cell.repeatDateLabel.text = model.clockDate;
        
        if(model.clockDate.length >= 21)
        {
            cell.repeatDateLabel.text = NSLocalizedString(@"每天", nil);
        }
    }
    
    cell.clockSwitch.on = [model.isClockOpen boolValue];
    if(indexPath.row==0){
        [cell.clockSwitch addTarget:self action:@selector(firstAction:) forControlEvents:UIControlEventValueChanged];
    }else if (indexPath.row==1){
        [cell.clockSwitch addTarget:self action:@selector(secondAction:) forControlEvents:UIControlEventValueChanged];
    }else{
        [cell.clockSwitch addTarget:self action:@selector(thirdAction:) forControlEvents:UIControlEventValueChanged];
    }
    return cell;
}

- (void)firstAction:(id)sender{
    [self.clockModelArray objectAtIndex:0].isClockOpen = [NSNumber numberWithBool:((UISwitch*)sender).on];
    [self syncToWatch:0];
}
- (void)secondAction:(id)sender{
    [self.clockModelArray objectAtIndex:1].isClockOpen = [NSNumber numberWithBool:((UISwitch*)sender).on];
    [self syncToWatch:1];
}
- (void)thirdAction:(id)sender{
    [self.clockModelArray objectAtIndex:2].isClockOpen = [NSNumber numberWithBool:((UISwitch*)sender).on];
    [self syncToWatch:2];
}


//点击闹钟页面的按钮后发送至手表
- (void)syncToWatch:(int)index
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data0 = [self assembleClockData:index];
        if([BLEAppContext shareBleAppContext].isConnected){
            if(data0){
                [ApplicationDelegate logForData:data0 prefix:@"OUT"];
                [ApplicationDelegate.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data0];
            }
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.clockModelArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak __block id anyObject = self;
    __block UITableView* tv = _tableView;
    _editClock = ^(ClockModel* model){
        if (!model) {
            return ;
        }
        [((ClockViewController*)anyObject).clockModelArray replaceObjectAtIndex:indexPath.row withObject:model];
        [tv performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    };
    
    EditClockViewController* editClockVc = [[EditClockViewController alloc] init];
    editClockVc.clockIndex = (int)indexPath.row;
    editClockVc.editClock = _editClock;
    editClockVc.currentModel = [self.clockModelArray objectAtIndex:indexPath.row];
    editClockVc.title =  NSLocalizedString(@"编辑闹钟", nil);
//    UINavigationController* naviController = [[UINavigationController alloc] initWithRootViewController:editClockVc];
    [self.navigationController pushViewController:editClockVc animated:YES];
}

- (NSData*) assembleClockData:(int)index
{
    ClockModel* model = [self.clockModelArray objectAtIndex:index];
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
}



@end

@interface ClockViewCell()
@end

@implementation ClockViewCell


+(instancetype)createCustomTableViewCell:(UITableView*)tableView
{
    static NSString* const reuseIdentifier = @"reuseIdentifier";
    ClockViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ClockViewCell" owner:nil options:nil] lastObject];
        UISwitch* view = [[UISwitch alloc] init];
        view.frame = CGRectMake(0, 0, 20, 20);
        view.center = CGPointMake(screen_width-30,cell.timeLabel.center.y-20);
        cell.clockSwitch = view;
        [cell.clockSwitch addTarget:cell action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:cell.clockSwitch];
    }
    return cell;
}

- (void)switchAction:(id)sender {
    
    BOOL status = ((UISwitch*)sender).on;
    if(status){
        NSLog(@"---->");
    }else{
        NSLog(@"====>");
    }
}
@end
