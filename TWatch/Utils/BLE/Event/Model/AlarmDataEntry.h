//
//  AlarmDataEntry.h
//  sportsBracelets
//
//  Created by anerevol on 13-10-5.
//  Copyright (c) 2013年 zhang yi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmDataEntry : NSObject<NSCoding>

@property(copy, nonatomic)NSDate* date;
@property(copy, nonatomic)NSArray* weekdaysArray;
@property(assign, nonatomic)BOOL repeat;
@property(assign, nonatomic)BOOL on;

- (UInt8)getWeekdaysFlag;

@end
