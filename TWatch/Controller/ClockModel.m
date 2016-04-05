//
//  ClockModel.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/13.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "ClockModel.h"

@implementation ClockModel
//我想这个就是为了传输过程中的安全而考虑的吧。
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.clockDate forKey:@"ClockDate"];
    [aCoder encodeObject:self.clockTime forKey:@"ClockTime"];
    [aCoder encodeObject:self.isClockOpen forKey:@"isClockOpen"];
    [aCoder encodeObject:self.isClockRepeat forKey:@"isClockRepeat"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.clockDate = [aDecoder decodeObjectForKey:@"ClockDate"];
        self.clockTime = [aDecoder decodeObjectForKey:@"ClockTime"];
        self.isClockOpen = [aDecoder decodeObjectForKey:@"isClockOpen"];
        self.isClockRepeat = [aDecoder decodeObjectForKey:@"isClockRepeat"];
    }
    return self;
}
@end
