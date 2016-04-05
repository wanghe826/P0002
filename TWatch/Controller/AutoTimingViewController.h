//
//  AutoTimingViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#define degreesToRadian(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / M_PI)

#define HourHand 0
#define MinuteHand 1
#define SecondHand 2

@interface AutoTimingViewController : BaseViewController
{
    UILabel* _hourLabel;
    UILabel* _minLabel;
    UILabel* _secondLabel;
    
    UIImageView* _hourView;
    UIImageView* _minuteView;
    UIImageView* _secondView;
    
    NSDateComponents* _dateComponents;
    
    NSUInteger _currentSelectHand;
    
//    CGRect _watchAndHandleRect;
    
    //头部提示语
    UILabel* _topHintLabel;
    
    //表盘的图片
    UIImageView* _watchView;
    
    //正在校时的定时器
    NSTimer* _timingTimer;
    
    UIActivityIndicatorView* _activityView;
    
    //同步时间按钮
    UIButton* _syncTimeBtn;
    

    NSTimer* _timeOutTimer;
}

- (void) startActionHandle;

- (void) syncTime:(UIButton*)sender;

- (void) resetTimer;

- (void) stopActionHint;
@end
