//
//  SMDatabaseSingleton.h
//  sqliteDemo
//
//  Created by QFITS－iOS on 15/10/10.
//  Copyright © 2015年 SmartMovementw07. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@class SportModel;

@interface SMDatabaseSingleton : NSObject
{
    FMDatabase* _db;
}

+(instancetype) shareInstance;
+(FMDatabaseQueue *)sharedFMDBQueueInstance;

//数据库操作
- (BOOL) createTable;
- (BOOL) insertData:(SportModel*)modle withUUID:(NSString*)uuidString;

- (BOOL) clearAllData;
- (NSMutableArray*)queryOneDayByDate:(NSDate*)queryDate;
- (NSMutableArray*)queryAllDays;
@end
