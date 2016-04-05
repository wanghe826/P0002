//
//  BLEAppContext.m
//  sportsBracelets
//
//  Created by dingyl on 14/12/21.
//
//

#import "BLEAppContext.h"

NSString *key_isPaired = @"isPaired";
NSString *key_switches = @"switches";

static BLEAppContext *_appContext = nil;

@implementation BLEAppContext

+ (instancetype)shareBleAppContext {
    if (!_appContext) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _appContext = [[BLEAppContext alloc] init];
        });
    }
    return _appContext;
}

- (void)saveSwitches:(NSString *)identifer {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithUnsignedShort:self.switches] forKey:[NSString stringWithFormat:@"%@_switches",identifer]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readSwitches:(NSString *)identifier {
    NSNumber *switches = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_switches",identifier]];
    if (switches) {
        self.switches = [switches unsignedShortValue];
    }
    else {
        self.switches = (UInt16)(1|(1<<1)|(1<<2)|(1<<3));
    }
}

- (void)resetBLEAppContext {
    self.isPaired = NO;
    self.switches = 0x0;
    self.isConnected = NO;
    self.isInsertingData = NO;
}

@end
