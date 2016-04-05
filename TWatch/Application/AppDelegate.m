//
//  AppDelegate.m
//  TWatch
//
//  Created by Bob on 15/6/6.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "UserDefaultsUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "JGBLEManager+Simple.h"

#import "Constants.h"
#import "Utilities.h"
#import "UserDefaultsUtils.h"
#import "Utilities.h"
#import <PgySDK/PgyManager.h>
#import "FirmwareUpgradeHomeViewController.h"
#import "SVProgressHUD.h"
#import "AppUtils.h"
#import "UMSocialData.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialSnsService.h"
#import "FirmwareFileDownloadUtils.h"

#import "CBUUID+ToString.h"
#import "SMDatabaseSingleton.h"

#import "FunctionViewController.h"
#import "MobClick.h"
#import "SplashViewController.h"

#import "SMPlaySound.h"

#define QiniuTWatchFirmwareFileJson @"http://7xl781.com1.z0.glb.clouddn.com/firmware.json"

static AVAudioPlayer* player = nil;
static BOOL _hasPlaySoundCompletion = YES;

#define TABLENAME   @"MHEvent"
#define KEY_ID      @"eventID"
#define KEY_TITLE   @"iTitle"
#define KEY_DATE    @"iDate"
#define KEY_CONTENT @"iContent"


#define BLEConnectedCBPeripheralKey     @"ConnectedCBPeripheral"

@interface AppDelegate () <AVAudioPlayerDelegate>
{
    UIScrollView* _splashView;
}

@property (nonatomic, readwrite) BOOL isBleStateOn;
@property (nonatomic, readwrite) BOOL isBLEDeviceConnected;

@property(retain, nonatomic)AVAudioPlayer* audioPlayer;

//@property (retain, nonatomic) JGBLEManager *bleMgr;

@end

@implementation AppDelegate



//日志重定向
- (void)redirectNSlogToDocumentFolder
{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *fileName = [NSString stringWithFormat:@"dr.log"];// 注意不是NSData!
//    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
//    // 先删除已经存在的文件
//    //    NSFileManager *defaultManager = [NSFileManager defaultManager];
//    //    [defaultManager removeItemAtPath:logFilePath error:nil];
//    
//    // 将log输入到文件
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.disConnCount = 0;
//    [self redirectNSlogToDocumentFolder];
    
    self.isInFunctionVc = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //蒲公英  famar     ---对应com.smartmovtw07-002
        //ab100fbda8750db9dc8f896b9fc079a2
//        [[PgyManager sharedPgyManager] startManagerWithAppId:@"ab100fbda8750db9dc8f896b9fc079a2"];//测试版本
        [[PgyManager sharedPgyManager] startManagerWithAppId:@"b0c7780d6cbefcfe71e22efdcf1677a5"];
        [PgyManager sharedPgyManager].shakingThreshold = 4.3;
        [PgyManager sharedPgyManager].enableFeedback = NO;
        
        
        [MobClick startWithAppkey:@"56603244e0f55a08cf001b8c" reportPolicy:BATCH channelId:@"Web"];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [MobClick setAppVersion:version];
        [UMSocialData setAppKey:@"56603244e0f55a08cf001b8c"];
        
        //设置微信AppId，设置分享url，默认使用友盟的网址
        [UMSocialWechatHandler setWXAppId:@"wx8381c0b4259ee03e" appSecret:@"2bff5861e93faf3fc05bf579c0b7ccb5" url:nil];
        //设置分享到QQ空间的应用Id，和分享url 链接
        [UMSocialQQHandler setQQWithAppId:@"1104928051" appKey:@"USpzF5YLfdt3ErME" url:@"http://www.fm-smart.com"];
        //新兰微博分享
        [UMSocialSinaHandler openSSOWithRedirectURL:nil];
        
    });
    [self initData];
    
    [BLEAppContext shareBleAppContext].isInSearchVC = NO;
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    [self gotoMainController];
    self.window.rootViewController = [self getViewControllerWithLogic];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return result;
}

- (void)initData
{
    self.bleMgr = [JGBLEManager sharedManager];
    self.bleMgr.delegate = self;
    
    self.isOldVersionFirmware = NO;
    self.clockModels = [[NSMutableArray alloc] initWithCapacity:3];
    self.isOnFirmwareUpgrade = NO;
    self.upgradeFileName = nil;
    self.upgradeChkFileName = nil;
    
    //保持屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        //初始化数据库
        SMDatabaseSingleton* smDatabase = [SMDatabaseSingleton shareInstance];
        [smDatabase createTable];
    });
    
    //播放无声的声音，保持后台常驻
//    [self playSound];
}

- (void)playSound
{
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dispatchQueue, ^(void) {
        NSError *audioSessionError = nil;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        if ([audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError]){
            
            NSLog(@"Successfully set the audio session.");
            
        } else {
            
            NSLog(@"Could not set the audio session");
            
        }
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        NSString *filePath = [mainBundle pathForResource:@"mySong" ofType:@"mp3"];
        
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
        
        if (self.audioPlayer != nil)
        {
            [self.audioPlayer setNumberOfLoops:-1];
            if ([self.audioPlayer prepareToPlay] && [self.audioPlayer play]){
                NSLog(@"Successfully started playing...");
            } else {
                NSLog(@"Failed to play.");
            }
            
        }
        
    });
}

- (void) alertNewFirmwareVersion
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"发现新固件,是否升级？", nil) message:_firmwareUpgradeLog delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定",nil), nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        FirmwareUpgradeHomeViewController* firmwareVc = [[FirmwareUpgradeHomeViewController alloc] init];
        //        [self.lordVc.navigationController pushViewController:firmwareVc animated:YES];
        [self.functionVc.navigationController presentViewController:firmwareVc animated:YES completion:nil];
    }
}


- (void) addAppShortcutItem
{
    UIApplicationShortcutItem* itemConnect = [[UIApplicationShortcutItem alloc] initWithType:@"connect" localizedTitle:@"开始连接"];
    UIApplicationShortcutItem* itemTakephoto = [[UIApplicationShortcutItem alloc] initWithType:@"takephoto" localizedTitle:@"遥控拍照"];
    UIApplicationShortcutItem* itemAppreminder = [[UIApplicationShortcutItem alloc] initWithType:@"reminder" localizedTitle:@"APP提醒"];
    NSMutableArray <UIApplicationShortcutItem*> *itemArray = [[NSMutableArray alloc] initWithCapacity:1];
    [itemArray addObject:itemConnect];
    [itemArray addObject:itemTakephoto];
    [itemArray addObject:itemAppreminder];
    [[UIApplication sharedApplication] setShortcutItems:itemArray];
}


- (void)gotoMainController
{
    if(_splashView){
        [_splashView removeFromSuperview];
    }
#pragma mark - init ble && register notification
    NSArray *notificationNames = @[BLEDiscoverCBPeripheralsNotification,BLEConnectNotification,BLEMCUSoundNotification,BLEChangePushSwitchStateNotification,BLEMCUTimeSyncNotification,BLEMCUWorldTimeSyncNotification,BLEMCUBeginWhenAdjustTimeNotification,BLEMCUAdjustTimeNotification,BLESelfDisconnectNotification,BLEMCUAlarmWhenDisconnect,BLEACKPedometerDataNotification,BLEForbidMobileLostNotification,BLENotDisturbNotification,BLEOnTakePhotoVCNotification,BLENotOnTakePhotoVCNotification,
                                   BLESportModeNotification,BLEMCUEndWhenAdjustTimeNotification,BLEStopScanDevice,BLELetYouKnowIamIOSNotification,BLEClearDataNotification];
    for (NSString *notificationName in notificationNames) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotification:) name:notificationName object:nil];
    }
    
    
#pragma mark - init window && set root view controller
    //    [self.window makeKeyAndVisible];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:kAlarmWhenDisconnect]){
        [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:YES] forKey:kAlarmWhenDisconnect];
    }
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    
}



//3d touch 菜单被按了之后会调用的系统回调
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    //When a user chooses one of your Home screen quick actions, the system launches or resumes your app and UIKit calls the application:performActionForShortcutItem:completionHandler: method in your app delegate
    NSString* itemType = shortcutItem.type;
    if([itemType isEqualToString:@"connect"])
    {
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"----d-d-d--");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter] postNotificationName:BLENotOnTakePhotoVCNotification object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIViewController*)getViewControllerWithLogic
{
    UINavigationController *navController = [[UINavigationController alloc]init];
    SplashViewController* splashVc = [[SplashViewController alloc] init];
    if(![UserDefaultsUtils boolValueWithKey:FirstTimeLogin])
    {
        [UserDefaultsUtils saveBoolValue:YES withKey:FirstTimeLogin];
        [navController setViewControllers:@[splashVc]];
        
        [[NSUserDefaults standardUserDefaults] setInteger:10000 forKey:FootTargetKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        FunctionViewController* funcVc = [[FunctionViewController alloc] init];
        [navController setViewControllers:@[funcVc]];
        self.functionVc = funcVc;
    }
    
//   [navController setViewControllers:@[splashVc]];
    
    
    return navController;
}

- (void)beginSimpleLife:(id)sender
{
    [self gotoMainController];
}

- (BOOL)checkBleStateOn {
    if (self.isBleStateOn) {
        return YES;
    }
    else {
        [self.window makeToast:NSLocalizedString(@"蓝牙未打开", nil)];
        return NO;
    }
}

- (BOOL)checkBleConnectedState {
    if (![BLEAppContext shareBleAppContext].isConnected) {
        [self.window makeToast:NSLocalizedString(@"蓝牙未连接", nil)];
        return NO;
    }
    return YES;
}

- (JGBleDeviceInfo *)getPreConnectedBleDevice {
    return [self.bleMgr preConnectedDevice];
}


#pragma mark - deal with notification

- (void)dealWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    //扫描BLE
    if ([notification.name isEqualToString:BLEDiscoverCBPeripheralsNotification]) {
        [self.bleMgr startScanWithTimeOut:10];
        return;
    }
    //连接BLE
    else if ([notification.name isEqualToString:BLEConnectNotification]) {
        JGBleDeviceInfo *info = userInfo[BLEConnectCBPeripheralKey];
        [self.bleMgr stopScan];
        [self.bleMgr connectDeviceByIdentifier:info.identifier timeout:10];
        return;
    }else if([notification.name isEqualToString:BLELetYouKnowIamIOSNotification]){
        Byte paired[6] = {'$', 0x03, 0x02, 0x0a, 0x01, 0x0b};
        NSData* data = [NSData dataWithBytes:paired length:6];
        //发送命令至BLE
        if (data && [BLEAppContext shareBleAppContext].isPaired) {
            [self logForData:data prefix:@"SHIT---"];
            //            [self.bleMgr writeToDeviceEventData:data];
            //0x02类型的命令
            [self.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
            return;
        }
        
    }
    else if ([notification.name isEqualToString:BLEStopScanDevice]){
        [self.bleMgr stopScan];
    }
    //手动断开连接
    else if ([notification.name isEqualToString:BLESelfDisconnectNotification])
    {
        [BLEAppContext shareBleAppContext].isSelfDisconnect = YES;
        [self.bleMgr disconnectConnectedDevice];
        return;
    }
    //设置电话，信息，邮件开关
    else if ([notification.name isEqualToString:BLEChangePushSwitchStateNotification]) {
        if ([BLEAppContext shareBleAppContext].isPaired) {
            //app 提醒
            NSData *data = [NSData BLEAppType];
            if (data) {
                //发送命令至BLE
                [self logForData:data prefix:@"OUT"];
                //            [self.bleMgr writeToDeviceEventData:data];
                
                //0x02类型的命令
                [self.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
                return;
            }
        }
    }
    else
    {
        NSData* data = nil;
        if ([notification.name isEqualToString:BLEMCUBeginWhenAdjustTimeNotification]) {      //w07进入指针模式
            //            data = [NSData BLEEventWithType:JGBLEToApp UInt8Param:MCUBeignAdjustTime];
            Byte bytes[6];
            bytes[0] = 0x24;
            bytes[1] = 0x03;
            bytes[2] = 0x02;
            bytes[3] = 0x05;
            bytes[4] = 0x01;
            bytes[5] = 0x06;
            data = [NSData dataWithBytes:bytes length:6];
        }else if([notification.name isEqualToString:BLEMCUEndWhenAdjustTimeNotification]){          //w07退出校针
            //            data = [NSData BLEEventWithType:JGBLEToApp UInt8Param:MCUEndAdjustTime];
            Byte bytes[6];
            bytes[0] = 0x24;
            bytes[1] = 0x03;
            bytes[2] = 0x02;
            bytes[3] = 0x05;
            bytes[4] = 0x02;
            bytes[5] = 0x07;
            data = [NSData dataWithBytes:bytes length:6];
        }
        else if ([notification.name isEqualToString:BLEMCUAdjustTimeNotification]) {
            NSArray *dataAry = @[userInfo[BLEHour],userInfo[BLEMinute],userInfo[BLESecond]];
            data = [NSData BLEAdjustTimeWithObj:dataAry];
        }
        else if ([notification.name isEqualToString:BLEMCUWorldTimeSyncNotification])
        {
            NSDate* date = userInfo[BLEMCUWorldTimeSyncNotificationDateKey];
            char timezone = [userInfo[BLEMCUWorldTimeSyncNotificationTimezoneKey] charValue];
            BOOL isDstOn = [userInfo[@"DST_IS_ON"] boolValue];
            NSString *city = userInfo[@"CITY"];
            data = [NSData BLEWorldTimeWithTime:date timezone:timezone isDstOn:isDstOn city:city];
        }
        else if ([notification.name isEqualToString:BLEMCUTimeSyncNotification])
        {
            NSDate* date = userInfo[BLEMCUTimeSyncNotificationDateKey];
            NSTimeZone* timezone = userInfo[BLEMCUTimeSyncNotificationTimezoneKey];
            data = [NSData BLETimeSyncEventWithTime:date timezone:timezone];
        }
        else if ([notification.name isEqualToString:BLEACKPedometerDataNotification])       //w07请求上传运动睡眠数据
        {
            data = [NSData BLEACKPedometerDataWithStatus:NO];
        }
        else if([notification.name isEqualToString:BLEForbidMobileLostNotification])
        {
            BOOL tag = [[NSUserDefaults standardUserDefaults] boolForKey:ForbidMobileLostSwitch];
            data = [NSData BLEACKForbidLostDataWithStatus:tag];
        }
        else if([notification.name isEqualToString:BLENotDisturbNotification])      //勿扰模式的设置
        {
            BOOL tag = [[NSUserDefaults standardUserDefaults] boolForKey:NotDisturbSwitch];
            NSDate* startDate = [UserDefaultsUtils valueWithKey:StartTimeUserDefaultsKey];
            NSDate* endDate = [UserDefaultsUtils valueWithKey:EndTimeUserDefaultsKey];
            if(startDate==nil){
                startDate = [NSDate date];
            }
            if(endDate==nil){
                endDate = [NSDate date];
            }
            
            //华唛更改
            //            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            //            formatter.dateFormat = @"hh-mm";
            //            startDate = [formatter dateFromString:@"00:01"];
            //            endDate = [formatter dateFromString:@"00:00"];
            //            NSLog(@"---->开始%@", startDate);
            //            NSLog(@"---->结束%@", endDate);
            
            data= [NSData BLENotiflyType:tag startTime:startDate endTime:endDate];
        }
        else if([notification.name isEqualToString:BLEOnTakePhotoVCNotification])    //在拍照页面
        {
            data = [NSData BLECameraType:YES];
        }
        else if([notification.name isEqualToString:BLENotOnTakePhotoVCNotification])    //不在拍照页面
        {
            data = [NSData BLECameraType:NO];
        }
        else if([notification.name isEqualToString:BLESportModeNotification]){          //w07运动开关
            BOOL status = [UserDefaultsUtils boolValueWithKey:SportsModeStatusKey];
            if(status){
                Byte byte[7] = {'$', 0x03, 0x02, 0x03, 0x07, 0x01, 0x0b};
                data = [NSData dataWithBytes:byte length:7];
            }else{
                Byte byte[7] = {'$', 0x03, 0x02, 0x03, 0x07, 0x02, 0x0c};
                data = [NSData dataWithBytes:byte length:7];
            }
            //            BOOL status2 = [UserDefaultsUtils boolValueWithKey:JiuzuoStatusKey];
            //            data = [NSData toChangeSomeType:status motor:YES type:status2];
        }
        else if ([notification.name isEqualToString:BLEClearDataNotification]){
            //            byte[] bytes = { 0x03, 0x0A, 0x0D };
            UInt8 bytes[3] = {0x03,0x0A,0x0D};
            //            this.toWriteByF1(bytes);
            data = [NSData dataWithBytes:bytes length:3];
        }
        //发送命令至BLE
        if (data && [BLEAppContext shareBleAppContext].isPaired) {
            [self logForData:data prefix:@"OUT"];
            //            [self.bleMgr writeToDeviceEventData:data];
            
            //0x02类型的命令
            [self.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
            
        }
    }
    
}




-(int)findNumFromStr:(NSString*)originalString
{
    
    if(originalString == nil){
        return 5;
    }
    
    // Intermediate
    NSMutableString *numberString = [[NSMutableString alloc] init];
    NSString *tempStr;
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
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

- (void)logForData:(NSData *)data prefix:(NSString *)prefix {
    unsigned char buf[32];
    char str[512];
    [data getBytes:buf];
    int off = 0;
    NSMutableString *logStr = [NSMutableString string];
    [logStr appendString:prefix];
    for (int i = 0; i < [data length]; i++) {
        off += sprintf(str+off, "%02X ", buf[i]);
        [logStr appendFormat:@" %02x",buf[i]];
    }
    NSLog(@"====== 命令开始 ======");
    NSLog(@"%@",logStr);
    NSLog(@"====== 命令结束 ======");
}



- (int)getHex:(int)ind
{
    return (int) (((ind / 10) * 16) + (ind % 10));
}

//将十进制转化为十六进制
- (NSString *)ToHex:(uint16_t)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}

-(void)reConn{
    [self.bleMgr connectDeviceByIdentifier:self.bleMgr.preConnectedDevice.identifier timeout:5];
}


#pragma mark - JGBLEManagerDelegate

- (void)JGBLEManager:(JGBLEManager*)manager didUpdateState:(CBCentralManagerState)state {
    self.isBleStateOn = (state == CBCentralManagerStatePoweredOn);
    if (self.isBleStateOn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEBleStateOnNotification object:nil userInfo:nil];
        if ([self.bleMgr isSystemConnectedBlesContain: [self.bleMgr preConnectedDevice].identifier]) {
            [self performSelector:@selector(reConn) withObject:self afterDelay:5];
        }
    }
    else {
        self.isBLEDeviceConnected = NO;
        [BLEAppContext shareBleAppContext].isConnected = NO;
        [BLEAppContext shareBleAppContext].isPaired = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shishishuaxin" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEDidFailConnectNotification object:nil];
    }
}

// 搜索到设备，每次都会返回当前搜索到的所有设备UUID
- (void)JGBLEManager:(JGBLEManager*)manager didDiscoverPeripherals:(JGBleDeviceInfo *)device {
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoveredDeviceNotification object:nil userInfo:@{BLEDeviceInfoKey:device}];
}

- (void)JGBLEManagerDidFinishScan {
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDidFinishScanNotification object:nil userInfo:nil];
}

// 连接设备相关
- (void)JGBLEManagerDidConnectPeripheral:(NSString *)uuid{
    [BLEAppContext shareBleAppContext].uuid = uuid;
    [[BLEAppContext shareBleAppContext] readSwitches:uuid];
    [BLEAppContext shareBleAppContext].isConnected = YES;
    [BLEAppContext shareBleAppContext].isSelfDisconnect = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDidConnectedNotification object:uuid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shishishuaxin" object:nil];
    
    NSLog(@"APP与手表连接---成功---！！！！");
}

- (void)JGBLEManagerDidFailConnectPeripheral{
    self.isBLEDeviceConnected = NO;
    [BLEAppContext shareBleAppContext].isPaired = NO;
    [BLEAppContext shareBleAppContext].uuid = nil;
    [BLEAppContext shareBleAppContext].isConnected = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDidFailConnectNotification object:nil];
}

- (void)JGBLEManager:(JGBLEManager*)manager didDisconnectPeripheralByUUID:(CBPeripheral*)peripheral error:(NSError*)error {
    //与手表断开连接 （比如： 手表手动关闭了蓝牙）
    
    ApplicationDelegate.upgradeChkFileName = nil;
    ApplicationDelegate.upgradeFileName = nil;
    ApplicationDelegate.deviceVer = nil;
    
    self.isBLEDeviceConnected = NO;
    [BLEAppContext shareBleAppContext].isAuthorized = NO;
    [BLEAppContext shareBleAppContext].isPaired = NO;
    [BLEAppContext shareBleAppContext].uuid = nil;
    [BLEAppContext shareBleAppContext].isConnected = NO;
    //断开连接后，启动搜索
    if([UserDefaultsUtils boolValueWithKey:ForbidMobileLostSwitch]){
        if([BLEAppContext shareBleAppContext].isSelfDisconnect == NO && ![BLEAppContext shareBleAppContext].isInSearchVC){
            [self performSelector:@selector(delayPlayCaf) withObject:nil afterDelay:15.0f];
        }
    }
    
    if([BLEAppContext shareBleAppContext].isInSearchVC != YES)
    {
        [self.bleMgr retrievePeriphralBySystem];               //保持app和手表的连接状态 与 系统和手表的连接状态同步
    }
    [self performSelector:@selector(delayShowConnectStatus) withObject:nil afterDelay:15.0f];
    
    NSLog(@"错误代码是:%@", error);
    NSLog(@"手表断开了蓝牙--------------------!!---------------");
    
    self.disConnCount++;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shishishuaxin" object:nil];
}



// 设备属性相关
- (void)JGBLEManager:(JGBLEManager*)manager
didRegistUpdateNotifyForDeviceUUID:(CBPeripheral*)peripheral
         serviceUUID:(CBUUID*)serviceUUID
  characteristicUUID:(CBUUID *)characteristicUUID
               error:(NSError*)error {
    
}


- (void) delayShowConnectStatus
{
    if([BLEAppContext shareBleAppContext].isConnected){
        return;
    }
}

- (void) delayPlayCaf
{
    if([BLEAppContext shareBleAppContext].isConnected){
        return;
    }
//    [self playCaf:@"findphone"];
    SMPlaySound* play = [[SMPlaySound alloc] init];
    [play playAlertSound];
    
}


- (void)JGBLEManager:(JGBLEManager*)manager
      didUpdateValue:(NSData*)value
       forDeviceUUID:(CBPeripheral*)peripheral
         serviceUUID:(CBUUID*)serviceUUID
  characteristicUUID:(CBUUID *)characteristicUUID
               error:(NSError*)error
       processResult:(BOOL*)result
  withCharacteristic:(CBCharacteristic *)characteristic
{
    *result = YES;
    if(value==nil){
        return;
    }
    
    //    //记录与蓝牙设备交互的数据--YES写 NO读
    //    [self theDataWithTheBle:value withType:NO];
    
    
    Byte* recValueByte = (Byte*)[value bytes];
    
    //闹钟声音
    if(value.length>=6 && recValueByte[0]==0x24 && recValueByte[1]==0x04 && recValueByte[2]==0x02 && recValueByte[3]==0x29){
//        [self customPlaySound];
        SMPlaySound* play = [[SMPlaySound alloc] init];
        [play playAlertSound];
    }
    
    
    //收到MCU反馈的数据包长度
    if(value.length>=6 && recValueByte[0]==0x24 && recValueByte[1]==0x05 && recValueByte[2]==0x02 && recValueByte[3]==0x16
       && recValueByte[4]==0x01)
    {
        
    }
    NSLog(@"收到MCU返回的数据--->");
    [self logForData:value prefix:@"FROM_MCU"];
    //收到闹钟设置成功的反馈
    if(value.length>5 && recValueByte[0]==0x24 && recValueByte[1]==0x04 && recValueByte[2]==0x02 && recValueByte[3]==0x19){
        int clockIndex = recValueByte[4];
        NSLog(@"闹钟设置成功---%d", clockIndex);
    }
    
    //    //App收到这条命令后主动断开蓝牙且不报警
    //    if(value.length==5 && recValueByte[0]==0x24 && recValueByte[1]==0x03 && recValueByte[2]==0x03
    //       && recValueByte[3]==0x20 && recValueByte[4]==0x23){
    //        [BLEAppContext shareBleAppContext].isSelfDisconnect = YES;
    //    }
    
    if(recValueByte[0]==0x24 && recValueByte[1]==0x03 && recValueByte[2]==0x02
       && recValueByte[3]==0x85 && recValueByte[4]==0x01)
    {
        NSLog(@"第一次收到sn码");
        NSLog(@"---> %@", value);
        Byte snByte[6] = {'$', 0x03, 0x02, 0x85, 0x12,0x97};
        [self.bleMgr writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:[NSData dataWithBytes:snByte length:6]];
    }
    
    if(recValueByte[0]==0x24 && recValueByte[1]==0x03 && recValueByte[2]==0x02
       && recValueByte[3]==0x85 && recValueByte[4]==0x02)
    {
        NSLog(@"第二次收到sn码");
        NSLog(@"---> %@", value);
    }
    
    //w07---------查找手机          24030213 0114
    Byte* byteArray = (Byte*)[value bytes];
    if(byteArray[0]==0x24 && byteArray[1]==0x03 && byteArray[2]==0x02 && byteArray[3]==0x13 && byteArray[4]==0x01 && byteArray[5]==0x14)
    {
        if(!self.isInCamera)
        {
//            [self playCaf:@"findphone"];
            SMPlaySound* play = [[SMPlaySound alloc] init];
            [play playAlertSound];
        }
    }
    
    //w07---------遥控拍照
    if(byteArray[0]==0x24 && byteArray[1]==0x03 && byteArray[2]==0x02 && byteArray[3]==0x13 && byteArray[4]==0x02 && byteArray[5]==0x15)
    {
        if (self.isInCamera)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhoto" object:nil];
        }
    }
}

- (void)JGBLEManager:(JGBLEManager*)manager
       didWriteValue:(NSData*)value
       forDeviceUUID:(CBPeripheral*)peripheral
         serviceUUID:(CBUUID*)serviceUUID
  characteristicUUID:(CBUUID *)characteristicUUID
               error:(NSError*)error {
    
}

- (void)JGBLEManager:(JGBLEManager*)manager
didFinishDiscoverServiceAndCharacteristicForDeviceUUID:(CBPeripheral*)peripheral
         withService:(CBService*)service
{
}


// 信号变化
- (void)JGBLEManager:(JGBLEManager*)manager
       didUpdateRSSI:(NSNumber*)RSSI
       forDeviceUUID:(CBPeripheral*)peripheral {
}

@end
