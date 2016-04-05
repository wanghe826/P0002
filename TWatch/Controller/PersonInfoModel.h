//
//  PersonInfoModel.h
//  TWatch
//
//  Created by QFITS－iOS on 15/8/1.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonInfoModel : NSObject<NSCopying>
@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* sex;
@property(nonatomic,strong) NSDate* birthday;
@property(nonatomic,strong) NSString* weight;
@property(nonatomic,strong) NSString* height;
@property(nonatomic,strong) NSData* touxiang;
@end
