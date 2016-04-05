//
//  FetchSportDataUtil.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/28.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "FetchSportDataUtil.h"
#import "SportModel.h"

@implementation FetchSportDataUtil

+ (NSArray*) fetchOneDaySportData:(NSDate*)date
{
    SMDatabaseSingleton* dbSingleton = [SMDatabaseSingleton shareInstance];
    NSArray* array = [dbSingleton queryOneDayByDate:[NSDate dateWithTimeIntervalSince1970: [date timeIntervalSince1970]]];
    return array;
}


+ (NSMutableArray*) fetchAllDaysSportData
{
    NSMutableArray* retArray = [NSMutableArray array];
    
    SMDatabaseSingleton* dbSingleton = [SMDatabaseSingleton shareInstance];
    NSArray* allDays = [dbSingleton queryAllDays];
    
    NSLog(@"获取天结束");
    if(allDays==nil || allDays.count==0)
    {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* firstDate = [formatter dateFromString:[[[allDays objectAtIndex:0] sportTime] substringWithRange:NSMakeRange(0, 10)]];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlag = NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlag fromDate:firstDate toDate:[NSDate date] options:0];
    
    int days = (int)[components day] + 1;
    for(int i=0; i<days; ++i)
    {
        int oneDayFoot = 0;
        NSString* firstDateString = [formatter stringFromDate:firstDate];
        for (SportModel* model in allDays)
        {
            if([model.sportTime rangeOfString:firstDateString].length != 0)
            {
                oneDayFoot += model.sportData;
            }
        }
        [retArray addObject:@{firstDateString:[NSString stringWithFormat:@"%d",oneDayFoot]}];
        
        firstDate = [firstDate dateByAddingTimeInterval:24*60*60];
    }
    
    NSNumber* lastObject = [[retArray[retArray.count-1] allObjects] firstObject];
    [retArray removeLastObject];
    [retArray addObject:@{NSLocalizedString(@"今天", nil):lastObject}];
    NSLog(@"----ddddd->%@", retArray);
    return retArray;
}


+ (NSMutableArray*) fetchAllWeeksSportData:(NSMutableArray**)average
{
    SMDatabaseSingleton* dbSingleton = [SMDatabaseSingleton shareInstance];
    NSArray* allDays = [dbSingleton queryAllDays];
    if(allDays==nil || allDays.count==0)
    {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    int weekCount = 0;
    int sportData = 0;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSString* firstDateSting = [[[allDays objectAtIndex:0] sportTime] substringWithRange:NSMakeRange(0, 10)];
    
    NSDate* date = [NSDate date];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    
    while (true)
    {
        for (SportModel* model in allDays)
        {
            if([model.sportTime rangeOfString:[formatter stringFromDate:date]].length != 0)
            {
                sportData +=  model.sportData;
            }
        }
        
        
        NSString* weekdays = [FetchSportDataUtil weekdayStringFromDate:date];
        if([weekdays isEqualToString:@"Sunday"])
        {
            [array addObject:@(sportData)];
            weekCount++;
            sportData = 0;
        }
        if([[formatter stringFromDate:date] isEqualToString:firstDateSting])
        {
            //如果第一天是星期天 则直接break；
            if(sportData==0) break;
            
            [array addObject:@(sportData)];
            weekCount = 0;
            break;
        }
        date = [date dateByAddingTimeInterval:-60*60*24];
    }
    
    
    NSLog(@"----所有周的数组是:%@", array);
    NSDate* currentDate = [NSDate date];
    
    NSMutableArray* dicArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        for(int i=0; i<array.count; ++i)
        {
            NSMutableString* dateString = [[NSMutableString alloc] init];
            
            if(i!=0)
            {
                currentDate = [currentDate dateByAddingTimeInterval:-60*60*24];
            }
            
            comps = [calendar components:unitFlags fromDate:currentDate];
            [dateString appendString:[NSString stringWithFormat:@"~%02ld.%02ld", (long)comps.month,(long)comps.day]];
            
            currentDate = [currentDate dateByAddingTimeInterval:-(comps.weekday-1)*60*60*24];
            if([currentDate timeIntervalSinceDate:[formatter dateFromString:firstDateSting]]>0.0)
            {
                comps = [calendar components:unitFlags fromDate:currentDate];
                [dateString insertString:[NSString stringWithFormat:@"%02ld.%02ld", (long)comps.month,(long)comps.day] atIndex:0];
            }
            else
            {
                comps = [calendar components:unitFlags fromDate:[formatter dateFromString:firstDateSting]];
                [dateString insertString:[NSString stringWithFormat:@"%02ld.%02ld", (long)comps.month,(long)comps.day] atIndex:0];
            }
            NSLog(@"----dateString:%@", dateString);
            
            
            
            NSDictionary* dic = @{dateString:[NSString stringWithFormat:@"%d", [array[i] intValue]]};
            [dicArray addObject:dic];
        }
    }
    NSLog(@"数组%@", dicArray);
    *average = [[NSMutableArray alloc] init];
    for(int i=0; i<dicArray.count; ++i)
    {
        NSArray* strArray = [(NSString*)[[dicArray[i] allKeys] objectAtIndex:0] componentsSeparatedByString:@"~"];
        
        comps.month = [[strArray[0] substringWithRange:NSMakeRange(0, 2)] intValue];
        comps.day = [[strArray[0] substringWithRange:NSMakeRange(3, 2)] intValue];
        NSDate* date1 = [calendar dateFromComponents:comps];
        
        NSInteger compsMonth = comps.month;
        
        comps.month = [[strArray[1] substringWithRange:NSMakeRange(0, 2)] intValue];
        comps.day = [[strArray[1] substringWithRange:NSMakeRange(3, 2)] intValue];
        NSDate* date2 = [calendar dateFromComponents:comps];
        
        int days = (int)[date2 timeIntervalSinceDate:date1]/60/60/24;
        if (comps.month == 1 && compsMonth == 12) {
            if (days+1 + 365 > 7) {
                [*average addObject:@(7)];
            } else {
                [*average addObject:@(days+1 + 365)];
            }
        } else {
            [*average addObject:@(days+1)];
        }
    }
    return dicArray;
}


+ (NSMutableArray*) fetchAllMonthSportData:(NSMutableArray**)average
{
    NSMutableArray* retArray = [[NSMutableArray alloc] init];
    
    SMDatabaseSingleton* dbSingleton = [SMDatabaseSingleton shareInstance];
    NSArray* allDays = [dbSingleton queryAllDays];
    if(allDays==nil || allDays.count==0)
    {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString* firstDateSting = [[[allDays objectAtIndex:0] sportTime] substringWithRange:NSMakeRange(0, 10)];
    
    
    NSDate* date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:date];
    
    NSString* monthString = [[formatter stringFromDate:date] substringWithRange:NSMakeRange(0, 7)];
    
    while (true) {
        
        int foot = 0;
        for (SportModel* model in allDays) {
            if([model.sportTime rangeOfString:monthString].length != 0)
            {
                foot+=model.sportData;
            }
        }
        
        NSString* dicKey = [NSString stringWithFormat:@"%@%@", [monthString substringFromIndex:5], NSLocalizedString(@"月", nil)];
        [retArray addObject:@{dicKey:[NSString stringWithFormat:@"%d",foot]}];
        
        if(comps.month==1)
        {
            comps.month = 12;
            comps.year -= 1;
        }
        else
        {
            comps.month = (comps.month - 1);
            comps.day = (comps.day - 1);
            NSLog(@"hmm%ld", comps.month);
        }
        
        date = [calendar dateFromComponents:comps];
        monthString = [[formatter stringFromDate:date] substringWithRange:NSMakeRange(0, 7)];
        NSString* caculateString = [monthString stringByAppendingString:@"-01"];
        if([[formatter dateFromString:caculateString] timeIntervalSinceDate:[formatter dateFromString:firstDateSting]] < 0.0)
        {
            int foot = 0;
            for (SportModel* model in allDays) {
                if([model.sportTime rangeOfString:monthString].length != 0)
                {
                    foot+=model.sportData;
                }
            }
            NSString* dicKey = [NSString stringWithFormat:@"%@月", [monthString substringFromIndex:5]];
            if (foot != 0) {
                [retArray addObject:@{dicKey:[NSString stringWithFormat:@"%d",foot]}];
            }
            break;
        }
        
    }
    
    *average = [NSMutableArray array];
    NSDate* firstDate = [formatter dateFromString:firstDateSting];
    comps = [calendar components:unitFlags fromDate:firstDate];
    
    if(retArray.count==1)
    {
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        //        [*average addObject:@(comps.day)];
        [*average addObject:@((int)[[calendar dateFromComponents:comps] timeIntervalSinceDate:firstDate]/(24*60*60) + 1)];
    }
    else if(retArray.count==2)
    {
        if(comps.month == 12)
        {
            comps.year += 1;
            comps.month = 1;
        }
        else
        {
            comps.month += 1;
        }
        comps.day = 1;
        NSDate* firstEndDate = [calendar dateFromComponents:comps];
        int days = (int)[firstEndDate timeIntervalSinceDate:firstDate]/(24*60*60);
        [*average addObject:@(days)];
        
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [*average addObject:@(comps.day)];
    }
    else
    {
        for(int i=0; i<retArray.count; ++i)
        {
            if(i==0)
            {
                if(comps.month == 12)
                {
                    comps.year += 1;
                    comps.month = 1;
                }
                else
                {
                    comps.month += 1;
                }
                comps.day = 1;
                NSDate* firstEndDate = [calendar dateFromComponents:comps];
                int days = (int)[firstEndDate timeIntervalSinceDate:firstDate]/(24*60*60);
                [*average addObject:@(days - 1)];
            }
            else if (i == (retArray.count-1))
            {
                comps = [calendar components:unitFlags fromDate:[NSDate date]];
                [*average addObject:@(comps.day)];
            }
            else
            {
                if(comps.month>12)
                {
                    comps.year += 1;
                    comps.month = 1;
                }
                
                NSDate* begin = [calendar dateFromComponents:comps];
                
                comps.month+=1;
                comps.day = 1;
                if(comps.month>12)
                {
                    comps.year += 1;
                    comps.month = 1;
                }
                NSDate* end = [calendar dateFromComponents:comps];
                int intervalDays = (int)[end timeIntervalSinceDate:begin]/24/60/60;
                [*average addObject:@(intervalDays)];
            }
        }
    }
    return retArray;
}


+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"Sunday", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

@end
