//
//  CBUUID+ToString.m
//  TWatch
//
//  Created by QFITS－iOS on 15/8/19.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "CBUUID+ToString.h"

@implementation CBUUID (ToString)

- (NSString *)toString {
    if ([self respondsToSelector:@selector(UUIDString)]) {
        return [self UUIDString]; // Available since iOS 7.1
    } else {
//        NSString *str = [[NSString alloc] initWithFormat:@"%@",  CFUUIDCreateString(nil, peripheral.UUID) ];
        return [[[NSUUID alloc] initWithUUIDBytes:[[self data] bytes]] UUIDString]; // iOS 6.0+
    }
}

@end
