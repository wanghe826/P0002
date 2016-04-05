/*
 * Copyright Cypress Semiconductor Corporation, 2015 All rights reserved.
 *
 * This software, associated documentation and materials ("Software") is
 * owned by Cypress Semiconductor Corporation ("Cypress") and is
 * protected by and subject to worldwide patent protection (UnitedStates and foreign), United States copyright laws and international
 * treaty provisions. Therefore, unless otherwise specified in a separate license agreement between you and Cypress, this Software
 * must be treated like any other copyrighted material. Reproduction,
 * modification, translation, compilation, or representation of this
 * Software in any other form (e.g., paper, magnetic, optical, silicon)
 * is prohibited without Cypress's express written permission.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY
 * KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
 * NONINFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes
 * to the Software without notice. Cypress does not assume any liability
 * arising out of the application or use of Software or any product or
 * circuit described in the Software. Cypress does not authorize its
 * products for use as critical components in any products where a
 * malfunction or failure may reasonably be expected to result in
 * significant injury or death ("High Risk Product"). By including
 * Cypress's product in a High Risk Product, the manufacturer of such
 * system or application assumes all risk of such use and in doing so
 * indemnifies Cypress against all liability.
 *
 * Use of this Software may be limited by and subject to the applicable
 * Cypress software license agreement.
 *
 *
 */
#import "Masonry.h"

#import <QuartzCore/QuartzCore.h>
#import "FirmwareUpgradeHomeViewController.h"
#import "Utilities.h"
#import "JGBLEManager.h"
#import "BLEAppContext.h"
#import "SVProgressHUD.h"
#import "LineProgressView.h"

#import "FirmwareFileDownloadUtils.h"

#import "KKProgressTimer.h"

#define BACK_BUTTON_ALERT_TAG  200

#define UPGRADE_RESUME_ALERT_TAG 201
#define UPGRADE_STOP_ALERT_TAG  202

#define APP_UPGRADE_BTN_TAG 203
#define APP_STACK_UPGRADE_COMBINED_BTN_TAG  204
#define APP_STACK_UPGRADE_SEPARATE_BTN_TAG  205

#define OTA_COMPLETION 291
#define OTA_FILE_NOT_EXIST 309
#define OTA_EXIT 333

#define MAX_DATA_SIZE   133

#define FIRMWARE_UPGRADE @"OTA Firmware Upgrade"

/*!
 *  @class FirmwareUpgradeHomeViewController
 *
 *  @discussion Class to handle user interaction, UI update and firmware upgrade
 *
 */

@interface FirmwareUpgradeHomeViewController () <UIAlertViewDelegate, JGBLEManagerDelegate>
{
    //Constraint Outlets for modifying UI for screen fit
    NSLayoutConstraint * statusLabelTopSpaceConstraint;
    NSLayoutConstraint * progressLabel1TopSpaceConstraint;
    NSLayoutConstraint * progressLabel2TopSpaceConstraint;
    
    NSLayoutConstraint * firmwareUpgradeProgressLabel1TrailingSpaceConstraint;
    NSLayoutConstraint * firmwareUpgradeProgressLabel2TrailingSpaceConstraint;
    
    BOOL isBootLoaderCharacteristicFound, isWritingFile1;
    NSMutableArray *currentRowDataArray;
    
    NSDictionary *fileHeaderDictionary;
    NSString *currentArrayID;
    int fileWritingProgress;
    
    NSTimer *timer;
    CGFloat progress;
    CAShapeLayer * layer;
    UIImageView * clockView;        //表盘视图
    NSTimer* _timer;
    
    
    JGBLEManager* _bleManager;
    NSFileHandle* _fileInHandle;     //读
    
    BOOL _isMCURequestLength;       // MCU请求程序长度
    BOOL _isMCURequestSeek;         // MCU请求偏移地址
    BOOL _isMCUUpgradeCompletion;   // MCU传输完成
    long _fileSeek;                  // MCU请求的文件偏移量
    
    long _fileLength;                // bin文件的总长度
    
    long _alreadTransfer;            //已经传送的数据
    
    NSTimer* _transferTimer;        //数据传输定时器
    
    KKProgressTimer* _progressTimer;     //界面的进度条
    
    BOOL _isUpgradeSuccess;             //升级是否成功
    
    BOOL _recMcuCheckfileAck;           //是否收到了MCU的checkFile确认
    
    int _heartCount;                    //检测超时
    int _disconnectedCount;             //断开次数
}

@property(nonatomic,strong) UIButton * startStopUpgradeBtn;

@property(nonatomic,strong) UILabel * currentOperationLabel;
@property(nonatomic,strong) UILabel * firmwareFile1NameLabel;
@property(nonatomic,strong) UILabel * firmwareFile2NameLabel;
@property(nonatomic,strong) UILabel * firmwareFile1UpgradePercentageLabel;
@property(nonatomic,strong) UILabel * firmwareFile2UpgradePercentageLabel;

@property(nonatomic,strong) UIView * firmwareFile1NameContainerView;
@property(nonatomic,strong) UIView * firmwareFile2NameContainerView;
//创建全局属性的ShapeLayer
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer1;

@end

@implementation FirmwareUpgradeHomeViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _beginTransfer = NO;
    
    _disconnectedCount = 0;
    _recMcuCheckfileAck = NO;
    
    _bleManager = [JGBLEManager sharedManager];
    _bleManager.delegate = self;
    
    _isMCURequestLength = NO;
    _isMCURequestSeek = NO;
    _isMCUUpgradeCompletion = NO;
    
    //升级是否成功
    _isUpgradeSuccess = NO;
    
    self.title = NSLocalizedString(@"OTA升级", nil);
    [self initNavigationBarView];
    [self initiateView];
    //    [self initServiceModel];
    
    isWritingFile1 = YES;

    [self drawCircularProgress];
    _heartCount = 0;
    
}
-(void)drawCircularProgress
{
    float scale = (float)25/32;
    if(screen_height == 480){
        scale = 0.65;
    }
    float scaleX = 0.4;
    if(screen_height == 480){
        scaleX = 0.3;
    }
    
    //创建出CAShapeLayer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = CGRectMake(0, 0, (screen_width - 35) * scale, (screen_width - 35) * scale);//设置shapeLayer的尺寸和位置
    //    self.shapeLayer.position = self.view.center;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    self.shapeLayer.strokeColor = HexRGBAlpha(0xEF3D3F, 0.5).CGColor;
    
    //创建出CAShapeLayer
    self.shapeLayer1 = [CAShapeLayer layer];
    self.shapeLayer1.frame = CGRectMake(0, 0, (screen_width - 35) * scale, (screen_width - 35) * scale);//设置shapeLayer的尺寸和位置
    //    self.shapeLayer.position = self.view.center;
    self.shapeLayer1.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    self.shapeLayer1.strokeColor = HexRGBAlpha(0xEF3D3F, 0.9).CGColor;
    
    UIBezierPath *circlePath;
    if (screen_height == 480) {
        self.shapeLayer.lineWidth = 12.0f;
        self.shapeLayer1.lineWidth = 12.0f;
        circlePath = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:(screen_width - 32) * scale / 2.0 startAngle:-M_PI * 0.5 endAngle:M_PI * 1.5 clockwise:YES];
    } else if (screen_height == 568) {
        self.shapeLayer.lineWidth = 15.0f;
        self.shapeLayer1.lineWidth = 15.0f;
        circlePath = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:(screen_width - 32) * scale / 2.0 startAngle:-M_PI * 0.5 endAngle:M_PI * 1.5 clockwise:YES];
    } else if (screen_height == 667) {
        self.shapeLayer.lineWidth = 17.0f;
        self.shapeLayer1.lineWidth = 17.0f;
        circlePath = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:(screen_width - 37) * scale / 2.0 startAngle:-M_PI * 0.5 endAngle:M_PI * 1.5 clockwise:YES];
    } else if (screen_height == 736) {
        self.shapeLayer.lineWidth = 19.0f;
        self.shapeLayer1.lineWidth = 19.0f;
        circlePath = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:(screen_width - 40) * scale / 2.0 startAngle:-M_PI * 0.5 endAngle:M_PI * 1.5 clockwise:YES];
    } else {
        
    }
    
    //    self.shapeLayer.transform = CATransform3DMakeRotation(-M_PI * 0.5, 0, 0, 0);
    
    //创建出圆形贝塞尔曲线
    //    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, (screen_width - 31) * scale, (screen_width - 31) * scale)];
    
    
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = circlePath.CGPath;
    self.shapeLayer1.path = circlePath.CGPath;
    
    //添加并显示
    [self.view.layer addSublayer:self.shapeLayer1];
    [self.view.layer addSublayer:self.shapeLayer];
    
    //设置stroke起始点
    self.shapeLayer1.strokeStart = 0;
    self.shapeLayer1.strokeEnd = 0.005;
    
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0.0001;
    
    //    CABasicAnimation
}

- (void)circleAnimationTypeOne:(float)rate
{
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = rate;
    
    self.shapeLayer1.strokeStart = 1 * rate - 0.005;
    self.shapeLayer1.strokeEnd = 1 * rate;
    
    NSLog(@"%lf", self.shapeLayer.strokeEnd);
    
    ((UILabel *)[self.view viewWithTag:3542]).text = [NSString stringWithFormat:@"%.0lf%@", rate * 100, @"%"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBarView
{
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    [btnBack setImage:[UIImage imageNamed:@"navagation_back_nor"] forState:UIControlStateNormal];
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    
    self.navigationController.navigationBar.barTintColor = RGBColor(105, 168, 241);
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ApplicationDelegate.isOnFirmwareUpgrade = YES;
    [self sendCheckFile];       //发送checkFile信息
    [self performSelector:@selector(upgradeTimeout) withObject:nil afterDelay:900.0f];
}


- (void)sendCheckFile{
    NSString* checkFilePath = ApplicationDelegate.upgradeChkFileName;
    
    NSFileHandle* fileHander = nil;
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"读取文件失败" message:@"是否退出?" delegate:self cancelButtonTitle:NSLocalizedString(@"确定",@"") otherButtonTitles:NSLocalizedString(@"取消",@""), nil];
    alertView.tag = OTA_FILE_NOT_EXIST;
    
    if([fileManager fileExistsAtPath:checkFilePath])
    {
        fileHander = [NSFileHandle fileHandleForReadingAtPath:checkFilePath];
        if(fileHander==nil)
        {
            NSLog(@"读取文件失败");
            [alertView show];
            return ;
        }
        NSData* data = [fileHander readDataToEndOfFile];
        if(data==nil)
        {
            NSLog(@"读取文件失败!");
            [alertView show];
            return ;
        }
        Byte* byte = (Byte*)[data bytes];
        if(data.length==2){
            Byte byte1 = byte[0];
            Byte byte2 = byte[1];
            Byte checkSum =  0x0b + byte1 + byte2;
            Byte sendData[7] = {'$', 0x04, 0x02, 0x0b, byte1, byte2, checkSum};
            __block NSData* checkData = [NSData dataWithBytes:sendData length:7];
            
            
            void (^sendFunc)() = ^(){
                [_bleManager writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:checkData];
            };
            sendFunc();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(!_recMcuCheckfileAck){
                    sendFunc();
                }
            });
        }
    }else{
        [alertView show];
    }
    
}


//新增加的（关于MCU修改蓝牙连接间隔）
- (void) tellMcuDisconnectBle
{
//    [SVProgressHUD showInfoWithStatus:@"Ready to OTA..."];
    Byte command[6] = {'$', 0x03, 0x02, 0x07, 0x02, 0x09};
    NSData* commandData = [NSData dataWithBytes:command length:6];
    [_bleManager writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:commandData];
}

- (void) upgradeTimeout
{
    if(!_isUpgradeSuccess && ApplicationDelegate.isOnFirmwareUpgrade)
    {
        [self upgradeFailure];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ApplicationDelegate.isOnFirmwareUpgrade = NO;
}

- (void) processW07OTA
{
    Byte readyCommand[6] = {'$', 0x03, 0x02, 0x07, 0x01, 0x08};
    NSData* readyData = [NSData dataWithBytes:readyCommand length:6];
    [_bleManager writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:readyData];
    for(int i=0; i<3; ++i){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if(_isMCURequestLength){
                return ;
            }
            if(!_isMCURequestLength && (i==2)){
                [self upgradeFailure];
                return ;
            }
            if(!_isMCURequestLength)
            {
                Byte readyCommand[6] = {'$', 0x03, 0x02, 0x07, 0x01, 0x08};
                NSData* readyData = [NSData dataWithBytes:readyCommand length:6];
                [_bleManager writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:readyData];
            }
            
        });
    }
}

- (void)tellMcuTheFileLength
{
    long lengthOfBin = (long)[self fileLength];
    UInt8 checkSum = (Byte)lengthOfBin+(Byte)(lengthOfBin>>8)+(Byte)(lengthOfBin>>16)+(Byte)(lengthOfBin>>24) + 0x03 + 0x17;
    Byte feedbackLength[10] = {'$', 0x07, 0x02, 0x17, 0x03,(Byte)lengthOfBin, (Byte)(lengthOfBin>>8), (Byte)(lengthOfBin>>16),
        (Byte)(lengthOfBin>>24), checkSum};
    NSData* data = [NSData dataWithBytes:feedbackLength length:10];
    [_bleManager writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
    [self performSelector:@selector(readyTransferBinFile) withObject:nil afterDelay:2.0f];
}

- (void)readyTransferBinFile
{
    if(!_isMCURequestSeek)
    {
        [self upgradeFailure];
    }
}

- (void)startTransferBinFile
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //    while (!_isUpgradeSuccess) {
        if(_fileSeek==0){
            [SVProgressHUD dismiss];
        }
        
        if(_fileSeek > _fileLength){
            return ;
        }
        
        [_fileInHandle seekToFileOffset:_fileSeek];
        
        Byte allbyte[20] = {};
        int index = (int)(_fileSeek/16);
        allbyte[0] = (Byte)index;
        allbyte[1] = (Byte)(index>>8);
        
        if((_fileSeek+16)>_fileLength){            //快到文件尾部
            
            NSData* fileDataReadyToWrite = [_fileInHandle readDataToEndOfFile];
            Byte* fileByte = (Byte*)([fileDataReadyToWrite bytes]);
            for(int i=0; i<fileDataReadyToWrite.length; ++i)
            {
                allbyte[i+2] = fileByte[i];
            }
            
            for(int i=fileDataReadyToWrite.length; i<16; ++i)
            {
                allbyte[i+2] = 0x00;
            }
            
        }else{
            NSData* fileDataReadyToWrite = [_fileInHandle readDataOfLength:16];
            Byte* fileByte = (Byte*)([fileDataReadyToWrite bytes]);
            for (int i=0; i<fileDataReadyToWrite.length; ++i)   //还没到文件尾部
            {
                allbyte[i+2] = fileByte[i];
            }
        }
        
        //内容校验
        int checkSum = 0;
        for(int i=0; i<18; ++i)
        {
            checkSum += allbyte[i];
        }
        allbyte[18] = (Byte)checkSum;
        allbyte[19] = (Byte)(checkSum>>8);
        
        NSData* data = [NSData dataWithBytes:allbyte length:20];
        [_bleManager writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:MCU_DATA_CHARACTERISTIC_UUID withData:data];
        NSLog(@"总共多少个字节:%li", _fileLength);
        NSLog(@"已经写了多少个字节:%li", _alreadTransfer);
        
        float percent = (float)_alreadTransfer/ (float)_fileLength;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self circleAnimationTypeOne:percent];
        });
        
    });
}

- (void) upgradeFailure
{
    //    if(_isMCURequestSeek)
    //    {
    //        return;
    //    }
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"升级失败", nil)];
    _bleManager.delegate = ApplicationDelegate;
    if(_transferTimer && [_transferTimer isValid])
    {
        [_transferTimer invalidate];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [ApplicationDelegate.bleMgr retrievePeriphralBySystem];
}

#pragma JGBLeManagerDelegate
- (void) JGBLEManager:(JGBLEManager *)manager didDisconnectPeripheralByUUID:(CBPeripheral *)peripheral error:(NSError *)error
{
    [BLEAppContext shareBleAppContext].isConnected = NO;
    _disconnectedCount = 0;       //记录ota过程中蓝牙断开的次数
    _disconnectedCount++;
    [_bleManager retrievePeriphralBySystem];
    
    //超时20秒退出x
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([BLEAppContext shareBleAppContext].isConnected == NO){
            [self upgradeFailure];
        }
    });
    
}
- (void) JGBLEManager:(JGBLEManager *)manager didDiscoverPeripherals:(JGBleDeviceInfo *)device
{
    
}
- (void) JGBLEManager:(JGBLEManager *)manager didFinishDiscoverServiceAndCharacteristicForDeviceUUID:(CBPeripheral *)peripheral withService:(CBService *)service
{
    for(CBCharacteristic* ch in service.characteristics)
    {
        NSLog(@"OTA过程中的服务是多少----->%@", ch.UUID.UUIDString);
        if([ch.UUID.UUIDString isEqualToString:BLE_DATA_CHARACTERISTIC_UUID.UUIDString])
        {
            [_bleManager requestAuthorizedFromWatch:YES];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self processW07OTA];
//            });
            
            
            
            return;
        }
    }
}
- (void) JGBLEManager:(JGBLEManager *)manager didRegistUpdateNotifyForDeviceUUID:(CBPeripheral *)peripheral serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID error:(NSError *)error
{
    
}
- (void) JGBLEManager:(JGBLEManager *)manager didUpdateRSSI:(NSNumber *)RSSI forDeviceUUID:(CBPeripheral *)peripheral
{
    
}
- (void) JGBLEManager:(JGBLEManager *)manager didUpdateState:(CBCentralManagerState)state
{
    switch (state)
    {
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStatePoweredOff:
        {
            [BLEAppContext shareBleAppContext].isConnected = NO;
            [self upgradeFailure];
            break;
        }
        case CBCentralManagerStateUnauthorized:
            NSLog(@"蓝牙状态处于不允许状态");
            
            break;
        default:
            break;
    }
}
- (void) JGBLEManager:(JGBLEManager *)manager didUpdateValue:(NSData *)value forDeviceUUID:(CBPeripheral *)peripheral serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID error:(NSError *)error processResult:(BOOL *)result withCharacteristic:(CBCharacteristic *)characteristic
{
    if(value==nil)
    {
        return;
    }
    NSLog(@"---OTA收到数据是:%@", value);
    Byte* bytes = (Byte*)[value bytes];
    if(value.length>5)
    {
        //1  收到允许授权
        if(bytes[0]==0x24 && bytes[1]==4 && bytes[2]==0x02 && bytes[3]==0x0a && bytes[4]==0x01 && bytes[5]==0x13)
        {
            [_bleManager requestVersionBatteryAndSyncSwitch];
        }
        
        
        //2  收到版本和电量
        if(bytes[0]==0x24 && bytes[1]==0x0c && bytes[2]==0x02 && bytes[3]==0x1c && bytes[4]==0x01)
        {
            dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
            //同步App开关
            [[NSNotificationCenter defaultCenter] postNotificationName:BLEChangePushSwitchStateNotification object:nil];
            
            //同步勿扰
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), globalQueue, ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:BLENotDisturbNotification object:nil];
            });
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), globalQueue, ^{
                [self processW07OTA];
            });
            
        }
        
        
        //收到MCU的checkSum确认信息
        if(bytes[0]=='$' && bytes[1]==0x04 && bytes[2]==0x02 && bytes[3]==0x1b)
        {
            _recMcuCheckfileAck = YES;
            [self tellMcuDisconnectBle];        //开始ota流程
        }
        
        
        //MCU请求BLE程序数据长度
        if(bytes[0]=='$' && bytes[1]==0x03 && bytes[2]==0x02 && bytes[3]==0x17 && bytes[4]==0x02 && bytes[5]==0x19)
        {
            _isMCURequestLength = YES;
            [self tellMcuTheFileLength];
        }
        //MCU告知APP传送从偏移地址位置开始的数据
        if(bytes[0]=='$' && bytes[1]==0x07 && bytes[2]==0x02 && bytes[3]==0x37 && bytes[4]==0x03)
        {
            _isMCURequestSeek = YES;
            UInt32 seek4 = (UInt32)bytes[8], seek3 = (UInt32)bytes[7], seek2 = (UInt32)bytes[6], seek1 = (UInt32)bytes[5];
            
            UInt32 skLength = (seek4<<24) + (seek3<<16) + (seek2<<8) + seek1;   //MCU反馈的偏移量
            if(skLength==0)
            {
                _fileSeek = 0;
                _beginTransfer = YES;
                [self startTransferBinFile];
            }
            else if (bytes[5]==0xff && bytes[6]==0xff && bytes[7]==0xff && bytes[8]==0xff)
            {
                //不用更改_fileSeek，继续发送
                NSLog(@"----------------------------------心跳包---------------");
                int tmp = ++_heartCount;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(_heartCount == tmp){
                        if(!_isUpgradeSuccess){
                            [self upgradeFailure];
                        }
                    }
                });
                
            }
            else
            {
                NSLog(@"-----------丢包了，重发------%d", skLength);
                _heartCount++;
                _fileSeek = skLength;
                _alreadTransfer = skLength;
                [self startTransferBinFile];
            }
        }
    }
    //收到MCU发过来的升级完成命令
    if(bytes[0]=='$' && bytes[1]==0x03 && bytes[2]==0x02 && bytes[3]==0x47 && bytes[4]==0x01 && bytes[5]==0x48)
    {
        progress = (M_PI+M_PI_2 + 2*M_PI/100);
        JGBLEManager* manager = [JGBLEManager sharedManager];
        manager.delegate = ((AppDelegate*)[UIApplication sharedApplication].delegate);
        
        _isUpgradeSuccess = YES;
        
        [[NSFileManager defaultManager] removeItemAtPath:ApplicationDelegate.upgradeFileName error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:ApplicationDelegate.upgradeChkFileName error:nil];
        
        ApplicationDelegate.upgradeChkFileName = nil;
        ApplicationDelegate.upgradeFileName = nil;

        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OTA升级成功", @"") message:NSLocalizedString(@"点击确定返回上一个页面",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"确定", @""), nil];
        alertView.tag = OTA_COMPLETION;
        [alertView show];
    }
    
}
- (void) JGBLEManager:(JGBLEManager *)manager didWriteValue:(NSData *)value forDeviceUUID:(CBPeripheral *)peripheral serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID error:(NSError *)error
{
    if(!_beginTransfer){
        return;
    }
    
    if(error){
        NSLog(@"OTA写数据失败---> %@", error);
        return;
    }
    
    _fileSeek+=16;
    _alreadTransfer+=16;
    [self startTransferBinFile];
    NSLog(@"ota写数据 %@  长度是多少-->%d,  偏移量是-->%ld", value, value.length, _fileSeek);
}
- (void) JGBLEManagerDidConnectPeripheral:(NSString *)uuid
{
    [BLEAppContext shareBleAppContext].isConnected = YES;
    NSLog(@"OTA过程再次连接成功");
}
- (void) JGBLEManagerDidFailConnectPeripheral
{
    
}
- (void) JGBLEManagerDidFinishScan
{
    
}

#pragma JGBleManager delegate


//获取文件的长度
- (NSUInteger)fileLength
{
    //    NSString* fileString = [ApplicationDelegate.upgradeFileName stringByDeletingLastPathComponent];
    //    NSString* firmwareFilePath = [[NSBundle mainBundle] pathForResource:fileString ofType:@"bin"];
    NSString* firmwareFilePath = ApplicationDelegate.upgradeFileName;
    _fileInHandle = nil;
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:firmwareFilePath])
    {
        _fileInHandle = [NSFileHandle fileHandleForReadingAtPath:firmwareFilePath];
        if(_fileInHandle==nil)
        {
            NSLog(@"读取文件失败");
            return 0;
        }
        NSData* data = [_fileInHandle readDataToEndOfFile];
        if(data==nil)
        {
            NSLog(@"读取文件失败!");
            return 0;
        }
        _fileLength = (int)data.length;
        return data.length;
    }
    return 0;
}
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // removing the custom back button
    if (self.navigationItem.leftBarButtonItem != nil)
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (UILabel *)currentOperationLabel
{
    if (_currentOperationLabel == nil) {
        _currentOperationLabel = [[UILabel alloc]init];
        _currentOperationLabel.frame = CGRectMake(0, 120, screen_width, 20);
        _currentOperationLabel.backgroundColor = [UIColor orangeColor];
    }
    return _currentOperationLabel;
}

- (UILabel *)firmwareFile1NameLabel
{
    if (_firmwareFile1NameLabel == nil) {
        _firmwareFile1NameLabel = [[UILabel alloc]init];
        _firmwareFile1NameLabel.frame = CGRectMake(0, 120, screen_width, 20);
        _firmwareFile1NameLabel.backgroundColor = [UIColor orangeColor];
    }
    return _firmwareFile1NameLabel;
}

- (UIButton *)startStopUpgradeBtn
{
    if (_startStopUpgradeBtn == nil) {
        _startStopUpgradeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _startStopUpgradeBtn.frame = CGRectMake(0, 0, 80, 30);
        _startStopUpgradeBtn.center = CGPointMake(screen_width / 2, 160);
        //        [_startStopUpgradeBtn setTitle:@"update" forState:UIControlStateNormal];
        [_startStopUpgradeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [_startStopUpgradeBtn addTarget:self action:@selector(startStopBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startStopUpgradeBtn;
}

/*!
 *  @method initiateView
 *
 *  @discussion Method - Setting the view initially or resets it into inital mode when required.
 *
 */


- (void) initiateView
{
    float scale = (float)25/32;
    if(screen_height == 480){
        scale = 0.65;
    }
    float scaleX = 0.4;
    if(screen_height == 480){
        scaleX = 0.3;
    }
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*scaleX, self.view.frame.size.height*0.8)];
    backgroundView.image = [UIImage imageNamed:@"slect_dr_bg"];
    backgroundView.center = CGPointMake(self.view.center.x, (self.view.frame.size.height+20)/2);
    [self.view addSubview:backgroundView];
    clockView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_update_bg"]];
    clockView.frame = CGRectMake(0, 0, screen_width * scale, screen_width * scale);
    clockView.center = self.view.center;
    [self.view addSubview:clockView];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(screen_width / 2.0 - 50, screen_height / 2.0 - 50, 100, 100)];
    label.tag = 3542;
    label.textColor = HexRGBAlpha(0xFDFDFD, 1.0);
    label.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:label];
    label.text = @"0%";
    label.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.startStopUpgradeBtn];
    [_startStopUpgradeBtn setSelected:NO];
    [_firmwareFile1NameContainerView setHidden:YES];
    [_firmwareFile2NameContainerView setHidden:YES];
    [_currentOperationLabel setHidden:YES];
    [_firmwareFile1UpgradePercentageLabel setHidden:YES];
    [_firmwareFile2UpgradePercentageLabel setHidden:YES];
    firmwareUpgradeProgressLabel1TrailingSpaceConstraint.constant = _firmwareFile1NameContainerView.frame.size.width;
    firmwareUpgradeProgressLabel2TrailingSpaceConstraint.constant = _firmwareFile2NameContainerView.frame.size.width;
    
    if (self.view.frame.size.height <= 480) {
        statusLabelTopSpaceConstraint.constant = 15;
        progressLabel2TopSpaceConstraint.constant = 10;
        [self.view layoutIfNeeded];
    }
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedString(@"正在升级华唛手表固件", @"");
    [titleLabel setFont:[UIFont systemFontOfSize:17]];
    titleLabel.center = CGPointMake(self.view.center.x, 80);
    [self.view addSubview:titleLabel];
    
    UILabel* titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 280, 40)];
    titleLabel1.textAlignment = NSTextAlignmentCenter;
    titleLabel1.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    titleLabel1.text = NSLocalizedString(@"请确保手表与手机蓝牙保持连接", @"");
    [titleLabel1 setFont:[UIFont systemFontOfSize:12]];
    titleLabel1.center = CGPointMake(self.view.center.x, 110);
    [self.view addSubview:titleLabel1];
    
//    UILabel* hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
//    [hintLabel setFont:[UIFont systemFontOfSize:14]];
//    hintLabel.textColor = [UIColor whiteColor];
//    hintLabel.textAlignment = NSTextAlignmentCenter;
//    hintLabel.text = NSLocalizedString(@"稍后再试", @"");
//    hintLabel.center = CGPointMake(self.view.center.x, self.view.frame.size.height-110);
//    [self.view addSubview:hintLabel];
//    hintLabel.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBack:)];
//    [hintLabel addGestureRecognizer:tapBack];

    UIButton *btnWaiting = [UIButton buttonWithType:UIButtonTypeSystem];
    btnWaiting.frame = CGRectMake(0, 0, 200, 50);
    btnWaiting.center = CGPointMake(self.view.center.x, self.view.frame.size.height-110);
    [btnWaiting setTitle:NSLocalizedString(@"暂不升级", nil) forState:UIControlStateNormal];
    [btnWaiting setTitleColor:HexRGBAlpha(0xFDFDFD, 1) forState:UIControlStateNormal];
    [self.view addSubview:btnWaiting];
    [btnWaiting addTarget:self action:@selector(waitTimeBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIImageView* logoIv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, clockView.frame.size.width/3, 231/189*(clockView.frame.size.height/3))];
    logoIv.image = [UIImage imageNamed:@"bottom_logo"];
    logoIv.center = CGPointMake(self.view.center.x, self.view.frame.size.height-50);
    [self.view addSubview:logoIv];
}
/**
 *  ’稍后再试‘手势
 */
- (void)waitTimeBtn:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"下次将重新开始，是否取消升级", nil)    message:nil delegate:self cancelButtonTitle: NSLocalizedString(@"是", nil)  otherButtonTitles:NSLocalizedString(@"否", nil) , nil];
    alertView.tag = OTA_EXIT;
    [alertView show];

}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == OTA_EXIT)
    {
        if(buttonIndex == 0)
        {
            _bleManager.delegate = ApplicationDelegate;
            [_bleManager cancelDeviceConnect];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    if(alertView.tag == OTA_COMPLETION)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

