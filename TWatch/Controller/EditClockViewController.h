//
//  EditClockViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/13.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"
#import "ClockModel.h"

#define XLFORMROW_TAG_ONCE @"tag_once"
#define XLFORMROW_TAG_CLOCK_SWITCH @"tag_clock_switch"
#define XLFORMROW_TAG_CLOCK_TIME @"tag_clock_time"

@interface EditClockViewController : XLFormViewController
@property (nonatomic,strong) void (^editClock) (ClockModel* model);
@property (nonatomic,strong) ClockModel* currentModel;
@property (nonatomic,strong) void (^addClock) (ClockModel* model);
@property (nonatomic,assign) int clockIndex;
@end
