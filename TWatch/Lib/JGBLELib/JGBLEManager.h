//
//  JGBLEManager.h
//  BluetoothLabel
//
//  Created by zhang yi on 13-7-3.
//  Copyright (c) 2013年 zhang yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "JGBleDeviceInfo.h"
#import "SMDatabaseSingleton.h"

#define JGBLERROR_DOMAIN @"JGBLE"
typedef enum {
    JGBLEErrorCharacteristicNoFound
}JGBLEError;

typedef CBPeripheral JGBLEPeripheral;

@interface CBPeripheral (JGBLE)<NSCopying>

- (CBCharacteristic*)characteristicByServerUUID:(CBUUID*)serverUUID characteristicUUID:(CBUUID*)chUUID;
- (BOOL)isFinishedDiscover;
@property(readonly, nonatomic, getter = getCBUUID)CBUUID* CBUUID;

@end


@interface CBCharacteristic (JGBLE)

- (CBUUID*)serverUUID;
- (CBUUID*)deviceUUID;
- (JGBLEPeripheral*)device;
- (void)writeValue:(NSData*)value;

@end


@class JGBLEManager;
@protocol JGBLEManagerDelegate

// 状态改变 只有当CBCentralManagerStatePoweredOn时候才能正常使用
- (void)JGBLEManager:(JGBLEManager*)manager didUpdateState:(CBCentralManagerState)state;
// 搜索到设备，每次都会返回当前搜索到的所有设备UUID
- (void)JGBLEManager:(JGBLEManager*)manager didDiscoverPeripherals:(JGBleDeviceInfo *)device;
- (void)JGBLEManagerDidFinishScan;

// 连接设备相关
- (void)JGBLEManagerDidConnectPeripheral:(NSString *)uuid;
- (void)JGBLEManagerDidFailConnectPeripheral;

//主动断开连接
- (void)JGBLEManager:(JGBLEManager*)manager didDisconnectPeripheralByUUID:(CBPeripheral*)peripheral error:(NSError*)error;

// 设备属性相关
- (void)JGBLEManager:(JGBLEManager*)manager
didRegistUpdateNotifyForDeviceUUID:(CBPeripheral*)peripheral
         serviceUUID:(CBUUID*)serviceUUID
  characteristicUUID:(CBUUID *)characteristicUUID
               error:(NSError*)error;

- (void)JGBLEManager:(JGBLEManager*)manager
      didUpdateValue:(NSData*)value
       forDeviceUUID:(CBPeripheral*)peripheral
         serviceUUID:(CBUUID*)serviceUUID
  characteristicUUID:(CBUUID *)characteristicUUID
               error:(NSError*)error
       processResult:(BOOL*)result
  withCharacteristic:(CBCharacteristic*)characteristic;

- (void)JGBLEManager:(JGBLEManager*)manager
       didWriteValue:(NSData*)value
       forDeviceUUID:(CBPeripheral*)peripheral
         serviceUUID:(CBUUID*)serviceUUID
  characteristicUUID:(CBUUID *)characteristicUUID
               error:(NSError*)error;

//修改
- (void)JGBLEManager:(JGBLEManager*)manager
didFinishDiscoverServiceAndCharacteristicForDeviceUUID:(CBPeripheral*)peripheral
         withService:(CBService*)service;

// 信号变化
- (void)JGBLEManager:(JGBLEManager*)manager
       didUpdateRSSI:(NSNumber*)RSSI
       forDeviceUUID:(CBPeripheral*)peripheral;

@end

@interface JGBLEManager : NSObject
{
    NSTimer* _scanMaxTimer;
    NSTimer* _scanTimeoutTimer;
    NSMutableArray* _connectDevTimers;
    CBCentralManager* _manager;
    NSMutableDictionary* _UUIDDeviceDic;
    // 可能用户注册属性改变通知回调时候设备的服务以及属性还没读取完全
    // 所以下面这个这个是用来缓存要注册的属性
    NSMutableDictionary* _observedCharacteristics;
    NSMutableArray* _discoverUUIDDevices;
    
    NSMutableArray *commandArray;
    NSString *checkSumType;
    
    NSTimer* _reconnectTimer;
    BOOL _hasGottaAck;      //是否收到MCU的ack
    
    
    NSDate* _nearDate;
    NSDateFormatter* _dateFormatter;
    SMDatabaseSingleton* _singleton;
    
    int _bigPackageOffset;      //应该跳跃的大包数
    int _allDataLength;         //总数据包数
    BOOL _hasRecieveSportDataOk;    //是否收到了计步数据
    
    int _sendIndex;             //发送编号
    int _recIndex;              //收到编号
    
    //收到MCU发来的修改连接间隔成功的通知
    BOOL _isConnectionIntervalChangeOk;
    
    BOOL _haveReceivedACK;
    
    NSTimer* _receiveDataTimer;
    
    //是否正在获取手表的数据
    BOOL _isFetchingSportData;
    
    //是否配对
    BOOL _isPaired;
    
    //当前连接成功的设备
    JGBleDeviceInfo* _currentConnectedDeviceInfo;
    
    int _alreadyReceivedPckIndex;
    
    //运动数据上传相关
    @public
    BOOL _hasReadytoDownloadSportData;
}

@property(nonatomic,strong) NSString* currentUUIDString;

@property(assign, nonatomic) id<JGBLEManagerDelegate> delegate;
@property(readonly, nonatomic) NSMutableArray* scanedDevices;
@property(nonatomic,assign) BOOL isBootLoaderCharacteristicFound;
@property(nonatomic,assign) CBCharacteristic *bootLoaderCharacteristic;
@property(nonatomic,strong) void (^downloadBinFile)();

@property(nonatomic,strong) NSMutableArray<CBCharacteristic*> *myCharacterisics;
@property(nonatomic,strong) NSMutableArray<SportModel*> * sportModelsBuffer;
@property(nonatomic,assign) int ackCount;

- (void) retrievePeriphralBySystem;

- (void) startRetrieveConnTimer;
- (void) stopRetrieveConnTimer;

- (void) requestAuthorizedFromWatch:(BOOL)isForbid;

- (NSString*)periphralName;

- (void) requestVersionBatteryAndSyncSwitch;

- (void) writeValueToDeviceWithServiceAndCharactersitc:(CBUUID*)serviceUUID withChUUID:(CBUUID*)chUUID withData:(NSData*)data;

- (void) fetchSportData;
/*!
 *  @property siliconIDString
 *
 *  @discussion siliconID from the device response
 *
 */
@property (strong,nonatomic) NSString *siliconIDString;

/*!
 *  @property siliconRevString
 *
 *  @discussion silicon rev from the device response
 *
 */
@property (strong,nonatomic) NSString *siliconRevString;

/*!
 *  @property isWriteRowDataSuccess
 *
 *  @discussion flag used to check whether data writing is success
 *
 */

@property (nonatomic) BOOL isWriteRowDataSuccess;

/*!
 *  @property isWritePacketDataSuccess
 *
 *  @discussion flag used to check whether packet data writing is success
 *
 */

@property (nonatomic) BOOL isWritePacketDataSuccess;
/*!
 *  @property startRowNumber
 *
 *  @discussion Device flash start row number
 *
 */
@property (nonatomic) int startRowNumber;

/*!
 *  @property endRowNumber
 *
 *  @discussion Device flash end row number
 *
 */
@property (nonatomic) int endRowNumber;

/*!
 *  @property checkSum
 *
 *  @discussion checkSum received from the device for writing a single row
 *
 */
@property (nonatomic) uint8_t checkSum;

/*!
 *  @property isApplicationValid
 *
 *  @discussion flag used to check whether the application writing is success
 *
 */
@property (nonatomic) BOOL isApplicationValid;

/*!
 *  @property bootLoaderFilesArray
 *
 *  @discussion  Firmware files selected for device upgrade.
 *
 */

@property (retain, nonatomic) NSArray *bootLoaderFilesArray;

+ (id)sharedManager;

- (JGBLEPeripheral*)deviceByUUID:(CBUUID*)UUID;
/*
 *检测系统连接的设备中是否包含上次连接的设备标识，如果有自动连接。
 */
- (BOOL)isSystemConnectedBlesContain:(NSString *)bleIdentifier;

/*
 搜索设备,如果不指定超时，会一直查找设备直到手动调用stopScan为止
 回调为:
 - (void)JGBLEManager:(JGBLEManager*)manager didDiscoverPeripherals:(NSArray*)peripherals;
 可能不止回调一次
 */
- (void)startScanWithTimeOut:(NSTimeInterval)timeout;
- (void)stopScan;

/*
 连接设备，如果不指定超时，会一直尝试连接设备直到连接到设备为止
 回调为:
 - (void)JGBLEManager:(JGBLEManager*)manager didConnectPeripheralByUUID:(CBUUID*)peripheralUUID;
 - (void)JGBLEManager:(JGBLEManager*)manager didFailConnectPeripheralByUUID:(CBUUID*)peripheralUUID error:(NSError*)error;
 */
- (JGBleDeviceInfo *)preConnectedDevice;
- (void)connectDeviceByIdentifier:(NSString*)identifier timeout:(NSTimeInterval)timeout;
- (void)cancelDeviceConnect;
- (void)disconnectConnectedDevice;


- (NSData *)setSwitchState:(UInt16)states;

/*
 注册监听设备属性改变回调
 注册结果回调为:
 - (void)JGBLEManager:(JGBLEManager*)manager
 didRegistUpdateNotifyForDeviceUUID:(CBUUID*)peripheralUUID
 serviceUUID:(CBUUID*)serviceUUID
 characteristicUUID:(CBUUID *)characteristicUUID
 error:(NSError*)error;
 */
- (void)registUpdateNotifyForDeviceUUID:(CBPeripheral*)peripheral
                            serviceUUID:(CBUUID*)serviceUUID
                     characteristicUUID:(CBUUID*)characteristicUUID;

/*
 写设备的属性
 回调为:
 - (void)JGBLEManager:(JGBLEManager*)manager
 didWriteValue:(NSData*)value
 forDeviceUUID:(CBUUID*)peripheralUUID
 serviceUUID:(CBUUID*)serviceUUID
 characteristicUUID:(CBUUID *)characteristicUUID
 error:(NSError*)error;
 */
- (void)writeValue:(NSData*)value
        deviceUUID:(CBPeripheral*)peripheral
       serviceUUID:(CBUUID*)serviceUUID
characteristicUUID:(CBUUID*)characteristicUUID;

/*
 读设备的属性
 读到属性回调为:
 - (void)JGBLEManager:(JGBLEManager*)manager
 didUpdateValue:(NSData*)value
 forDeviceUUID:(CBUUID*)peripheralUUID
 serviceUUID:(CBUUID*)serviceUUID
 characteristicUUID:(CBUUID *)characteristicUUID
 error:(NSError*)error;
 */
- (void)readValueOfDeviceUUID:(CBPeripheral*)peripheral
                  serviceUUID:(CBUUID*)serviceUUID
           characteristicUUID:(CBUUID*)characteristicUUID;


/*
 设置读信号强度时间间隔 0代表不读取
 读到属性回调为:
 - (void)JGBLEManager:(JGBLEManager*)manager
 didUpdateRSSI:(NSNumber*)RSSI
 forDeviceUUID:(CBUUID*)peripheralUUID;
 */
- (void)setReadRssiOfDeviceUUID:(CBPeripheral*)peripheral frequency:(NSTimeInterval)time;

///ota

-(void) updateValueForCharacteristicWithCompletionHandler:(void (^) (BOOL success,id command,NSError *error)) handler;
-(void) writeValueToCharacteristicWithData:(NSData *)data bootLoaderCommandCode:(unsigned short)commandCode;
-(void) stopUpdate;

-(NSData *) createCommandPacketWithCommand:(uint8_t)commandCode dataLength:(unsigned short)dataLength data:(NSDictionary *)packetDataDictionary ;
-(void) setCheckSumType:(NSString *)type;

//新增加
- (void) setNotifyForCharateristic:(BOOL)type withCharateristic:(CBCharacteristic*)characteristic;

@end
