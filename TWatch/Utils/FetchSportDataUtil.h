//
//  FetchSportDataUtil.h
//  TWatch
//
//  Created by QFITS－iOS on 15/11/28.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchSportDataUtil : NSObject

+ (NSArray*) fetchOneDaySportData:(NSDate*)date;

+ (NSMutableArray*) fetchAllDaysSportData;

+ (NSMutableArray*) fetchAllWeeksSportData:(NSMutableArray**)array;

+ (NSMutableArray*) fetchAllMonthSportData:(NSMutableArray**)array;
@end
