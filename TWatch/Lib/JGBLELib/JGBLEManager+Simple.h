//
//  JGBLEManager1.h
//  JGBLELib
//
//  Created by zhang yi on 13-7-16.
//  Copyright (c) 2013年 zhang yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGBLEManager.h"

@interface JGBLEManager (Simple)

@end

@interface CBUUID (intInit)

+ (CBUUID*)UUIDWithUInt16:(UInt16)num;
- (BOOL)isEqualToCBUUID:(CBUUID*)UUID;

@end

@interface NSData (BLEEvent)

+(NSData*)sendSitToWatch:(NSDate*)startTime withEndTime:(NSDate*)endTime withSitTime:(int)sitTime withFlag:(BOOL)flag;
+(NSData*)toChangeSomeType:(BOOL)sportType motor:(BOOL)motorType type:(BOOL)sitType;

+ (NSData*)BLECameraType:(BOOL) type;
//勿扰模式
+ (NSData*)BLENotiflyType:(BOOL) type startTime:(NSDate*)startTime endTime:(NSDate*)endDate;


//查询电量
+(NSData*) toQueryPower;

+ (NSData*)BLEAppType;



+ (NSData*)BLETimeSyncEventWithTime:(NSDate*)date
                           timezone:(NSTimeZone*)timezone;


+ (NSData*)BLEWorldTimeWithTime:(NSDate*)date
                       timezone:(char)timezone
                        isDstOn:(BOOL)isDstOn
                           city:(NSString *)cityName;

+ (NSData *)BLEAdjustTimeWithObj:(NSArray *)time;

+ (NSData*)BLESetEventMask:(UInt16)mask;

+ (NSData*)BLEACKPedometerDataWithStatus:(BOOL)status;
+ (NSData*)BLEACKForbidLostDataWithStatus:(BOOL)status;

#define SetFlagOn 0x1
#define SetFlagOff 0x2
#define NOFlag 0
+ (NSData*)BLEAlarmEventWithTime:(NSDate*)time
                         setFlag:(UInt8)setFlag
                        weekFlag:(UInt8)weekFlag;


@end