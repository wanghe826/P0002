//
//  JGBLEManager.m
//  BluetoothLabel
//
//  Created by zhang yi on 13-7-3.
//  Copyright (c) 2013年 zhang yi. All rights reserved.
//
#import "ClockModel.h"
#import "SportsDataUtil.h"
#import "JGBLEManager.h"
#import "FirmwareFileDownloadUtils.h"
#import <objc/runtime.h>
#import "SportModel.h"
#import "JGBLEManager+Simple.h"
//#import "UIView+Toast.h"
#import "Constants.h"
#import "SVProgressHUD.h"
#define COMMAND_PACKET_MIN_SIZE  7
//0x03,0x0E,0x11

@implementation CBPeripheral (JGBLE)

- (CBCharacteristic*)characteristicByServerUUID:(CBUUID*)serverUUID characteristicUUID:(CBUUID*)chUUID
{
    for (CBService * service in self.services)
    {
        if ([service.UUID isEqualToCBUUID:serverUUID])
        {
            for (CBCharacteristic* ch in service.characteristics)
            {
                if ([ch.UUID isEqualToCBUUID:chUUID])
                {
                    return ch;
                }
            }
        }
    }
    
    return nil;
}

- (BOOL)isFinishedDiscover
{
    if (self.services.count > 0)
    {
        CBService* serv = self.services.lastObject;
        if (serv.characteristics.count > 0)
        {
            return YES;
        }
    }
    return NO;
}

static const char* UUIDKEY = "UUIDKEY";
- (CBUUID*)getCBUUID
{
    CBUUID* uuid = objc_getAssociatedObject(self, UUIDKEY);
    if (uuid == nil)
    {
        //        uuid = [CBUUID UUIDWithCFUUID:self.UUID];
        uuid = [CBUUID UUIDWithCFUUID:CFBridgingRetain(self.CBUUID)];
        objc_setAssociatedObject(self, UUIDKEY, uuid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return uuid;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end

@implementation CBCharacteristic (JGBLE)

- (CBUUID*)serverUUID
{
    return self.service.UUID;
}

- (CBUUID*)deviceUUID
{
    //    return [CBUUID UUIDWithCFUUID:self.service.peripheral.UUID];
    return [CBUUID UUIDWithCFUUID:CFBridgingRetain(self.service.peripheral.CBUUID)];
}

- (JGBLEPeripheral*)device
{
    return self.service.peripheral;
}

- (void)writeValue:(NSData*)value
{
    NSLog(@"writeValue:<%@>", value);
    [[self device] writeValue:value forCharacteristic:self type:CBCharacteristicWriteWithoutResponse];
}

@end

@interface JGBLEManager()
{
    void (^cbCharacteristicUpdationHandler)(BOOL success,id command,NSError *error);
}
@property (retain, nonatomic) CBPeripheral *peripheral;
@property (nonatomic) BOOL intendToDisconnect;

@end

@interface JGBLEManager (Private)<CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@implementation JGBLEManager

+ (id)sharedManager {
    static JGBLEManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self != NULL)
    {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _connectDevTimers = [NSMutableArray new];
        _scanedDevices = [NSMutableArray new];
        _observedCharacteristics = [NSMutableDictionary new];
        _UUIDDeviceDic = [NSMutableDictionary new];
        _discoverUUIDDevices = [NSMutableArray new];
        
        commandArray = [[NSMutableArray alloc] init];
        self.downloadBinFile = nil;
        
        self.ackCount = 0;
        
        _hasReadytoDownloadSportData = NO;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        _singleton = [SMDatabaseSingleton shareInstance];
        _bigPackageOffset = 0;
        _allDataLength = 0;
        _hasRecieveSportDataOk = NO;
        
        _sendIndex = 0;
        _recIndex = 0;
        
        _haveReceivedACK = NO;
        _isConnectionIntervalChangeOk = NO;
        self.myCharacterisics = [[NSMutableArray alloc] initWithCapacity:1];
        
        _isFetchingSportData = NO;
        
        self.sportModelsBuffer = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSData* data = [[NSUserDefaults standardUserDefaults] valueForKey:BLEConnectedKey];
        if(data){
            JGBleDeviceInfo* info = (JGBleDeviceInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.currentUUIDString = info.identifier;           //保存设备的uuid（如果当前没有连接，则保存的是上一个版本的uuid）
            NSLog(@"-----shebeiuuid--->%@", self.currentUUIDString);
        }
        
        _isPaired = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if (_scanMaxTimer != nil)
    {
        [_scanMaxTimer invalidate];
        _scanMaxTimer = nil;
    }
    for (NSTimer* timer in _connectDevTimers)
    {
        [timer invalidate];
    }
    _connectDevTimers = nil;
    _manager = nil;
    
    _scanedDevices = nil;
    
    _UUIDDeviceDic = nil;
    
    _discoverUUIDDevices = nil;
    
}

#pragma mark - scan ble device

- (BOOL)isSystemConnectedBlesContain:(NSString *)bleIdentifier {
    if (bleIdentifier) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:bleIdentifier];
        NSArray *peripherals = [_manager retrievePeripheralsWithIdentifiers:@[uuid]];
        if (peripherals && peripherals.count) {
            //            [_manager connectPeripheral:peripherals[0] options:nil];
            return YES;
        }
    }
    return NO;
}

- (void)initScanTimerWithTimeout:(NSTimeInterval)timeout {
    if (_scanMaxTimer != nil)
    {
        [_scanMaxTimer invalidate];
        _scanMaxTimer = nil;
    }
    _scanMaxTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(stopScan) userInfo:nil repeats:NO];
}

- (void)startScanWithTimeOut:(NSTimeInterval)timeout {
    [_scanedDevices removeAllObjects];
    [self initScanTimerWithTimeout:timeout];
    [_manager scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - stop scan ble device

- (void)stopScan
{
    [_manager stopScan];
    [_scanMaxTimer invalidate];
    _scanMaxTimer = nil;
    [_scanTimeoutTimer invalidate];
    _scanTimeoutTimer = nil;
    [_delegate JGBLEManagerDidFinishScan];
}

- (NSString*) periphralName
{
    if(!self.peripheral){
        return nil;
    }
    return self.peripheral.name;
}

- (JGBleDeviceInfo *)preConnectedDevice {
    NSData *seriData = [[NSUserDefaults standardUserDefaults] valueForKey:BLEConnectedKey];
    if (seriData) {
        JGBleDeviceInfo *deviceInfo = [NSKeyedUnarchiver unarchiveObjectWithData:seriData];
        if (deviceInfo) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:deviceInfo.identifier];
            NSArray *per = [_manager retrievePeripheralsWithIdentifiers:@[uuid]];
            if (per && per.count) {
                [_scanedDevices addObject:per[0]];
                return deviceInfo;
            }
        }
    }
    return nil;
}

//连接设备
- (void)connectDeviceByIdentifier:(NSString*)identifier timeout:(NSTimeInterval)timeout
{
    for (CBPeripheral *peri in _scanedDevices) {
        if ([peri.identifier.UUIDString isEqualToString:identifier]) {
            self.peripheral = peri;
            break;
        }
    }
    if (self.peripheral != nil) {
        [_scanedDevices removeAllObjects];
//        [_manager connectPeripheral:self.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:[NSNumber numberWithBool:YES]}];
        
        [_manager connectPeripheral:self.peripheral options:nil];
    
        NSLog(@"开始连接蓝牙--> %@", self.peripheral);
        //        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(onConnectTimeout:) userInfo:self.peripheral repeats:NO];
        //        [_connectDevTimers addObject:timer];
    }
}

- (void)onConnectTimeout:(NSTimer*)timer
{
    [_connectDevTimers removeObject:timer];
    if (!(self.peripheral.state == CBPeripheralStateConnected))
    {
        [self cancelDeviceConnect];
        [self.delegate JGBLEManagerDidFailConnectPeripheral];
    }
}

- (void)cancelDeviceConnect
{
    if (self.peripheral == nil) {
        return;
    }
    [_manager cancelPeripheralConnection:self.peripheral];
//    self.peripheral = nil;
}

- (void)disconnectConnectedDevice
{
    self.intendToDisconnect = YES;
    [self cancelDeviceConnect];
    //    [self clearUserDefaults];
}

- (void)clearUserDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BLEConnectedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) writeValueToDeviceWithServiceAndCharactersitc:(CBUUID*)serviceUUID withChUUID:(CBUUID*)chUUID withData:(NSData*)data
{
    NSLog(@"-----------------写数据-----------------%@", data);
    CBCharacteristic* characteristic = [self.peripheral characteristicByServerUUID:serviceUUID characteristicUUID:chUUID];
    if(characteristic){
        [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}


- (BOOL)doRegistUpdateNotifyForDevice:(JGBLEPeripheral*)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID
{
    CBCharacteristic* ch = [device characteristicByServerUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (ch != nil)
    {
        [device setNotifyValue:YES forCharacteristic:ch];
        return YES;
    }
    else
    {
        NSError* error = [NSError errorWithDomain:JGBLERROR_DOMAIN code:JGBLEErrorCharacteristicNoFound userInfo:nil];
        [self.delegate JGBLEManager:self didRegistUpdateNotifyForDeviceUUID:device serviceUUID:ch.serverUUID characteristicUUID:ch.UUID error:error];
    }
    return NO;
}

- (void)registUpdateNotifyForDeviceUUID:(CBPeripheral *)peripheral serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID{
    if ([peripheral isFinishedDiscover])
    {
        [self doRegistUpdateNotifyForDevice:peripheral serviceUUID:serviceUUID characteristicUUID:characteristicUUID];
    }
    else
    {
        NSMutableSet* chSet = [_observedCharacteristics objectForKey:peripheral];
        if(chSet == nil)
        {
            chSet = [NSMutableSet new];
            [_observedCharacteristics setObject:chSet forKey:peripheral];
        }
        [chSet addObject:@[serviceUUID, characteristicUUID]];
    }
    
}

- (void)writeValue:(NSData*)value deviceUUID:(CBPeripheral*)peripheral serviceUUID:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*) characteristicUUID
{
    CBCharacteristic* ch = [peripheral characteristicByServerUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (ch != nil)
    {
        [peripheral writeValue:value forCharacteristic:ch type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        NSError* error = [NSError errorWithDomain:JGBLERROR_DOMAIN code:JGBLEErrorCharacteristicNoFound userInfo:nil];
        [self.delegate JGBLEManager:self didWriteValue:value forDeviceUUID:peripheral serviceUUID:serviceUUID characteristicUUID:characteristicUUID error:error];
    }
}

- (void)readValueOfDeviceUUID:(CBPeripheral*)peripheral
                  serviceUUID:(CBUUID*)serviceUUID
           characteristicUUID:(CBUUID*)characteristicUUID
{
    CBCharacteristic* ch = [peripheral characteristicByServerUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (ch != nil)
    {
        [peripheral readValueForCharacteristic:ch];
    }
    else
    {
        BOOL processResult = NO;
        NSError* error = [NSError errorWithDomain:JGBLERROR_DOMAIN code:JGBLEErrorCharacteristicNoFound userInfo:nil];
        [self.delegate JGBLEManager:self didUpdateValue:nil forDeviceUUID:peripheral serviceUUID:serviceUUID characteristicUUID:characteristicUUID error:error processResult:&processResult withCharacteristic:ch];
    }
}

#pragma mark private function
- (JGBLEPeripheral*)deviceByUUID:(CBUUID*)UUID
{
    return [_UUIDDeviceDic objectForKey:UUID];
}


#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //    // 初始的时候是未知的（刚刚创建的时候）
    //    CBCentralManagerStateUnknown = 0,
    //    //正在重置状态
    //    CBCentralManagerStateResetting,
    //    //设备不支持的状态
    //    CBCentralManagerStateUnsupported,
    //    // 设备未授权状态
    //    CBCentralManagerStateUnauthorized,
    //    //设备关闭状态
    //    CBCentralManagerStatePoweredOff,
    //    // 设备开启状态 -- 可用状态
    //    CBCentralManagerStatePoweredOn,
    //    NSLog(@"蓝牙状态:%d",central.state);
    [self.delegate JGBLEManager:self didUpdateState:central.state];
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStatePoweredOff:
        {
            [SVProgressHUD dismiss];
            [BLEAppContext shareBleAppContext].isConnected = NO;
            [BLEAppContext shareBleAppContext].isAuthorized = NO;
            [BLEAppContext shareBleAppContext].isSelfDisconnect = YES;
            _isFetchingSportData = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shishishuaxin" object:nil];
            break;
        }
        case CBCentralManagerStateUnauthorized:
            NSLog(@"蓝牙状态处于不允许状态");
            break;
        default:
            break;
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (_scanTimeoutTimer) {
        [_scanTimeoutTimer invalidate];
        _scanTimeoutTimer = nil;
        _scanTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(stopScan) userInfo:nil repeats:NO];
    }
    
    NSLog(@"对用的sn是多少---> %@", [advertisementData objectForKey:@"kCBAdvDataManufacturerData"]);
    NSLog(@"广播数据是: %@", advertisementData);
    
    if(![advertisementData objectForKey:@"kCBAdvDataManufacturerData"])
    {
        return;
    }
    
    NSData* data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    
    if(!(data.length != 4 || data.length!=5))
    {
        NSLog(@"长度不一致");
        return;
    }
    
    
    
    Byte* bytes = (Byte*)[data bytes];
    //!(bytes[0]==0x30 && bytes[1]==0x30 && bytes[2]==0x30 && bytes[3]==0x31) &&
    if(!(bytes[0]==0x30 && bytes[1]==0x30 && bytes[2]==0x30 && bytes[3]==0x32) && !((bytes[0]==0x50) && (bytes[1]==0x30) && (bytes[2]==0x30) && (bytes[3]==0x30) && (bytes[4]==0x32)))
    {
        NSLog(@"不是w07");
        return;
    }
    
    
//过滤掉信号弱的设备
    if(abs([RSSI intValue])>80)
    {
        return;
    }
    
    
    if (![_scanedDevices containsObject:peripheral])
    {
        [_scanedDevices addObject:peripheral];
        JGBleDeviceInfo *device = [[JGBleDeviceInfo alloc] init];
        device.name = peripheral.name;
        device.identifier = peripheral.identifier.UUIDString;
        device.rssi = RSSI;
        [self.delegate JGBLEManager:self didDiscoverPeripherals:device];
    }
    
    
    if((bytes[0]==0x50) && (bytes[1]==0x30) && (bytes[2]==0x30) && (bytes[3]==0x30) && (bytes[4]==0x32))
    {
        JGBleDeviceInfo *device = [[JGBleDeviceInfo alloc] init];
        device.name = peripheral.name;
        device.identifier = peripheral.identifier.UUIDString;
        device.rssi = RSSI;
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoverWatchNotification object:nil userInfo:@{@"device":device}];
    }

    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.intendToDisconnect = NO;
    self.peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [self.myCharacterisics removeAllObjects];
    
    JGBleDeviceInfo *device = [[JGBleDeviceInfo alloc] init];
    device.name = self.peripheral.name;
    device.identifier = self.peripheral.identifier.UUIDString;
    self.currentUUIDString = device.identifier;
    device.rssi = self.peripheral.RSSI;
    _currentConnectedDeviceInfo = device;
    
   
    
    [self.delegate JGBLEManagerDidConnectPeripheral:peripheral.identifier.UUIDString];
}

- (NSData *)setSwitchState:(UInt16)states {
    NSData *data = [NSData BLESetEventMask:states];
    return data;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.peripheral = nil;
    [self.delegate JGBLEManagerDidFailConnectPeripheral];
    NSLog(@"error----->   %@", error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [BLEAppContext shareBleAppContext].isAuthorized = NO;
    
    _isPaired = NO;
    
    ApplicationDelegate.isOldVersionFirmware = NO;
    [self.delegate JGBLEManager:self didDisconnectPeripheralByUUID:peripheral error:error];
    if (!self.intendToDisconnect) {
        if (self.peripheral) {
#warning 记得打开以下信息
            //            [_manager connectPeripheral:self.peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        }
    }
    
#warning SVProgressHUD
    if([BLEAppContext shareBleAppContext].isInsertingData == YES)  return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
}

- (void) startRetrieveConnTimer
{
    //    [self retrievePeriphralBySystem];
    if(_reconnectTimer != nil)
    {
        [_reconnectTimer setFireDate:[NSDate distantPast]];
    }
    else
    {
        _reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectPeripheralAlradyConnectedBySystem) userInfo:nil repeats:YES];
    }
}
- (void) stopRetrieveConnTimer
{
    if(_reconnectTimer != nil)
    {
        [_reconnectTimer setFireDate:[NSDate distantFuture]];
    }
}


- (void) retrievePeriphralBySystem
{
    if(_reconnectTimer == nil)
    {
        _reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectPeripheralAlradyConnectedBySystem) userInfo:nil repeats:YES];
    }
    
    if([_reconnectTimer isValid])
    {
        return;
    }
    [_reconnectTimer fire];
}

- (void) connectPeripheralAlradyConnectedBySystem
{
    if([BLEAppContext shareBleAppContext].isConnected || [BLEAppContext shareBleAppContext].isSelfDisconnect)      //如果已经连接上手表就不需要再重连了
    {
        if(_reconnectTimer != nil)
        {
            if([_reconnectTimer isValid])
            {
                [_reconnectTimer invalidate];
                _reconnectTimer = nil;
            }
        }
        return ;
    }
    NSArray* alreadyConnectedArray = [_manager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000a800-0000-1000-8000-00805f9b34fb"]]];
    NSLog(@"已经被系统连接了几个---》 %d", (int)alreadyConnectedArray.count);
    
    for (CBPeripheral * per in alreadyConnectedArray)
    {
        //P0002的项目
        if(![per.name isEqualToString:@"FAMAR"])
        {
            continue;
        }
        self.peripheral = per;
        [_manager connectPeripheral:self.peripheral options:nil];
        
        if(_reconnectTimer != nil)
        {
            if([_reconnectTimer isValid])
            {
                [_reconnectTimer invalidate];
                _reconnectTimer = nil;
            }
        }
        return;
    }
}


#pragma mark CBCentralManagerDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.delegate JGBLEManager:self didUpdateRSSI:peripheral.RSSI forDeviceUUID:peripheral];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService* service in peripheral.services)
    {
        NSLog(@"发现服务");
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    // not used currently
}

- (void)registerNofityForCachedOfDevice:(CBPeripheral *)peripheral
{
    NSMutableSet* chSet = [_observedCharacteristics objectForKey:peripheral];
    for (NSArray* array in chSet)
    {
        assert([array count] == 2);
        BOOL success = [self doRegistUpdateNotifyForDevice:peripheral serviceUUID:[array objectAtIndex:0] characteristicUUID:[array objectAtIndex:1]];
        if (success)
        {
            [chSet removeObject:array];
        }
    }
    if (chSet.count == 0)
    {
        [_observedCharacteristics removeObjectForKey:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error)
    {
        NSLog(@"发现特征失败，错误码是: %@", error);
        return;
    }
    [self.delegate JGBLEManager:self didFinishDiscoverServiceAndCharacteristicForDeviceUUID:peripheral withService:service];
    
    if(ApplicationDelegate.isOnFirmwareUpgrade){
        return;
    }
    
    for(CBCharacteristic* characteristic in service.characteristics)
    {
        self.peripheral = peripheral;
        
        if([[characteristic.UUID UUIDString] isEqualToString:@"2A19"])
        {
            ApplicationDelegate.isOldVersionFirmware = YES;
            [self.peripheral readValueForCharacteristic:characteristic];      //读取电量特征值
        }
        if([[characteristic.UUID UUIDString] isEqualToString:@"2A26"])
        {
            [self.peripheral readValueForCharacteristic:characteristic];      //读取版本号特征值
        }
        
        
        if([[characteristic.UUID UUIDString] isEqualToString:BLE_DATA_CHARACTERISTIC_UUID.UUIDString])
        {
            [BLEAppContext shareBleAppContext].isPaired = YES;
            [self.myCharacterisics addObject:characteristic];
            
            
            if([BLEAppContext shareBleAppContext].isInSearchVC == NO)
            {
                [self requestAuthorizedFromWatch:YES];
            }
            else
            {
                [self requestAuthorizedFromWatch:NO];
            }
            
            if(ApplicationDelegate.isOldVersionFirmware)
            {
                if(_hasReadytoDownloadSportData){
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        _sendIndex = 0;
                        if([BLEAppContext shareBleAppContext].isInsertingData == NO)
                        {
                            [self.sportModelsBuffer removeAllObjects];
                        }
                        [self requestSportsData:0];
                    });
                    return;
                }
            }
        }
        
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
    }
    
}

//获取电量，版本号
- (void) requestVersionBatteryAndSyncSwitch
{
    //请求电量和版本号
    Byte battery[7] = {'$', 4, 0x02, 0x0c, 0x01, 0x01,0x0e};
    NSData* batteryData = [NSData dataWithBytes:battery length:7];
    [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:batteryData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(!ApplicationDelegate.deviceVer || ApplicationDelegate.power==0)
        {
            [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:batteryData];
        }
    });
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    BOOL processResult = NO;
    [self.delegate JGBLEManager:self didUpdateValue:characteristic.value forDeviceUUID:peripheral serviceUUID:[characteristic serverUUID] characteristicUUID:characteristic.UUID error:error processResult:&processResult withCharacteristic:characteristic];
    if(ApplicationDelegate.isOnFirmwareUpgrade)
    {
        return;
    }
    
    
    if([characteristic.UUID.UUIDString isEqualToString:UPLOAD_SPORT_DATA_CHANNEL]){
        //3通道的计步数据
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"---收到计步数据--> %@", characteristic.value);
            _hasRecieveSportDataOk = YES;
            _hasReadytoDownloadSportData = NO;
            [self assemableSportData:(Byte*)[characteristic.value bytes]];
        });
        return;
    }
    
    Byte* recBytes = (Byte*)[characteristic.value bytes];
    
    
    //收到闹钟设置成功的反馈
    if(characteristic.value.length>5 && recBytes[0]==0x24 && recBytes[1]==0x04 && recBytes[2]==0x02 && recBytes[3]==0x19){
        int clockIndex = recBytes[5];
        NSLog(@"第%d个闹钟设置成功", clockIndex);
    }
    
    
    if(recBytes[0]==0x24 && recBytes[1]==0x03 && recBytes[2]==0x02 && recBytes[3]==0x01 && recBytes[4]==0xaa && recBytes[5]==0xab){
        self.ackCount++;
        NSLog(@"收到aaaaaaccck");
        _haveReceivedACK = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEACKNotificationKey object:nil];
    }
    
    
    //久坐提醒时间获取
    if(recBytes[0]==0x24 && recBytes[1]==0x05 && recBytes[2]==0x02 && recBytes[3]==0x0a && recBytes[4]==0x01 && recBytes[5]==0x15)
    {
        int jiuzuo = recBytes[6];
        NSLog(@"---久坐的时间是%d", jiuzuo);
        [[NSUserDefaults standardUserDefaults] setInteger:jiuzuo forKey:JiuzuoStatusKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //收到MCU修改连接间隔成功的通知
    if(recBytes[0]==0x24 && recBytes[1]==4 && recBytes[2]==0x02 && recBytes[3]==0x0d && recBytes[4]==0x01 && recBytes[5]==0x01)
    {
        [BLEAppContext shareBleAppContext].isConnected = YES;
        [BLEAppContext shareBleAppContext].isPaired = YES;
        _isConnectionIntervalChangeOk = YES;
        Byte ackByte[6] = {'$',3,0x02,0x1d,0x01,0x1e};
        [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:[NSData dataWithBytes:ackByte length:6]];
        
        
        //如果是在准备上传运动数据
        if(_hasReadytoDownloadSportData){
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                _sendIndex = 0;
                if([BLEAppContext shareBleAppContext].isInsertingData == NO)
                {
                    [self.sportModelsBuffer removeAllObjects];
                }
                [self requestSportsData:0];
                
#warning SVProgressHUD
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(ApplicationDelegate.isInFunctionVc)
                    {
                        [SVProgressHUD showWithStatus:NSLocalizedString(@"正在获取数据", nil) maskType:SVProgressHUDMaskTypeGradient];
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                });
                
            });
            return;
        }
    }
    
    //收到配对的通知
    if(recBytes[0]==0x24 && recBytes[1]==3 && recBytes[2]==0x01 && recBytes[3]==0x1d && recBytes[4]==0x01)
    {
        _isPaired = YES;
    }
    
    
    //允许授权
    if(recBytes[0]==0x24 && recBytes[1]==4 && recBytes[2]==0x02 && recBytes[3]==0x0a && recBytes[4]==0x01 && recBytes[5]==0x13)
    {
       if(_currentConnectedDeviceInfo)
       {
           NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_currentConnectedDeviceInfo];
           [[NSUserDefaults standardUserDefaults] setValue:data forKey:BLEConnectedKey];
           [[NSUserDefaults standardUserDefaults] synchronize];
       }
        
        //二岗同志(发起配对请求)
        Byte ergan[7] = {'$', 0x04, 0x01, 0x0d, 0x01, 0x01, 0xf};
        
        NSData* pairedData = [NSData dataWithBytes:ergan length:7];
        [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:BLE_CONTROL_CHARACTERISTIC_UUID withData:pairedData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_isPaired==NO)
            {
               [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:BLE_CONTROL_CHARACTERISTIC_UUID withData:pairedData];
            }
        });
        
        [self requestVersionBatteryAndSyncSwitch];
        
        [BLEAppContext shareBleAppContext].isAuthorized = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEAuthorizedSuccessNotification object:nil];
        
        NSLog(@"允许授权了------");
        
        //同步运动目标数据
        int target = 0;
        if(![[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey])
        {
            target = 10000;
        }
        else
        {
            target = (int)[[NSUserDefaults standardUserDefaults] integerForKey:FootTargetKey];
        }
        
        Byte targets[11] = {0x24, 0x08, 0x02, 0x0a, 0x01, 0x29};
        targets[9] = (UInt8)(target >>24);
        targets[8] = (UInt8)(target >>16);
        targets[7] = (UInt8)(target >> 8);
        targets[6] = (UInt8)target;
        UInt8 checkSum = targets[3] + targets[4] + targets[5] + targets[6] + targets[7] + targets[8] + targets[9];
        targets[10] = checkSum;
        NSData* targetData = [NSData dataWithBytes:targets length:11];
        [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:BLE_CONTROL_CHARACTERISTIC_UUID withData:targetData];
        
    }
    
    //未授权
    if(recBytes[0]==0x24 && recBytes[1]==4 && recBytes[2]==0x02 && recBytes[3]==0x0a && recBytes[4]==0x01 && recBytes[5]==0x14)
    {
        [BLEAppContext shareBleAppContext].isAuthorized = NO;
        [self cancelDeviceConnect];
    }
    
    
    
    if(recBytes[0]==0x24 && recBytes[1]==0x0c && recBytes[2]==0x02 && recBytes[3]==0x1c && recBytes[4]==0x01)
    {
        Byte version[8] = {recBytes[5], recBytes[6], recBytes[7],recBytes[8],recBytes[9],recBytes[10],recBytes[11],recBytes[12]};
        NSString* str = [[NSString alloc] initWithBytes:version length:8 encoding:NSUTF8StringEncoding];
        int battery = (int)recBytes[13];
        NSLog(@"电量是多少:%d", battery);
        NSLog(@"版本号是多少:%@", str);
        
        ApplicationDelegate.power = battery;
        ApplicationDelegate.deviceVer = str;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shishishuaxin" object:nil];
        //根据版本号从服务器获取最新版本的firmware固件
        self.downloadBinFile = ^{
            [FirmwareFileDownloadUtils downloadNewVersionFirmware:@"P0002" withVersion:str];
        };
        dispatch_async(dispatch_get_global_queue(0, 0), self.downloadBinFile);
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
        
        //收到版本和电量同步App开关
        _haveReceivedACK = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil];
        
        
        //同步勿扰
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BLENotDisturbNotification object:nil];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), globalQueue, ^{
            if(_haveReceivedACK==YES)
            {
                //同步勿扰
                _haveReceivedACK = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:BLENotDisturbNotification object:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), globalQueue, ^{
                    if(_haveReceivedACK == NO)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:BLENotDisturbNotification object:nil];
                    }
                    
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), globalQueue, ^{
                    if(_isConnectionIntervalChangeOk==NO)
                    {
#warning 如果没有收到MCU发来的修改连接间隔成功的命令呢？？？？
                        NSLog(@"没有收到蓝牙连接间隔成功的通知");
                        //                    [_manager cancelPeripheralConnection:self.peripheral];
                    }
                });
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil];
            }
        });
        
    }
    
    
    
    //MCU连接上10s后告诉APP我已经连接上了
    if(recBytes[0]==0x24 && recBytes[1]==0x04 && recBytes[2]==0x02 && recBytes[3]==0x1A && recBytes[4]==0x01 && recBytes[5]==0x02){
        Byte by[7] = {'$', 0x04, 0x02, 0x0A, 0x01, 0x02, 0xD};
        [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:[NSData dataWithBytes:by length:7]];
    }
    
    
    //收到MCU反馈的数据包总长度
    if(recBytes[0]==0x24 && recBytes[1]==0x05 && recBytes[2]==0x02 && recBytes[3]==0x06 && recBytes[4]==0x12){
        int i = (int)recBytes[5];
        int j = (int)recBytes[6];
        int length = (j<<8) + i;            //总共有多少个计步包
        NSLog(@"一共有几个计步包:%d", length);
        _allDataLength = length;
        
        if(length<=16 && length>0)
        {
            [self requestSportsData:0];
            
#warning SVProgressHUD
            if(ApplicationDelegate.isInFunctionVc)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在获取数据", nil) maskType:SVProgressHUDMaskTypeGradient];
                });
            }
        }
        else if(length>16)
        {
            [self readyRequestDownloadSportsData];
//            [self requestSportsData:0];
        }
        else
        {
#warning SVProgressHUD
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            _isFetchingSportData = NO;
        }
        return;
    }
    
    
    if(characteristic.value.length>5)
    {
        //240302130316      拒接来电
        if(recBytes[0]==0x24 && recBytes[1]==0x03 && recBytes[2]==0x02 && recBytes[3]==0x13 && recBytes[4]==0x03 && recBytes[5]==0x16)
        {
            Byte bytes[6] = {0x24,0x03,0x02,0x03,0x03,0x06};
            NSData* data = [NSData dataWithBytes:bytes length:6];
            [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
        }
        else if(_hasReadytoDownloadSportData)
        {
            return;
        }
        
        else
            
            //收到MCU发来的闹钟信息  Byte clock1[12] = {'$', 0x09, 0x02, 0x09, 0x01};
            if(recBytes[0]==0x24 && recBytes[1]==0x09 && recBytes[2]==0x02 && recBytes[3]==0x19 && recBytes[4]==0x02)
            {
                ClockModel* model = [[ClockModel alloc] init];
                int hour = recBytes[5];
                NSString* hourStr = [NSString stringWithFormat:@"%d", hour];
                if(hour<10){
                    hourStr = [@"0" stringByAppendingString:hourStr];
                }
                int min = recBytes[6];
                NSString* minuteStr = [NSString stringWithFormat:@"%d", min];
                if(min<10){
                    minuteStr = [@"0" stringByAppendingString:minuteStr];
                }
                model.clockTime = [[hourStr stringByAppendingString:@":"] stringByAppendingString:minuteStr];
                
                NSMutableString* clockDate = [[NSMutableString alloc] initWithCapacity:10];
                [clockDate appendString:recBytes[7]&0x80 ? NSLocalizedString(@"周日 ", @"") : @""];
                [clockDate appendString:recBytes[7]&0x40 ? NSLocalizedString(@"周一 ", @"") : @""];
                [clockDate appendString:recBytes[7]&0x20 ? NSLocalizedString(@"周二 ", @"") : @""];
                [clockDate appendString:recBytes[7]&0x10 ? NSLocalizedString(@"周三 ", @"") : @""];
                [clockDate appendString:recBytes[7]&0x08 ? NSLocalizedString(@"周四 ", @"") : @""];
                [clockDate appendString:recBytes[7]&0x04 ? NSLocalizedString(@"周五 ", @"") : @""];
                [clockDate appendString:recBytes[7]&0x02 ? NSLocalizedString(@"周六 ", @"") : @""];
                model.clockDate = clockDate;
                model.isClockRepeat = [NSNumber numberWithBool:recBytes[8]];
                NSLog(@"-----mmmmmm----> %@", model.isClockRepeat);
                model.isClockOpen = [NSNumber numberWithBool:recBytes[10]];
                
                int clockIndex = recBytes[9];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshClockData" object:nil userInfo:@{@"clock":model,@"index":[NSNumber numberWithInt:clockIndex]}];
                
            }
    }
}

- (void) fetchSportData
{
    if(_isFetchingSportData)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(90 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_isFetchingSportData==YES){
                _isFetchingSportData = NO;
            }
        });
        return;
    }
    
    if([BLEAppContext shareBleAppContext].isAuthorized == YES && ApplicationDelegate.deviceVer && ![BLEAppContext shareBleAppContext].isInsertingData)
    {
        SportsDataUtil* util = [[SportsDataUtil alloc] init];
        _isFetchingSportData = YES;
        
        [util requestSportsDataLength];
        
    }
    
}


- (void) requestAuthorizedFromWatch:(BOOL)isForbid
{
    //连接后请求手表授权，手腕翻转
    Byte authorize[7] = {'$', 4, 0x02, 0x0A, 0x01, 0x03,0x0e};
    
     //强制授权
    if(isForbid == YES)
    {
        authorize[5] = 0x04;
        authorize[6] = 0x0f;
    }
   
    
    NSData* authorizeData = [NSData dataWithBytes:authorize length:7];
    [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:authorizeData];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
//        if([BLEAppContext shareBleAppContext].isAuthorized == NO)
//        {
//            if(self.peripheral)
//            {
//                [_manager cancelPeripheralConnection:self.peripheral];
//            }
//            [BLEAppContext shareBleAppContext].isSelfDisconnect = YES;
//            return ;
//        }
//    });
}

//运动数据上传准备------->BLE断开修改连接间隔
-(void) readyRequestDownloadSportsData{
    _hasReadytoDownloadSportData = YES;
    Byte bytes[6] = {'$', 0x03, 0x02, 0x06, 0x01, 0x07};
    NSData* data = [NSData dataWithBytes:bytes length:6];
    [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(![BLEAppContext shareBleAppContext].isConnected){
            _hasReadytoDownloadSportData = NO;
        }
    });
}

//请求运动数据包
-(void) requestSportsData:(int)packageIndex{
    Byte low = (Byte)(packageIndex&0xff);
    Byte big =  (Byte)((packageIndex>>8)&0xff);
    Byte checkSum = 0x06 + 0x03 + big + low;
    Byte bytes[8] = {'$', 0x05, 0x02, 0x06, 0x03, low, big, checkSum};
    NSData* data = [NSData dataWithBytes:bytes length:8];
    [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
}

//组装计步数据并插入到数据库
- (void) assemableSportData:(Byte*)recbytes{
    //01 00 00 ff ff 02 00 00 00 00 00 00 00 00 00 00 00 00 00 27
    int i = recbytes[1];
    int j = recbytes[2];
    
    
    int packageIndex = (j<<8) + i;  //包序号
    
#warning 处理收到多个重复的包的bug
    if(packageIndex!=0 && packageIndex==_alreadyReceivedPckIndex)  return;
    _alreadyReceivedPckIndex = packageIndex;
    
    if(packageIndex==0){
        _nearDate = [NSDate date];
       
        NSDate* date = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents* comps = [calendar components:unitFlags fromDate:date];
        NSUInteger minute = 5;
        if(comps.minute%5)
        {
            minute = comps.minute - comps.minute%5;
            comps.minute = minute;
            
            _nearDate = [calendar dateFromComponents:comps];
        }
        NSLog(@"----第一个时间是 %@", _nearDate);
        
    }
    NSLog(@"收到的包序号是:%d", packageIndex);
    
    _recIndex = packageIndex;
    if(_receiveDataTimer)
    {
        if([_receiveDataTimer isValid])
        {
            [_receiveDataTimer invalidate];
        }
        _receiveDataTimer = nil;
    }
    
    int countOfFullPck = 0;
    for(int i=0; i<16; i+=2)
    {
        if(recbytes[3+i]!=0xff && recbytes[4+i]!=0xff)
        {
            countOfFullPck++;
        }
        else
        {
            break;
        }
    }
    
    
    NSDate* tmpDate = _nearDate;
    
    for(int i=0,j=0; i<16; i+=2){
        //异常情况---
        if(recbytes[3]==0xff && recbytes[4]==0xff){                 //1、  开始有空包
            int lengthOfNullPackage = (int)recbytes[5] + ((int)(recbytes[6])<<8);
            
            _nearDate = [_nearDate dateByAddingTimeInterval:-1*lengthOfNullPackage*300];
            ++packageIndex;
            [self requestNexPackage:packageIndex];
            return;
        }
        
        //正常情况----
        int low = (int)(recbytes[4+i]);
        int pck = (int)recbytes[3+i] + (low<<8);
        
        if(i>0){
            if(recbytes[3+i]==0xff && recbytes[4+i]==0xff){         //2、  中间有空包
                int nullPackage = i/2;
                _nearDate = [_nearDate dateByAddingTimeInterval:-1*nullPackage*300];
                ++packageIndex;
                [self requestNexPackage:packageIndex];
                return;
            }
        }
        
        SportModel* model = [[SportModel alloc] init];
        if(_nearDate){
            //            NSDate* date = [tmpDate dateByAddingTimeInterval:-60*5*(7-j)];
            NSDate* date = [tmpDate dateByAddingTimeInterval:-60*5*(countOfFullPck-1-j)];
            
            NSString* dateStr = [_dateFormatter stringFromDate:date];
            model.sportTime = [dateStr substringToIndex:dateStr.length-3];
        }
        model.sportData = pck;
        NSLog(@"---计步时间---> %@", model.sportTime);
        @synchronized(self.sportModelsBuffer) {
            if([BLEAppContext shareBleAppContext].isInsertingData == NO)
            {
                [self.sportModelsBuffer addObject:model];
            }
        }
        
        ++j;
    }
    _nearDate = [_nearDate dateByAddingTimeInterval:-60*5*8];
    
    
    ++packageIndex;
    [self requestNexPackage:packageIndex];
}

- (void) requestNexPackage:(int)packageIndex{
    if(packageIndex<_allDataLength){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            _sendIndex = packageIndex;
            NSLog(@"-df-s-df-a-sdf-a-sfd-a-fa-sd-fa-");
            [self requestSportsData:packageIndex];
            
            int tmp = _recIndex;
            
//            float timeOut = 0.5;
//            if(_allDataLength <= 16)
//            {
//                timeOut = 0.7;
//            }
            
            float timeOut = 1.5;
            if(_allDataLength <= 16)
            {
                timeOut = 2.0;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC)), dispatch_get_global_queue(0,0), ^{
                if(_recIndex == tmp)
                {
                    [self requestSportsData:_sendIndex];
                }
            });
        });
        
        
    }
    
    [BLEAppContext shareBleAppContext].isInsertingData = NO;
    
    //收到的是最后一个包，直接清除数据，最后返回
    if(packageIndex == _allDataLength)
    {
        Byte clear[6] = {'$', 0x03, 0x02, 0x03, 0x05, 0x08};
        NSData* clearData = [NSData dataWithBytes:clear length:6];
        
        [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:[NSData dataWithBytes:clear length:6]];
        
        @synchronized(self.sportModelsBuffer) {
            for(SportModel* model in self.sportModelsBuffer)
            {
                [BLEAppContext shareBleAppContext].isInsertingData = YES;
                [_singleton insertData:model withUUID:self.currentUUIDString];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InsertDataCompletion" object:nil];
            [BLEAppContext shareBleAppContext].isInsertingData = NO;
        }
        
        if(self.sportModelsBuffer.count != 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadFootDataCompletion" object:nil];
        }
        
        //如果上传了，则清除数据
        [self.sportModelsBuffer removeAllObjects];
        
        _hasReadytoDownloadSportData = NO;      //传输完成，标志位置为NO
        
//        [self writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:clearData];
        
        _isFetchingSportData = NO;
        
        _allDataLength = 0;
        
#warning SVProgressHUD
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self.delegate JGBLEManager:self didWriteValue:characteristic.value forDeviceUUID:peripheral serviceUUID:[characteristic serverUUID] characteristicUUID:characteristic.UUID error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self.delegate JGBLEManager:self didRegistUpdateNotifyForDeviceUUID:peripheral serviceUUID:[characteristic serverUUID] characteristicUUID:characteristic.UUID error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // not used currently
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    // not used currently
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    // not used currently
}

/*!
 *  @method setCheckSumType:
 *
 *  @discussion Method to set the checksum calculation type
 *
 */
-(void) setCheckSumType:(NSString *) type
{
    checkSumType = type;
}

@end