//
//  NotDisturbRow.m
//  TWatch
//
//  Created by QFITS－iOS on 15/7/31.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "NotDisturbRow.h"

NSString* const XLFormRowDescriptorTypeSwitchDisturb = @"XLFormRowDescriptorTypeSwitchDisturb";

@implementation NotDisturbRow

+(void)load{
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:NSStringFromClass([NotDisturbRow class]) forKey:XLFormRowDescriptorTypeSwitchDisturb];
}

-(void)configure{
    [super configure];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
}

@end
