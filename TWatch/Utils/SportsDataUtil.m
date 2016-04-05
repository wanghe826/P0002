//
//  SportsDataUtil.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/18.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//


/**
 ## 运动数据上传
 
	运动数据上传准备[APP->MCU]: BLE断开修改连接间隔
 协议: 0x24,3,0x02,0x06,0x01,校验(1)
 
	运动数据长度请求[APP->MCU]:
 协议: 0x24,3,0x02,0x06,0x02,校验(1)
 
	数据长度上传[MCU->APP]:
 协议: 0x24,5,0x02,0x06,0x12,长度(2),校验(1)
 ps. 长度包括缓存，为0，则无缓存
 
	请求数据包[APP->MCU]:
 协议: 0x24,5,0x02,0x06,0x03,序号(2),校验(1)
 
	数据上传[MCU->APP]:
 协议: 0x24,21,0x03,0x26,类型(1),序号(2),数据(16),校验(1)
 类型: 0x00为空包 0x10为数据包
 数据包16byte全为数据(0xFF表示数据终止)
 空包0-1byte为0xFFFF 2-3byte为空包数
 
	(应标记当上传开始时的数据长度)
	第0包为当前缓存，第一节表示缓存长度，其后为数据(<8包)
	第1包为最近的flash存储
 ***/

#import "SportsDataUtil.h"
#import "Constants.h"
#import "SportModel.h"


@implementation SportsDataUtil

- (instancetype)init{
    if(self = [super init]){
        [self initData];
    }
    return self;
}

- (void)initData{
    _manager = [JGBLEManager sharedManager];
//    _manager.delegate = self;
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _singleton = [SMDatabaseSingleton shareInstance];
    _nullPckOffset = 0;
}

//运动数据长度请求
-(void) requestSportsDataLength{
    Byte bytes[6] = {'$', 0x03, 0x02, 0x06, 0x02, 0x08};
    NSData* data = [NSData dataWithBytes:bytes length:6];
    [_manager writeValueToDeviceWithServiceAndCharactersitc:BLE_APP_TOUCHUAN_COMMAND_SERVICE_UUID withChUUID:COMMAND_TOUCHUAN_CHARACTERISTIC_UUID withData:data];
}

@end

