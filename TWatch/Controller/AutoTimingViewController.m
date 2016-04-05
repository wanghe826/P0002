//
//  AutoTimingViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "AutoTimingViewController.h"
#import "FunctionViewController.h"
#import "SVProgressHUD.h"

#import "AppUtils.h"

@interface AutoTimingViewController()
{
    NSTimer* _sendCommandTimer;
    
    int _timingAckCount;
    
    
    NSTimer* _animationTimer;
    UIImageView* _handleView;
}

@end

@implementation AutoTimingViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    self.view.backgroundColor = RGBColor(0x2f, 0x34, 0x3e);
    self.navigationController.navigationBar.hidden = YES;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle: NSLocalizedString(@"跳过", nil)  forState:UIControlStateNormal];
    [button setFrame:CGRectMake(screen_width-80, 25, 80, 30)];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(ignore) forControlEvents:UIControlEventTouchUpInside];
    
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(actionHint) userInfo:nil repeats:YES];
    [_animationTimer fire];
    
}

- (void) actionHint
{
    int second = (int)_dateComponents.second;
    float secondRotation = second*2*M_PI/60;
    
    [UIView animateWithDuration:1.0f animations:^{
        _secondLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
        
        _secondView.transform = CGAffineTransformMakeRotation(secondRotation + 0.5);
        _handleView.transform = CGAffineTransformMakeRotation(secondRotation + 0.5);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f animations:^{
            _secondLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
            _secondView.transform = CGAffineTransformMakeRotation(secondRotation);
            _handleView.transform = CGAffineTransformMakeRotation(secondRotation);
        }];
    }];
}

- (void) ignore
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUEndWhenAdjustTimeNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        FunctionViewController* funcVc = [[FunctionViewController alloc] init];
        ApplicationDelegate.functionVc = funcVc;
        UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:funcVc];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
        
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    });
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //停针
//    [self stopHandler];
     _sendCommandTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(stopHandler) userInfo:nil repeats:YES];
    [_sendCommandTimer fire];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAck) name:BLEACKNotificationKey object:nil];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_sendCommandTimer && [_sendCommandTimer isValid])
    {
        [_sendCommandTimer invalidate];
    }
    _sendCommandTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEACKNotificationKey object:nil];
    
    
    _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(timeOutExit) userInfo:nil repeats:NO];
}


- (void) timeOutExit
{
    [self startActionHandle];
}

#pragma 收到ACK
- (void)didReceiveAck
{
}


- (void) stopHandler
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUBeginWhenAdjustTimeNotification object:nil];
}

- (void) initUI
{
    self.title = NSLocalizedString(@"智能校时", nil);
    _topHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 60)];
    _topHintLabel.text = NSLocalizedString(@"手表现在的指针指向是？", nil);
    _topHintLabel.numberOfLines  = 0 ;
    _topHintLabel.textAlignment = NSTextAlignmentCenter;
    _topHintLabel.textColor = [UIColor grayColor];
    [_topHintLabel setFont:[UIFont systemFontOfSize:14]];
    _topHintLabel.center = CGPointMake(self.view.center.x, 90);
    [self.view addSubview:_topHintLabel];
    
    NSDate* currentDate = [NSDate date];
    _dateComponents = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    _dateComponents = [gregorian components:unit fromDate:currentDate];
    
    if(_dateComponents.hour == 0)
    {
        _hourLabel = [self createLabel:CGPointMake(self.view.center.x-70, 150) withString:@"12"];
    }
    else if(_dateComponents.hour > 12)
    {
        _hourLabel = [self createLabel:CGPointMake(self.view.center.x-70, 150) withString:[NSString stringWithFormat:@"%ld",(long)(_dateComponents.hour-12)]];
    }
    else
    {
        _hourLabel = [self createLabel:CGPointMake(self.view.center.x-70, 150) withString:[NSString stringWithFormat:@"%ld",(long)_dateComponents.hour]];
    }
    
//    [_hourLabel setFont:[UIFont systemFontOfSize:40]];
//    _hourLabel.textColor = [UIColor redColor];
    _hourLabel.userInteractionEnabled = YES;
    [self.view addSubview:_hourLabel];
    
    UILabel* pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(_hourLabel.frame.origin.x+_hourLabel.frame.size.width+7, 120, 10, 50)];
    pointLabel.text = @":";
    pointLabel.textColor = [UIColor grayColor];
    pointLabel.textAlignment = NSTextAlignmentCenter;
    [pointLabel setFont:[UIFont systemFontOfSize:28]];
    [self.view addSubview:pointLabel];
    
    _minLabel = [self createLabel:CGPointMake(self.view.center.x, 150) withString:[NSString stringWithFormat:@"%ld",(long)_dateComponents.minute]];
    _minLabel.userInteractionEnabled = YES;
    [self.view addSubview:_minLabel];
    
    UILabel* pointLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(_minLabel.frame.origin.x+_minLabel.frame.size.width+5, 120, 10, 50)];
    pointLabel2.text = @":";
    pointLabel2.textColor = [UIColor grayColor];
    pointLabel2.textAlignment = NSTextAlignmentCenter;
    [pointLabel2 setFont:[UIFont systemFontOfSize:28]];
    [self.view addSubview:pointLabel2];
    
    _secondLabel = [self createLabel:CGPointMake(self.view.center.x+70, 150) withString:[NSString stringWithFormat:@"%ld",(long)_dateComponents.second]];
    _secondLabel.userInteractionEnabled = YES;
    _secondLabel.textColor = [UIColor redColor];
    [self.view addSubview:_secondLabel];
    
    _syncTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"]) {
    
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_first_synchronize_avr_en"] forState:UIControlStateNormal];
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_first_synchronize_avr_en"] forState:UIControlStateHighlighted];
        
    }else
    {
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_first_synchronize_avr"] forState:UIControlStateNormal];
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_first_synchronize_sel"] forState:UIControlStateHighlighted];
    }
    

    _syncTimeBtn.frame = CGRectMake(0, 0, 230, 34);
    _syncTimeBtn.center = CGPointMake(self.view.center.x, screen_height-100);
    [_syncTimeBtn addTarget:self action:@selector(syncTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_syncTimeBtn];
    
    _syncTimeBtn.hidden = YES;
    
    [self addWatch];
}

- (void) addWatch
{
    _watchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_first_timing_clock"]];
    _watchView.frame = kWatchRect;
    _watchView.center = CGPointMake(self.view.center.x, self.view.center.y+20);
    [self.view addSubview:_watchView];
    

    int hour = (int)_dateComponents.hour;
    if(hour>12)
    {
        hour = abs(hour-12);
    }
    int minute = (int)_dateComponents.minute;
    int second = (int)_dateComponents.second;
    
    _hourView = [[UIImageView alloc] initWithFrame:kWatchRect];
    _hourView.image = [UIImage imageNamed:@"img_first_pointer_hour_avr"];
    _hourView.center = _watchView.center;
    [self.view addSubview:_hourView];
    
    _minuteView = [[UIImageView alloc] initWithFrame:kWatchRect];
    _minuteView.image = [UIImage imageNamed:@"img_first_pointer_min_avr"];
    _minuteView.center = _watchView.center;
    [self.view addSubview:_minuteView];
    
    _secondView = [[UIImageView alloc] initWithFrame:kWatchRect];
    _secondView.image = [UIImage imageNamed:@"img_first_pointer_sec_sel"];
    _secondView.center = _watchView.center;
    [self.view addSubview:_secondView];
    
    _handleView = [[UIImageView alloc] initWithFrame:kWatchRect];
    _handleView.image = [UIImage imageNamed:@"img_touch"];
    _handleView.center = _watchView.center;
    [self.view addSubview:_handleView];
    
    float hourRotation = hour*2*M_PI/12;
    float minuteRotation = minute*2*M_PI/60;
    float secondRotation = second*2*M_PI/60;
    _hourView.transform = CGAffineTransformMakeRotation(hourRotation);
    _minuteView.transform = CGAffineTransformMakeRotation(minuteRotation);
    _secondView.transform = CGAffineTransformMakeRotation(secondRotation);
    _currentSelectHand = SecondHand;
    [self.view bringSubviewToFront:_secondView];
}

- (void) syncTime:(UIButton*)sender
{
    [self resetTimer];
    if(![BLEAppContext shareBleAppContext].isAuthorized)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请连接手表", nil)];
        return;
    }
    
    if(!_timingTimer)
    {
        _timingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(autoTimingTimer) userInfo:nil repeats:YES];
    }
    if(![_timingTimer isValid])
    {
        [_timingTimer fire];
    }
    _topHintLabel.text = NSLocalizedString(@"正在同步时间,请稍后...", nil);
    sender.hidden = YES;
    if(!_activityView)
    {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.frame = sender.frame;
        [self.view addSubview:_activityView];
    }
    [_activityView startAnimating];
    
    //步骤1
    _timingAckCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUAdjustTimeNotification object:nil userInfo:@{BLEHour:@([_hourLabel.text intValue]),BLEMinute:  @([_minLabel.text intValue]),BLESecond:  @([_secondLabel.text intValue]),}];
    
    //步骤2
    [self performSelector:@selector(checkTimeZoneAction) withObject:nil afterDelay:0.1];
    
    if(_sendCommandTimer && [_sendCommandTimer isValid])
    {
        [_sendCommandTimer invalidate];
        _sendCommandTimer = nil;
    }
    
    [self performSelector:@selector(startActionHandle) withObject:nil afterDelay:0.2];
}


- (void) startActionHandle
{
    //步骤3
    //走针
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUEndWhenAdjustTimeNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        FunctionViewController* funcVc = [[FunctionViewController alloc] init];
        ApplicationDelegate.functionVc = funcVc;
        UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:funcVc];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
        
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    });
}



- (void) checkTimeZoneAction
{
    NSDate* date = [NSDate date];
    NSNumber* Zone = [NSNumber numberWithInt:0x71];
    NSNumber* on = [NSNumber numberWithBool:NO];
    NSDictionary* userInfo = @{BLEMCUWorldTimeSyncNotificationDateKey:date, BLEMCUWorldTimeSyncNotificationTimezoneKey:Zone, @"DST_IS_ON":on  , @"CITY": @"HKG"};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUWorldTimeSyncNotification object:nil userInfo:userInfo];
    
    
}


- (void) autoTimingTimer
{
    static float degree = M_PI/30;
    static float hourDegree = M_PI/6;
    
    _secondView.transform = CGAffineTransformMakeRotation(degree + [_secondLabel.text intValue]*degree);
    
    int hour = [_hourLabel.text intValue];
    int min = [_minLabel.text intValue];
    int sec = [_secondLabel.text intValue];
    
    if(sec+1 < 10)
    {
        _secondLabel.text = [NSString stringWithFormat:@"0%d", sec+1];
    }
    else
    {
        _secondLabel.text = [NSString stringWithFormat:@"%d", sec+1];
    }
    
    ++sec;
    if(sec==60)
    {
        _secondLabel.text = @"0";
        sec = 0;
        _minuteView.transform = CGAffineTransformMakeRotation(degree + [_minLabel.text intValue]*degree);
        
        if(min+1 < 10)
        {
            _minLabel.text = [NSString stringWithFormat:@"0%d", min+1];
        }
        else
        {
            _minLabel.text = [NSString stringWithFormat:@"%d", min+1];
        }
        
        
    }
    if(min==60)
    {
        _minLabel.text = @"0";
        min = 0;
        _hourLabel.transform = CGAffineTransformMakeRotation(hourDegree + [_hourLabel.text intValue]*hourDegree);
        if(hour+1 < 10)
        {
            _hourLabel.text = [NSString stringWithFormat:@"%0d", hour+1];
        }
        else
        {
            _hourLabel.text = [NSString stringWithFormat:@"%d", hour+1];
        }
        _hourLabel.text = [NSString stringWithFormat:@"%d", hour+1];
    }
    if(hour == 12)
    {
        hour = 0;
    }
    
    
}

- (UILabel*)createLabel:(CGPoint)center withString:(NSString*)str
{
    if([str intValue]<10)
    {
        str = [@"0" stringByAppendingString:str];
    }
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    label.text = str;
    label.textColor = RGBColor(0xfd, 0xfd, 0xfd);
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont systemFontOfSize:32]];
    label.center = center;
    return label;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    if(!CGRectContainsPoint(_hourView.frame, currentPoint) || screen_height<=568)
    {
        return;
    }
    
    [self rotateWatchHandle:currentPoint];
}


- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    if(!CGRectContainsPoint(_hourView.frame, currentPoint))
    {
        return;
    }
    
    [self rotateWatchHandle:currentPoint];
}

- (void) stopActionHint
{
    _handleView.hidden = YES;
    [_animationTimer invalidate];
    _animationTimer = nil;
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self stopActionHint];
    
    _syncTimeBtn.hidden = NO;
    UITouch* touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    if(CGRectContainsPoint(_hourLabel.frame, currentPoint))
    {
        _hourLabel.textColor = [UIColor redColor];
        [_hourLabel setFont:[UIFont systemFontOfSize:40]];
        _hourView.image = [UIImage imageNamed:@"img_first_pointer_hour_sel"];
        [self.view bringSubviewToFront:_hourView];
        _currentSelectHand = HourHand;
        
        _minLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        [_minLabel setFont:[UIFont systemFontOfSize:32]];
        _minuteView.image = [UIImage imageNamed:@"img_first_pointer_min_avr"];
        
        _secondLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        [_secondLabel setFont:[UIFont systemFontOfSize:32]];
        _secondView.image = [UIImage imageNamed:@"img_first_pointer_sec_avr"];
    }
    else if(CGRectContainsPoint(_minLabel.frame, currentPoint))
    {
        [_hourLabel setFont:[UIFont systemFontOfSize:32]];
        _hourLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        _hourView.image = [UIImage imageNamed:@"img_first_pointer_hour_avr"];
        
        [_minLabel setFont:[UIFont systemFontOfSize:40]];
        _minLabel.textColor = [UIColor redColor];
        _minuteView.image = [UIImage imageNamed:@"img_first_pointer_min_sel"];
        [self.view bringSubviewToFront:_minuteView];
        _currentSelectHand = MinuteHand;
        
        [_secondLabel setFont:[UIFont systemFontOfSize:32]];
        _secondLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        _secondView.image = [UIImage imageNamed:@"img_first_pointer_sec_avr"];
    }
    else if(CGRectContainsPoint(_secondLabel.frame, currentPoint))
    {
        [_hourLabel setFont:[UIFont systemFontOfSize:32]];
        _hourLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        _hourView.image = [UIImage imageNamed:@"img_first_pointer_hour_avr"];
        
        [_minLabel setFont:[UIFont systemFontOfSize:32]];
        _minLabel.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        _minuteView.image = [UIImage imageNamed:@"img_first_pointer_min_avr"];
        
        [_secondLabel setFont:[UIFont systemFontOfSize:40]];
        _secondLabel.textColor = [UIColor redColor];
        _secondView.image = [UIImage imageNamed:@"img_first_pointer_sec_sel"];
        [self.view bringSubviewToFront:_secondView];
        _currentSelectHand = SecondHand;
    }
    
    [self resetTimer];
}

- (void) resetTimer
{
    [_timeOutTimer invalidate];
    _timeOutTimer = nil;
    _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(timeOutExit) userInfo:nil repeats:NO];
}

- (void) rotateWatchHandle:(CGPoint)currentPoint
{
    double degree = 0;
    if(currentPoint.x<self.view.center.x)       //触摸点在中心点的左边
    {
        degree = atan((self.view.center.x - currentPoint.x)/(currentPoint.y-_hourView.center.y));
        if(currentPoint.y>=_hourView.center.y)   //触摸点在中心点的上边
        {
            degree+=M_PI;
        }
    }
    if(currentPoint.x>self.view.center.x)       //触摸点在中心点的右边
    {
        degree = atan((currentPoint.x - self.view.center.x)/(currentPoint.y-_hourView.center.y));
        if(currentPoint.y>=_hourView.center.y)   //触摸点在中心点的上边
        {
            degree+=M_PI;
        }
        degree = -degree;
    }
    
    
    switch (_currentSelectHand) {
        case HourHand:
        {
            CGFloat radiusssss = atan2f(_hourView.transform.b, _hourView.transform.a);
            CGFloat degreeeeee = radiusssss * (180 / M_PI);
            if(degreeeeee>=0 && degreeeeee<=180)
            {
                _hourLabel.text = [NSString stringWithFormat:@"%d",(int)(degreeeeee/30)];
            }
            else
            {
                _hourLabel.text = [NSString stringWithFormat:@"%d",(int)(18-(-degreeeeee+180)/30)];
            }
            
            if([_hourLabel.text intValue]==0)
            {
                _hourLabel.text = @"12";
            }
            else if([_hourLabel.text intValue]<10)
            {
                _hourLabel.text = [@"0" stringByAppendingString:_hourLabel.text];
            }
            
            _hourView.transform = CGAffineTransformMakeRotation(degree);
            break;
        }
        case MinuteHand:
        {
            CGFloat radiusssss = atan2f(_minuteView.transform.b, _minuteView.transform.a);
            CGFloat degreeeeee = radiusssss * (180 / M_PI);
            if(degreeeeee>=0 && degreeeeee<=180)
            {
                _minLabel.text = [NSString stringWithFormat:@"%d",(int)(degreeeeee/6)];
            }
            else
            {
                _minLabel.text = [NSString stringWithFormat:@"%d",(int)(90-(-degreeeeee+180)/6)];
            }
            
            if([_minLabel.text intValue] < 10)
            {
                _minLabel.text = [@"0" stringByAppendingString:_minLabel.text];
            }
            
            _minuteView.transform = CGAffineTransformMakeRotation(degree);
            break;
        }
        case SecondHand:
        {
            CGFloat radiusssss = atan2f(_secondView.transform.b, _secondView.transform.a);
            CGFloat degreeeeee = radiusssss * (180 / M_PI);
            if(degreeeeee>=0 && degreeeeee<=180)
            {
                _secondLabel.text = [NSString stringWithFormat:@"%d",(int)(degreeeeee/6)];
            }
            else
            {
                _secondLabel.text = [NSString stringWithFormat:@"%d",(int)(90-(-degreeeeee+180)/6)];
            }
            
            if([_secondLabel.text intValue] < 10)
            {
                _secondLabel.text = [@"0" stringByAppendingString:_secondLabel.text];
            }
            
            _secondView.transform = CGAffineTransformMakeRotation(degree);
            break;
        }
        default:
        break;
    }
}




@end
