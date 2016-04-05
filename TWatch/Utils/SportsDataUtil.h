//
//  SportsDataUtil.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/18.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMDatabaseSingleton.h"
#import "JGBLEManager.h"

@interface SportsDataUtil : NSObject{
    NSDate* _nearDate;
    NSDateFormatter* _dateFormatter;
    SMDatabaseSingleton* _singleton;
    JGBLEManager* _manager;
    
    int _nullPckOffset;        //应该跳过的空包
}

//运动数据长度请求
-(void) requestSportsDataLength;




@end
