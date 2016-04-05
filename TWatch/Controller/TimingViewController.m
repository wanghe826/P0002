//
//  TimingViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/6.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "TimingViewController.h"
#import "AppUtils.h"

@implementation TimingViewController


- (void) viewDidLoad
{
    [super viewDidLoad];

    if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"]) {
        
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_timing_synchronize_avr_en"] forState:UIControlStateNormal];
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_timing_synchronize_sel_en"] forState:UIControlStateHighlighted];
        
    }else
    {
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_timing_synchronize_avr"] forState:UIControlStateNormal];
        [_syncTimeBtn setImage:[UIImage imageNamed:@"btn_timing_synchronize_sel"] forState:UIControlStateHighlighted];
    }
    
    
    self.view.backgroundColor = RGBColor(0xfd, 0xfd, 0xfd);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
    self.title = NSLocalizedString(@"智能校时", nil);
    
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    self.navigationController.navigationBarHidden = NO;
    

    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.layer.borderColor = [UIColor grayColor].CGColor;
    backBtn.frame = CGRectMake(0, screen_height - 40, screen_width, 40);
    backBtn.backgroundColor = [UIColor whiteColor];
//    [backBtn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(startActionHandle) forControlEvents:UIControlEventTouchUpInside];
    [backBtn addTarget:self action:@selector(returnBackToFunction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height-40, screen_width, 1)];
    separator.backgroundColor = SeparatorColor;
    [self.view addSubview:separator];
    
    
    _topHintLabel.text = NSLocalizedString(@"手表现在的指针指向是？", nil);
    _topHintLabel.textColor = HexRGBAlpha(0x090909, 0.5);
    
    _watchView.image = [UIImage imageNamed:@"img_timing_clock"];
    _hourView.image = [UIImage imageNamed:@"img_timing_pointer_hour_avr"];
    _minuteView.image = [UIImage imageNamed:@"img_timing_pointer_min_avr"];
    _secondView.image = [UIImage imageNamed:@"img_timing_pointer_sec_sel"];
    _hourLabel.textColor = HexRGBAlpha(0x090909, 0.5);
    _minLabel.textColor = HexRGBAlpha(0x090909, 0.5);
    _secondLabel.textColor = RGBColor(0xef, 0x3d, 0x3f);
}

- (void) returnBackToFunction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUEndWhenAdjustTimeNotification object:nil];
    
    [_timeOutTimer invalidate];
    _timeOutTimer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(timeOutExit) userInfo:nil repeats:NO];
}

- (void) timeOutExit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUEndWhenAdjustTimeNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super stopActionHint];
    
    [self resetTimer];
    _syncTimeBtn.hidden = NO;
    
    UITouch* touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    if(CGRectContainsPoint(_hourLabel.frame, currentPoint))
    {
        _hourLabel.textColor = [UIColor redColor];
        [_hourLabel setFont:[UIFont systemFontOfSize:40]];
        _hourView.image = [UIImage imageNamed:@"img_timing_pointer_hour_sel"];
        [self.view bringSubviewToFront:_hourView];
        _currentSelectHand = HourHand;
        
        _minLabel.textColor = HexRGBAlpha(0x090909, 0.5);
        [_minLabel setFont:[UIFont systemFontOfSize:32]];
        _minuteView.image = [UIImage imageNamed:@"img_timing_pointer_min_avr"];
        
        _secondLabel.textColor = HexRGBAlpha(0x090909, 0.5);
        [_secondLabel setFont:[UIFont systemFontOfSize:32]];
        _secondView.image = [UIImage imageNamed:@"img_timing_pointer_sec_avr"];
    }
    else if(CGRectContainsPoint(_minLabel.frame, currentPoint))
    {
        [_hourLabel setFont:[UIFont systemFontOfSize:32]];
        _hourLabel.textColor = HexRGBAlpha(0x090909, 0.5);
        _hourView.image = [UIImage imageNamed:@"img_timing_pointer_hour_avr"];
        
        [_minLabel setFont:[UIFont systemFontOfSize:40]];
        _minLabel.textColor = [UIColor redColor];
        _minuteView.image = [UIImage imageNamed:@"img_timing_pointer_min_sel"];
        [self.view bringSubviewToFront:_minuteView];
        _currentSelectHand = MinuteHand;
        
        [_secondLabel setFont:[UIFont systemFontOfSize:32]];
        _secondLabel.textColor = HexRGBAlpha(0x090909, 0.5);
        _secondView.image = [UIImage imageNamed:@"img_timing_pointer_sec_avr"];
    }
    else if(CGRectContainsPoint(_secondLabel.frame, currentPoint))
    {
        [_hourLabel setFont:[UIFont systemFontOfSize:32]];
        _hourLabel.textColor = HexRGBAlpha(0x090909, 0.5);
        _hourView.image = [UIImage imageNamed:@"img_timing_pointer_hour_avr"];
        
        [_minLabel setFont:[UIFont systemFontOfSize:32]];
        _minLabel.textColor = HexRGBAlpha(0x090909, 0.5);
        _minuteView.image = [UIImage imageNamed:@"img_timing_pointer_min_avr"];
        
        [_secondLabel setFont:[UIFont systemFontOfSize:40]];
        _secondLabel.textColor = [UIColor redColor];
        _secondView.image = [UIImage imageNamed:@"img_timing_pointer_sec_sel"];
        [self.view bringSubviewToFront:_secondView];
        _currentSelectHand = SecondHand;
    }
}


- (void) startActionHandle
{
    //步骤3
    //走针
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEMCUEndWhenAdjustTimeNotification object:nil];
    
    [_syncTimeBtn removeFromSuperview];
    for(UIView* view in self.view.subviews)
    {
        if([view isKindOfClass:[UILabel class]])
        {
            [view removeFromSuperview];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
