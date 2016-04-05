//
//  PointerView.h
//  TWatch
//
//  Created by Yingbo on 15/7/29.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

typedef enum : NSUInteger {
    kHour = 1,
    kMinute,
    kSecond,
} PointerType;

#import <UIKit/UIKit.h>

@interface PointerView : UIView

@property(nonatomic,assign) NSInteger hour;

@property(nonatomic,assign) NSInteger minute;

@property(nonatomic,assign) NSInteger second;

@property(nonatomic,assign) PointerType type;

@property(nonatomic,assign) BOOL daylightStatus;

@property (nonatomic, copy) void(^changeHourBlock)(NSInteger hour);

@property (nonatomic, copy) void(^changeMinuteBlock)(NSInteger minute);

@property (nonatomic, copy) void(^changeSecondBlock)(NSInteger second);

@property(nonatomic,assign) int currentHour;
@property(nonatomic,assign) int currentMin;
@property(nonatomic,assign) int currentSec;


@end