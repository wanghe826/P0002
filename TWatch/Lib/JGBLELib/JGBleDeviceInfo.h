//
//  JGBleDeviceInfo.h
//  sportsBracelets
//
//  Created by fnst on 14/10/30.
//
//

#import <Foundation/Foundation.h>

@interface JGBleDeviceInfo : NSObject<NSCoding>

@property (strong, nonatomic) NSString *identifier;             //uuid
@property (strong, nonatomic) NSString *name;                   //name
@property (strong, nonatomic) NSNumber *rssi;                   //信号强度

@end
