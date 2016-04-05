//
//  SMDatabaseSingleton.m
//  sqliteDemo
//
//  Created by QFITS－iOS on 15/10/10.
//  Copyright © 2015年 SmartMovementw07. All rights reserved.
//

#import "MyFMDBUtil.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#import "SportModel.h"

@implementation MyFMDBUtil


+ (FMDatabaseQueue*)sharedFMDBQueueInstance
{
    static FMDatabaseQueue *my_FMDatabaseQueue=nil;
    
    if (!my_FMDatabaseQueue) {
        NSString* homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString* dbPath = [homePath stringByAppendingPathComponent:@"sm_w07_fitness.db"];
        my_FMDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return my_FMDatabaseQueue;
}



//- (instancetype) init
//{
//    [self initData];
//    return self;
//}
//
//
//- (void) initData
//{
//    NSString* homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    NSString* dbPath = [homePath stringByAppendingPathComponent:@"sm_w07_fitness.db"];
//    db = [FMDatabase databaseWithPath:dbPath];
//}


+ (BOOL) createTable
{
    __block BOOL flag = YES;
    [[MyFMDBUtil sharedFMDBQueueInstance] inDatabase:^(FMDatabase *db) {
        if([db open])
        {
            //为数据库设置缓存，提高查询效率
            [db setShouldCacheStatements:YES];
    
//            NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' DATE, '%@' INTEGER, '%@' INTEGER, '%@' TEXT, '%@' INTEGER, '%@' INTEGER)",TABLE_NAME,ID,TIME,DATA,TYPE,UUID, TARGET, STATUS];
            NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' DATE, '%@' INTEGER, '%@' INTEGER, '%@' TEXT, '%@' INTEGER, '%@' INTEGER, UNIQUE('%@'))",TABLE_NAME,ID,TIME,DATA,TYPE,UUID, TARGET, STATUS,TIME];
            BOOL res = [db executeUpdate:sqlCreateTable];
            if (!res) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"success to creating db table");
                flag = NO;
            }
            [db close];
        }
    }];
    return flag;
}

//增
+ (void) insertData:(SportModel*)modle withUUID:(NSString*)uuidString
{
    FMDatabaseQueue* queue = [MyFMDBUtil sharedFMDBQueueInstance];
    
    [queue inDatabase:^(FMDatabase *db) {
//        NSString* insertStr = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@','%@') VALUES('%@','%d','%d','%@','%d','%d')", TABLE_NAME, TIME, DATA, TYPE, UUID, TARGET, STATUS, modle.sportTime, modle.sportData, 1, uuidString, 1000, 1];
        NSString* insertStr = [NSString stringWithFormat:@"INSERT OR IGNORE INTO '%@'('%@','%@','%@','%@','%@','%@') VALUES('%@','%d','%d','%@','%d','%d')", TABLE_NAME, TIME, DATA, TYPE, UUID, TARGET, STATUS, modle.sportTime, modle.sportData, 1, uuidString, 1000, 1];
        
        if([db open])
        {
            BOOL retInsert = [db executeUpdate:insertStr];
            NSLog(@"插入失败了:%d", retInsert);
        }
        else
        {
            NSLog(@"打开数据库失败!!!");
        }
    }];
}

//删

//改

//查

+ (NSMutableArray*)queryOneDayByDate:(NSDate*)queryDate
{
    __block NSMutableArray* array = [NSMutableArray new];
    
    FMDatabaseQueue* queue = [MyFMDBUtil sharedFMDBQueueInstance];
    [queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSString* exSql = nil;
            
            exSql = [NSString stringWithFormat:@"select * , date( %@ ) as dat  from %@ where dat = date('%@') order by %@ asc ;",TIME,TABLE_NAME,[formatter stringFromDate:queryDate],TIME];
            
            FMResultSet *resultSet = [db executeQuery:exSql];
            
            NSString *dateString;
            int step;
            
            while ([resultSet next]) {
                
                SportModel* model = [[SportModel alloc] init];
                dateString = [resultSet stringForColumn:TIME];
                //            dateTime = [formatter dateFromString:dateString];
                step = [resultSet intForColumn:DATA];
                model.sportData = step;
                model.sportTime = dateString;
                
                NSString* uuidStr = ApplicationDelegate.bleMgr.currentUUIDString;
                if(uuidStr){
                    if ([[resultSet stringForColumn:UUID] isEqualToString:uuidStr])
                    {
                        [array addObject:model];
                    }
                }else{
                    [array addObject:model];
                }
            }
        }
    }];
    
    
    return array;
}


+ (NSMutableArray*)queryAllDays
{
    __block NSMutableArray *array = [NSMutableArray new];
    
    FMDatabaseQueue* queue = [MyFMDBUtil sharedFMDBQueueInstance];
    [queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSString* exSql = nil;
            
            
            //        NSDate* date = [[NSDate date] dateByAddingTimeInterval:-60*60*24*2];
            
            exSql = [NSString stringWithFormat:@"select * , date( %@ ) as dat  from %@ order by %@ asc ;",TIME,TABLE_NAME,TIME];
            //        exSql = [NSString stringWithFormat:@"select * from %@", TABLE_NAME];
            
            
            FMResultSet *resultSet = [db executeQuery:exSql];
            
            NSLog(@"----duoshaohang---%d",[resultSet columnCount]);
            
            NSString *dateString;
            int step;
            
            while ([resultSet next]) {
                SportModel* model = [[SportModel alloc] init];
                dateString = [resultSet stringForColumn:TIME];
                step = [resultSet intForColumn:DATA];
                model.sportData = step;
                model.sportTime = dateString;
                
                NSString* uuidStr = ApplicationDelegate.bleMgr.currentUUIDString;
                if(uuidStr){
                    if ([[resultSet stringForColumn:UUID] isEqualToString:uuidStr])
                    {
                        [array addObject:model];
                    }
                }else{
                    [array addObject:model];
                }
            }
        }
    }];
    
    
    return array;
}



+ (BOOL) clearAllData
{
    __block BOOL flag =NO;
    
    FMDatabaseQueue* queue = [MyFMDBUtil sharedFMDBQueueInstance];
    [queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSString *exSql = [NSString stringWithFormat:@"delete from %@",TABLE_NAME];
            flag= [db executeUpdate:exSql];
            NSLog(@"数据库删除%@",flag?@"success":@"failue");
            [db close];
        }
    }];
    return flag;
}

@end
