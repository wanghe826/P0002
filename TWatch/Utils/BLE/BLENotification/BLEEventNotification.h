//
//  BLEEventNotification.h
//  sportsBracelets
//
//  Created by zhang yi on 13-9-25.
//  Copyright (c) 2013年 zhang yi. All rights reserved.
//

#ifndef sportsBracelets_BLEEventNotification_h
#define sportsBracelets_BLEEventNotification_h


/*
MCUIncomingCall  = 0x1,
MCUMemo = 0x2,
MCUNewSMS = 0x3,
MCUSound = 0x5,
*/

#pragma mark - view controller -> app delegate

#define BLEDiscoverCBPeripheralsNotification            @"Discover Peripherals"
#define BLEDiscoverWatchNotification                    @"Discover watch"
#define BLEConnectNotification                          @"Connect"
#define BLEChangePushSwitchStateNotification            @"ChangePushSwitchState"
#define BLEMCUBeginWhenAdjustTimeNotification           @"Begin Adjust Time"
#define BLEMCUEndWhenAdjustTimeNotification             @"end Adjust Time"
#define BLEMCUAdjustTimeNotification                    @"Adjust Time"
#define BLEMCUMemoTriggerNotification                   @"MCUMemo Trigger"
#define BLEMCUTimeSyncNotification                      @"TimeSync"
#define BLEMCUWorldTimeSyncNotification                 @"World TimeSync"
#define BLEMCUSoundNotification                         @"MCUSound"
#define BLEMCUAlarmWhenDisconnect                       @"Alarm When Disconnect"
#define BLESelfDisconnectNotification                   @"BLE self disconnected"
#define BLEMMemoChangeNotification                      @"Memo Change"
#define BLEACKPedometerDataNotification                 @"ACK PedometerData"
#define BLEStopScanDevice                               @"BLEStopScanDevice"
#define BLELetYouKnowIamIOSNotification                 @"BLELetYouKnowIamIOSNotification"
#define BLEClearDataNotification                        @"BLEClearDataNotification"


//新添加
#define BLEForbidMobileLostNotification                 @"ForbidMobileLost"         //关于手机防丢的通知
//关于手机提醒的通知
#define BLENotDisturbNotification                       @"NotDisturbNotification"   //勿扰模式

//拍照相关的通知
#define BLEOnTakePhotoVCNotification                    @"BLEOnTakePhotoVCNotification" //在拍照界面
#define BLENotOnTakePhotoVCNotification                 @"BLENotOnTakePhotoVCNotification"  //不在拍照界面

//运动睡眠设置
#define BLESportModeNotification                        @"BLESportModeNotification"


#pragma mark - app delegate -> view controller

#define BLEDiscoveredDeviceNotification                 @"discovered device"
#define BLEDidFinishScanNotification                    @"DidFinishScan"
#define BLEDidConnectedNotification                     @"DidConnected"
#define BLEDidFailConnectNotification                   @"DidFailConnect"
#define BLEBleStateOnNotification                       @"ble state on"
#define BLEAuthorizedSuccessNotification                 @"Authorized Success"

#pragma mark - old

#endif
