//
//  JGBleDeviceInfo.m
//  sportsBracelets
//
//  Created by fnst on 14/10/30.
//
//

#import "JGBleDeviceInfo.h"

@implementation JGBleDeviceInfo

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self=[super init])
    {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.rssi = [aDecoder decodeObjectForKey:@"rssi"];
    }
    return (self);
}

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_rssi forKey:@"rssi"];
}

-(NSString*) description {
    return self.name;
}

@end
