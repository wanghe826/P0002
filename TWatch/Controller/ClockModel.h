//
//  ClockModel.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/13.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

//这个我现在还不知道是干啥的。
//NSCoding就是为了加解密而生的协议。
@interface ClockModel : NSObject<NSCoding>
@property (nonatomic, copy) NSString* clockTime;
@property (nonatomic, strong) NSMutableString* clockDate;
@property (nonatomic, strong) NSNumber* isClockOpen;
@property (nonatomic, strong) NSNumber* isClockRepeat;
@end
