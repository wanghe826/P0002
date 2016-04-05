//
//  SMDatabaseSingleton.m
//  sqliteDemo
//
//  Created by QFITS－iOS on 15/10/10.
//  Copyright © 2015年 SmartMovementw07. All rights reserved.
//

#import "SMDatabaseSingleton.h"
#import "SportModel.h"

#import "MyFMDBUtil.h"



@implementation SMDatabaseSingleton


+(instancetype)shareInstance
{
    static SMDatabaseSingleton* singleton = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

- (instancetype) init
{
    [self initData];
    return self;
}


- (void) initData
{
    [MyFMDBUtil sharedFMDBQueueInstance];
}


- (BOOL) createTable
{
    BOOL flag = YES;
    
    [MyFMDBUtil createTable];
    return flag;
}

//增
- (BOOL) insertData:(SportModel*)modle withUUID:(NSString*)uuidString
{
    [MyFMDBUtil insertData:modle withUUID:uuidString];
    return YES;
}

//删

//改

//查

- (NSMutableArray*)queryOneDayByDate:(NSDate*)queryDate
{
    return [MyFMDBUtil queryOneDayByDate:queryDate];
}


- (NSMutableArray*)queryAllDays
{
    return [MyFMDBUtil queryAllDays];
}



- (BOOL) clearAllData
{
    BOOL flag =NO;
    
    [MyFMDBUtil clearAllData];
    
    return flag;
}

@end
