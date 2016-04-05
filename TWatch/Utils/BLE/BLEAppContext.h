//
//  BLEAppContext.h
//  sportsBracelets
//
//  Created by dingyl on 14/12/21.
//
//

#import <Foundation/Foundation.h>

@interface BLEAppContext : NSObject

extern NSString *key_isPaired;
extern NSString *key_switches;

@property (assign, nonatomic) BOOL isAuthorized; //标记是否授权
@property (assign, nonatomic) BOOL isConnected; //标记是否连接上
@property (assign, nonatomic) BOOL isPaired;//标记是否配对
@property (assign, nonatomic) BOOL isInSearchVC;  //标记是否在手动搜索连接页面

@property (assign, nonatomic) UInt16 switches;//各开关的对应值
@property (strong, nonatomic) NSString *uuid;//ble标识符


@property (assign, nonatomic) BOOL isSelfDisconnect;

@property (assign, nonatomic) BOOL isInsertingData;     //是否正在插入数据

+ (instancetype)shareBleAppContext;

- (void)saveSwitches:(NSString *)identifer;
- (void)readSwitches:(NSString *)identifier;
- (void)resetBLEAppContext;

@end
