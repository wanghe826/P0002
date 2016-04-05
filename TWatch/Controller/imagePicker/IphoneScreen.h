#import <Foundation/Foundation.h>
#define IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//#define ScreenHeight (IS_IPHONE5 ? 568.0 : 480.0)

@interface IphoneScreen : NSObject
 
@end
