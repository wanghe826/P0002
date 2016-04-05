//
//  PersonInfoModel.m
//  TWatch
//
//  Created by QFITS－iOS on 15/8/1.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "PersonInfoModel.h"

@implementation PersonInfoModel

/*@property(nonatomic,strong) UIImage* touxiang;
 @property(nonatomic,strong) NSString* username;
 @property(nonatomic,strong) NSDate* birthday;
 @property(nonatomic,assign) int weight;
 @property(nonatomic,assign) int height;*/

-(void)encodeWithCoder:(NSCoder*)aCoder{
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.weight forKey:@"weight"];
    [aCoder encodeObject:self.height forKey:@"height"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.touxiang forKey:@"touxiang"];
}

-(id)initWithCoder:(NSCoder*)aDecoder{
    if(self = [super init]){
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.weight = [aDecoder decodeObjectForKey:@"weight"];
        self.height = [aDecoder decodeObjectForKey:@"height"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
        self.touxiang = [aDecoder decodeObjectForKey:@"touxiang"];
    }
    return self;
}

@end
