//
//  MyFMDBUtil.h
//  Common
//
//  Created by QFITS－iOS on 15/12/23.
//  Copyright © 2015年 Smartmovt. All rights reserved.
//
#import <Foundation/Foundation.h> 

static NSString* const TABLE_NAME = @"FITNESS";
static NSString* const ID = @"_id";
static NSString* const TIME = @"time";
static NSString* const DATA = @"data";
static NSString* const TYPE = @"type";
static NSString* const UUID = @"uuid";
static NSString* const TARGET = @"target";
static NSString* const STATUS = @"status";



@class FMDatabase;
@class SportModel;

@interface MyFMDBUtil : NSObject{
    FMDatabase* _db;
}

+ (FMDatabaseQueue*)sharedFMDBQueueInstance;
+ (NSMutableArray*)queryAllDays;
+ (NSMutableArray*)queryOneDayByDate:(NSDate*)queryDate;
+ (void) insertData:(SportModel*)modle withUUID:(NSString*)uuidString;
+ (BOOL) createTable;
+ (BOOL) clearAllData;

@end
