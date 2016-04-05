//
//  PointerView.m
//  TWatch
//
//  Created by Yingbo on 15/7/29.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "PointerView.h"
@interface PointerView ()

@property(nonatomic,strong) UIImageView *backImageView;

@property(nonatomic,strong) UIImageView *hourView;

@property(nonatomic,strong) UIImageView *minuteView;

@property(nonatomic,strong) UIImageView *secondView;

@property(nonatomic,assign) CGPoint startPointerValue;



@end

@implementation PointerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = kHour;
        
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:[[NSUserDefaults standardUserDefaults]objectForKey:@"ZoneName"]];
//        NSDate *date = [NSDate date];
//        NSDate *newDate = date;


        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString * zoneName = [[NSUserDefaults standardUserDefaults]objectForKey:@"ZoneName"];
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:zoneName] ;
        
        NSDate *date = [NSDate date];
        NSDate *newDate = date;
        
        

       NSString * str = [formatter stringFromDate:newDate];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *transDate = [dateFormatter dateFromString:str];

        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unit = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents* components = [[NSDateComponents alloc] init];
        components = [calendar components:unit fromDate:transDate];
        self.currentHour = [components hour];
        _daylightStatus = [[NSUserDefaults standardUserDefaults]boolForKey:@"DayLight"];
        if (_daylightStatus)
        {
            self.currentHour = self.currentHour + 1;
        }
        if(self.currentHour >= 12){
            self.currentHour = self.currentHour-12;
        }
        self.currentMin = [components minute];
        self.currentSec = [components second];
        self.hour = _currentHour;
        self.second = _currentSec;
        self.minute = _currentMin;
        [self layoutSubview];
//        for (int i = 0; i<12; 1++)
//        {
//            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn
//        }
    }
    return self;
}
-(void)updateHour
{
    if (_daylightStatus)
    {
        self.currentHour = self.currentHour + 1;
    }
    if(self.currentHour >= 12){
        self.currentHour = self.currentHour-12;
    }
}
- (void)layoutSubview
{
    [self addSubview:self.backImageView];
    [self addSubview:self.hourView];
    if(self.currentHour >= 12){
        self.currentHour = self.currentHour-12;
    }
    self.hourView.transform = CGAffineTransformMakeRotation(self.currentHour * M_PI/6);
    [self addSubview:self.minuteView];
    self.minuteView.transform = CGAffineTransformMakeRotation(self.currentMin * M_PI*2/60);
    [self addSubview:self.secondView];
    self.secondView.transform = CGAffineTransformMakeRotation(self.currentSec * M_PI*2/60);

}

- (UIImageView *)backImageView
{
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backImageView.image = [UIImage imageNamed:@"time_set_clock_bg"];
    }
    return _backImageView;
}

- (UIImageView *)hourView
{
    if (_hourView == nil) {
        _hourView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _hourView.image = [UIImage imageNamed:@"time_set_hour_2"];
    }
    return _hourView;
}

- (UIImageView *)minuteView
{
    if (_minuteView == nil) {
        _minuteView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _minuteView.image = [UIImage imageNamed:@"time_set_min_1"];
    }
    return _minuteView;
}

- (UIImageView *)secondView
{
    if (_secondView == nil) {
        _secondView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _secondView.image = [UIImage imageNamed:@"time_set_sec_1"];
    }
    return _secondView;
}


- (void)setType:(PointerType)type
{
    _type = type;
    switch (type) {
        case kHour:
            self.hourView.image = [UIImage imageNamed:@"time_set_hour_2"];
            self.minuteView.image = [UIImage imageNamed:@"time_set_min_1"];
            self.secondView.image = [UIImage imageNamed:@"time_set_sec_1"];
            break;
        case kMinute:
            self.hourView.image = [UIImage imageNamed:@"time_set_hour_1"];
            self.minuteView.image = [UIImage imageNamed:@"time_set_min_2"];
            self.secondView.image = [UIImage imageNamed:@"time_set_sec_1"];
            break;
        case kSecond:
            self.hourView.image = [UIImage imageNamed:@"time_set_hour_1"];
            self.minuteView.image = [UIImage imageNamed:@"time_set_min_1"];
            self.secondView.image = [UIImage imageNamed:@"time_set_sec_2"];
            break;
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _startPointerValue  = [touch locationInView:self];
    return;
    CGFloat degrees = atan((_startPointerValue.y-self.frame.size.width/2)/(_startPointerValue.x-self.frame.size.width/2));
    NSInteger currentHour = ceil(degrees/30);
    NSLog(@"点击的几点%d",currentHour);
//    CGFloat degree = atan2(_startPointerValue.y, _startPointerValue. x);
    float x = _startPointerValue.x*_startPointerValue.x + _startPointerValue.y*_startPointerValue.y;
    float sqrt_x = _startPointerValue.x / sqrt(x);
    CGFloat degree = sin(sqrt_x);
    NSLog(@"旋转角度%f",degree);
    switch (_type) {
        case kHour:
        {
            NSDate *now = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            if (_hour==0)
            {
                _hour = [dateComponent hour];
                if (_hour>=12)
                {
                    _hour -= 12;
                }
            }
            degree = atan2(_startPointerValue.y,_startPointerValue.x-self.frame.size.width/2);
            NSInteger currentHour = ceil(degree/30+12);
            if (_hour<currentHour)
            {
                self.hourView.transform = CGAffineTransformMakeRotation((currentHour-_hour)*(M_PI/60));
            }
            else
            {
                self.hourView.transform = CGAffineTransformMakeRotation(-(currentHour-_hour)*(M_PI/60));
            }
//            self.hourView.transform = CGAffineTransformMakeRotation(degree);
            CGFloat value = degree / (M_PI/6)+ 12 ;
            if (value >= 12) {
                value -= 12;
            }
            _hour = floor(value);
            if (_changeHourBlock) {
                _changeHourBlock(_hour);
            }
            break;
        }
        case kMinute:
        {
            self.minuteView.transform = CGAffineTransformMakeRotation(degree);
            CGFloat value = degree / (M_PI/30) + 60;
            if (value >= 60) {
                value -= 60;
            }
            _minute = floor(value);
            if (_changeMinuteBlock) {
                _changeMinuteBlock(_minute);
            }
            break;
        }
        case kSecond:
        {
            self.secondView.transform = CGAffineTransformMakeRotation(degree);
            CGFloat value = degree / (M_PI/30) + 60;
            if (value >= 60) {
                value -= 60;
            }
            _second = floor(value);
            if (_changeSecondBlock) {
                _changeSecondBlock(_second);
            }
            break;
        }
        default:
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self];
    CGFloat degree = atan2(point.y-_startPointerValue.y,point.x-_startPointerValue.x);
//    if (degree > M_PI*2) {//大于 M_PI*2(360度) 角度再次从0开始
//        degree = 0;
//    }
    switch (_type) {
        case kHour:
        {
            self.hourView.transform = CGAffineTransformMakeRotation(degree);
            CGFloat value = degree / (M_PI/6)+ 12 ;
            if (value >= 12) {
                value -= 12;
            }
            _hour = floor(value);
            if (_changeHourBlock) {
                _changeHourBlock(_hour);
            }
            break;
        }
        case kMinute:
        {
            self.minuteView.transform = CGAffineTransformMakeRotation(degree);
            CGFloat value = degree / (M_PI/30) + 60;
            if (value >= 60) {
                value -= 60;
            }
            _minute = floor(value);
            if (_changeMinuteBlock) {
                _changeMinuteBlock(_minute);
            }
            break;
        }
        case kSecond:
        {
            self.secondView.transform = CGAffineTransformMakeRotation(degree);
            CGFloat value = degree / (M_PI/30) + 60;
            if (value >= 60) {
                value -= 60;
            }
            _second = floor(value);
            if (_changeSecondBlock) {
                _changeSecondBlock(_second);
            }
            break;
        }
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


@end