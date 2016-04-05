//
//  JGBLEManager1.m
//  JGBLELib
//
//  Created by zhang yi on 13-7-16.
//  Copyright (c) 2013年 zhang yi. All rights reserved.
//

#import "JGBLEManager+Simple.h"
#import "UserDefaultsUtils.h"
#import "Constants.h"

@implementation JGBLEManager (Simple)

@end

@implementation CBUUID (intInit)

+ (CBUUID*)UUIDWithUInt16:(UInt16)num
{
    UInt16 temp = num << 8;
    temp |= (num >> 8);
    NSData *data = [[NSData alloc] initWithBytes:(char *)&temp length:2];
    CBUUID* uuid = [CBUUID UUIDWithData:data];
    
    return uuid;
}

- (BOOL)isEqualToCBUUID:(CBUUID*)UUID
{
    return [self.data isEqualToData:UUID.data];
}

@end

@implementation NSData (BLEEvent)

UInt8 timeParamConvert(UInt8 param)
{
    UInt8 convertedParam = 0;
    convertedParam = ((param / 10) << 4) + param % 10;
    return convertedParam;
}

+(NSData*) toQueryPower{
//    byte[] bytes = { 0x03, 0x0E, 0x11 };
//    this.toWriteByF1(bytes);
    
    UInt8 bytes[3] = {0x03, 0x0E, 0x11};
    NSData* data = [NSData dataWithBytes:bytes length:3];
    return data;
}

//勿扰模式
+ (NSData*)BLENotiflyType:(BOOL) type startTime:(NSDate*)startTime endTime:(NSDate*)endDate
{
    UInt8 int0 = 0x24;
    UInt8 int1=0x08;
    UInt8 int2=0x02;
    UInt8 contentType = 0x04;
    
    UInt8 flag = 0x02;
    if(type)
    {
        flag = 0x01;
    }
    
    UInt8 int3,int4,int6,int7;
    if (type) {
        NSCalendar* calendar=[ NSCalendar currentCalendar];
        
        NSCalendarUnit unit=NSCalendarUnitHour |NSCalendarUnitMinute |NSCalendarUnitSecond;
        
        NSDateComponents *components = [calendar
                                        components:
                                        unit
                                        fromDate:startTime];
        int3=[components hour];
        int4=[components minute];
        
        components = [calendar
                      components:
                      unit
                      fromDate:endDate];
        
        int6=[components hour];
        int7=[components minute];
        
    }else{
        int3=0x00;
        int4=0x00;

        int6 = 0x00;
        int7 = 0x00;
    }
    
    //华唛勿扰模式增加
    int3 = 0x00;
    int4 = 0x01;
    int6 = 0x00;
    int7 = 0x00;
    
    UInt8 int9 = (0x04 + 0x03 + int3 + int4 + int6 + int7 + flag) & 0xFF;        //w07校验和
    
    UInt8 dataBuf[11] = {int0, int1, int2,contentType, 0x03, int3,int4,int6,int7, flag,int9};
    NSData* data = [NSData dataWithBytes:dataBuf length:11];
    
    NSLog(@"ttttttttttt =%@",data);
    
    return data;
}

//App提醒
+ (NSData*)BLEAppType  //设置手机和app提醒开关
{
    /*
     w07
     0 ：QQ0001
     1 ：微信0002
     2 ：腾讯微博0004
     3 ：Skype0008
     4 ：新浪微博0010
     5 ：Facebook0020
     6 ：Twitter0040
     7 ：What Sapp0080
     8 ：Line0100            ---->华唛改为陌陌
     9 ：其他0200
     10：电话0400
     11：短信0800
     12：未接来电1000
     13：日历事件2000
     14：Reserved
     15：其他
     
     */
    
    
    UInt8 int0 = 0x24;
    UInt8 int1=0x05;
    UInt8 int2=0x02;
    
    UInt8 call=0;
    UInt8 sms=0;
    UInt8 weibo=0;
    UInt8 skype=0;
    UInt8 weichar=0;
    UInt8 tentweibo=0;
    UInt8 line=0;
    UInt8 qq=0;
    
    UInt8 fackBook=0;
    UInt8 twitter=0;
    UInt8 whatsapp=0;
    UInt8 other=0;
    
    UInt8 missedCall = 0;
    UInt8 calentEvent = 0;
    UInt8 reserved = 0;
    UInt8 otherother = 0;
    
    UInt8 momo = 0;
    
    if([UserDefaultsUtils boolValueWithKey:QQRemindStatus]){            // QQ
        qq = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:WeixinRemindStatus]){        //微信
        weichar = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:WeiboRemindStatus]){         //腾讯微博
        tentweibo = 1;
    }
    
    if([UserDefaultsUtils boolValueWithKey:SkypeRemindStatus]){         //Skype
        skype = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:SinaWeiboRemindStatus]){     //新浪微博
        weibo = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:FacebookRemindStatus]){      //Facebook
        fackBook = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:TwitterRemindStatus]){       //Twitter
        twitter = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:WhatsappRemindStatus]){      //whatsapp
        whatsapp = 1;
    }
    
    if([UserDefaultsUtils boolValueWithKey:LineRemindStatus]){          //Line
        line = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:OtherRemindStatus]){         //Other
        other = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:CallRemindSwitch]){          //电话提醒
        call = 1;
    }
    if([UserDefaultsUtils boolValueWithKey:MsgRemindSwitch]){           //短信提醒
        sms = 1;
    }
    
    if([UserDefaultsUtils boolValueWithKey:CallRemindSwitch]){          //未接来电
        missedCall = 1;
    }
    
    if([UserDefaultsUtils boolValueWithKey:CalenderStatus]){            //日历事件
        calentEvent = 1;
    }
    
    if([UserDefaultsUtils boolValueWithKey:ReservedStatus]){            //Reserved
        reserved = 1;
    }
    
    if([UserDefaultsUtils boolValueWithKey:LineRemindStatus])
    {
        momo = 1;
    }
                                                                        //其他
    reserved = 0;
    calentEvent = 1;
    
    UInt8 int5 = (whatsapp<<7) + (twitter<<6) + (fackBook<<5) + (weibo<<4) + (skype<<3) + (tentweibo<<2) + (weichar<<1) + qq;
    UInt8 int6 = (otherother<<7) + (reserved<<6) + (calentEvent<<5) + (missedCall<<4) + (sms<<3) + (call<<2) + (other<<1) + momo;
    
    UInt8 checkSum = 0x03 + 0x06 + int6 + int5;
    UInt8 dataBuf[8] = {int0, int1, int2, 0x03, 0x06, int5, int6, checkSum};
    NSData* data = [NSData dataWithBytes:dataBuf length:8];
    return data;
}






+ (NSData*)BLEWorldTimeWithTime:(NSDate*)date
                       timezone:(char)timezone
                        isDstOn:(BOOL)isDstOn
                           city:(NSString *)cityName

{
    NSData* data = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:
                                    NSDayCalendarUnit |
                                    NSMonthCalendarUnit |
                                    NSYearCalendarUnit |
                                    NSHourCalendarUnit |
                                    NSMinuteCalendarUnit |
                                    kCFCalendarUnitSecond
                                    fromDate:date];
    
    UInt8 day = (UInt8)[components day];
    UInt8 month = (UInt8)[components month];
    UInt8 hour = (UInt8)[components hour] + (isDstOn ? 1 : 0);
    UInt8 min = (UInt8)[components minute];
    UInt8 sec = (UInt8)[components second];
//    UInt8 pYear = (UInt8)timeParamConvert([components year] % 100);
    UInt8 pYear = (UInt8)([components year]%100);

    
    
    NSString* city = cityName;
    int len = city.length > 3 ?3 :city.length;
    UInt8 charCity[3] = {0};
    for (int i = 0; i < len; i++)
    {
        charCity[i] = (UInt8)[city characterAtIndex:i];
    }
    UInt8 timeZone = 0x01;
    UInt8 checkSum = 0x04 + 0x01 +  pYear + month + day + hour + min + sec + timeZone;
    UInt8 buf[13] = {'$', 0x0a, 0x02, 0x04, 0x01, pYear, month, day, hour, min, sec, timeZone, checkSum};
    data = [NSData dataWithBytes:buf length:13];
    return data;
    
}

+ (NSData*)BLESetEventMask:(UInt16)mask {
    UInt8 d1 = (mask >> 8) & 0xF;
    UInt8 d2 = mask & 0xF;
    UInt8 checkSum = 4 + 0xA + d1 + d2;
    UInt8 buf[20] = {'$', 4, 0xA, d1, d2, checkSum};
    NSData *data = [NSData dataWithBytes:buf length:20];
    return data;
}

//是否在拍照界面
+ (NSData*)BLECameraType:(BOOL) type
{
    NSData* data;
    /*
    if (type) {
        UInt8  dataBuf[] ={0x03,0x0f,0x12};
        data = [NSData dataWithBytes:dataBuf length:3];
    }else{
        UInt8 dataBuf[] = {0x03,0x10,0x13};
        data = [NSData dataWithBytes:dataBuf length:3];
    }*/
    
    if(type)
    {
        UInt8 dataBuf[] = {0x24, 0x04, 0x02, 0x03, 0x02, 0x01, 0x06};
        data = [NSData dataWithBytes:dataBuf length:7];
    }
    else
    {
        UInt8 dataBuf[] = {0x24, 0x04, 0x02, 0x03, 0x02, 0x02, 0x07};
        data = [NSData dataWithBytes:dataBuf length:7];
    }
    
    return data;
}

//+ (NSData*)sendSitToWatch(Date startTime, Date endTime, int sitTime) {
+(NSData*)sendSitToWatch:(NSDate*)startTime withEndTime:(NSDate*)endTime withSitTime:(int)sitTime withFlag:(BOOL)flag
{
    sitTime = sitTime * 60;
    
    UInt8 bytes[18];
    bytes[0] = 0x24;
    bytes[1] = 0x10;
    bytes[2] = 0x02;

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh"];
    int startHour = [[NSString stringWithFormat:@"%@",[formatter stringFromDate:startTime]] intValue];
    NSLog(@"--->startHourString %d", startHour);
    
    [formatter setDateFormat:@"mm"];
    int startMM = [[NSString stringWithFormat:@"%@",[formatter stringFromDate:startTime]] intValue];
    
    bytes[3] = 0x04;
    bytes[4] = 0x02;
    bytes[5] = (UInt8) startHour;// h
    bytes[6] = (UInt8) startMM;// m
    
    [formatter setDateFormat:@"hh"];
    int endHour = [[NSString stringWithFormat:@"%@",[formatter stringFromDate:endTime]] intValue];
    [formatter setDateFormat:@"mm"];
    int endMM = [[NSString stringWithFormat:@"%@",[formatter stringFromDate:endTime]] intValue];

    bytes[7] = (UInt8)endHour;// h
    bytes[8] = (UInt8)endMM;// m
    // 久坐时间阀值
    bytes[9] = (UInt8) (sitTime >> 8);
    bytes[10] = (UInt8) sitTime;
    bytes[11] = 0x02;
    if(flag)
    {
        bytes[11] = 0x01;
    }
    
    
    UInt8 tempFlag = 0x04;
    
    for (int i = 4; i < 12; i++) {
        tempFlag = (UInt8) ((tempFlag + bytes[i]) & 0xFF);
    }
    bytes[12] = tempFlag;
    
    
    return [NSData dataWithBytes:bytes length:12];
}
+(NSData*)toChangeSomeType:(BOOL)sportType motor:(BOOL)motorType type:(BOOL)sitType
{
    UInt8 dataArrar[3] = {};
    
    dataArrar[0] = 0x11;
    dataArrar[1] = (((sitType ? 1 : 0) << 3) + (1 << 2)
                    + ((motorType ? 1 : 0) << 1) + (sportType ? 1 : 0));// 久坐
    dataArrar[2] = (UInt8)((dataArrar[0] + dataArrar[1]) & 0xFF);
    return [NSData dataWithBytes:dataArrar length:3];
}

+ (NSData *)BLEAdjustTimeWithObj:(NSArray *)time{
    UInt8 hour = (UInt8)[time[0] intValue];
    UInt8 minute = (UInt8)[time[1] intValue];
    UInt8 second = (UInt8)[time[2] intValue];
    UInt8 checkSum = hour + minute + second + 0x03 + 0x05;
    UInt8 buf[9] = {'$', 0x06, 0x02, 0x05, 0x03, hour,minute,second,checkSum};
    NSData* data = [NSData dataWithBytes:buf length:9];
    return data;
}

+ (NSData*)BLEACKPedometerDataWithStatus:(BOOL)status
{
    //w07请求上传运动睡眠数据
    UInt8 checkSum = 0x06 + 0x02;
    UInt8 buf[6] = {'$', 0x03, 0x02, 0x06, 0x02, checkSum};//全部计步数据:计步 睡眠
    NSData* data = [NSData dataWithBytes:buf length:6];
    return data;
}

+ (NSData*)BLEACKForbidLostDataWithStatus:(BOOL)status
{
    /*
    UInt8 buf[3] = { 0x03, 0x08, 0x0B };
    if(!status){
        buf[0] = 0x03;
        buf[1] = 0x09;
        buf[2] = 0x0C;
    }
     w05
     */
    
    
    /*
     w07
     $	3	0x02	0x03	"(1 char) 0x01"	0xxx	查找手表	APP--MCU
     */
    UInt8 buf[7];
    if(status)
    {
        buf[0] = 0x24;
        buf[1] = 0x04;
        buf[2] = 0x02;
        buf[3] = 0x03;
        buf[4] = 0x04;
        buf[5] = 0x01;
        buf[6] = 0x08;
    }
    else
    {
        buf[0] = 0x24;
        buf[1] = 0x04;
        buf[2] = 0x02;
        buf[3] = 0x03;
        buf[4] = 0x04;
        buf[5] = 0x02;
        buf[6] = 0x09;
    }
    
    
    NSData* data = [NSData dataWithBytes:buf length:7];
    return data;
}

@end
