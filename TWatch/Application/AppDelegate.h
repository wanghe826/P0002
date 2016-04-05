//
//  AppDelegate.h
//  TWatch
//
//  Created by Bob on 15/6/6.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEAppContext.h"
#import <CoreData/CoreData.h>
#import "FMDatabase.h"
#import "FMDB.h"
#import "JGBLEManager.h"

#define FirstTimeLogin @"FirstTime"

@class ClockModel;
@class JGBleDeviceInfo;
@class FunctionViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIScrollViewDelegate,JGBLEManagerDelegate>
{
    @public
    NSString* _firmwareUpgradeLog;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isInCamera;
@property (assign, nonatomic) BOOL isOnFirmwareUpgrade;
@property (nonatomic,strong) NSMutableArray <ClockModel*>* clockModels;
@property (nonatomic,strong) NSString* deviceVer;           //设备固件版本号
@property (nonatomic,assign) int power;                     //电池电量状态

/**
 @param 检查蓝牙状态
 **/
- (BOOL)checkBleStateOn;
- (BOOL)checkBleConnectedState;
- (void) alertNewFirmwareVersion;
- (JGBleDeviceInfo *)getPreConnectedBleDevice;

- (void)logForData:(NSData *)data prefix:(NSString *)prefix;
@property(nonatomic,assign) int disConnCount;               //失败连接的次数
@property (nonatomic,assign) BOOL isOldVersionFirmware;     //是否是旧版本的Firmware
@property(strong, nonatomic) NSString* upgradeFileName;         //要进行ota升级的文件名
@property(strong, nonatomic) NSString* upgradeChkFileName;      //要进行校验的chk文件

@property(assign, nonatomic) BOOL isInFunctionVc;           //是否停留在主页

@property (retain, nonatomic) JGBLEManager *bleMgr;
- (NSString *)ToHex:(uint16_t)tmpid;

@property (strong, nonatomic) FunctionViewController* functionVc;

@end

