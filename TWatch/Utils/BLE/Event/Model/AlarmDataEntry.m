//
//  AlarmDataEntry.m
//  sportsBracelets
//
//  Created by anerevol on 13-10-5.
//  Copyright (c) 2013年 zhang yi. All rights reserved.
//

#import "AlarmDataEntry.h"

#define kDate @"date"
#define kOn  @"on"
#define kWeekdaysArray @"weekdaysArray"
#define kRepeat @"repeat"

@implementation AlarmDataEntry

- (void)dealloc
{
    self.date = nil;
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_date forKey:kDate];
    [aCoder encodeBool:_on  forKey:kOn];
    [aCoder encodeObject:_weekdaysArray forKey:kWeekdaysArray];
    [aCoder encodeBool:_repeat forKey:kRepeat];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.date = [aDecoder decodeObjectForKey:kDate];
    self.on = [aDecoder decodeBoolForKey:kOn];
    self.weekdaysArray = [aDecoder decodeObjectForKey:kWeekdaysArray];
    self.repeat = [aDecoder decodeBoolForKey:kRepeat];
    
    return self;
}

- (UInt8)getWeekdaysFlag
{
    UInt8 flag = 0;
    if (self.repeat)
    {
        flag &= 1 << 7;
    }
    
    for (int i = 6; i >= 0; i--)
    {
        NSNumber* value = [_weekdaysArray objectAtIndex:6 - i];
        if (value.boolValue == YES)
        {
            flag |= 1 << i;
        }
    }
    
    return flag;
}

@end
