//
//  PairedViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/6.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "PairedViewController.h"
#import "Masonry.h"
#import "CoreText/CoreText.h"
#import "HelpViewController.h"
#import "JGBleDeviceInfo.h"

@implementation PairedViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = CGRectZero;
    if (screen_height == 568)
    {
        rect = CGRectMake(0,0,190,190);
    }
    else if (screen_height == 667)
    {
        rect = CGRectMake(0, 0, 250, 250);
    }
    else if(screen_height == 736)
    {
        rect = CGRectMake(0, 0, 280, 280);
    }
    else
    {
        rect = CGRectMake(0,0,170,170);
    }
    self.title = NSLocalizedString(@"手表配对", nil);
    
    _hsaSearchSuccessed = NO;
    
    
    _watchBackground = [[UIImageView alloc] initWithFrame:rect];
    _watchBackground.image = [UIImage imageNamed:@"img_bluetooth_clock_searching"];
    _watchBackground.center = CGPointMake(self.view.center.x, self.view.center.y+20);
    [self.view addSubview:_watchBackground];
    _tailView = [[UIImageView alloc] initWithFrame:rect];
    _tailView.image = [UIImage imageNamed:@"img_searching_tail"];
    _tailView.center = _watchBackground.center;
    [self.view addSubview:_tailView];
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_searchBtn addTarget:self action:@selector(searchWatchAction) forControlEvents:UIControlEventTouchUpInside];
    _searchBtn.frame = CGRectMake(0, 0, 64, 64);
    [_searchBtn setBackgroundImage:[UIImage imageNamed:@"btn_conect_avr"] forState:UIControlStateNormal];
    [_searchBtn setBackgroundImage:[UIImage imageNamed:@"btn_conect_avr"] forState:UIControlStateHighlighted];
    [_searchBtn setTitle:NSLocalizedString(@"搜索", nil) forState:UIControlStateNormal];
    [_searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _searchBtn.center = _watchBackground.center;
    [self.view addSubview:_searchBtn];
    
    [self initLabel];
}

- (void) searchButtonAnimation
{
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.5];
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.repeatCount = MAXFLOAT;
    scaleAnimation.duration = 0.8;
    [_searchBtn.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}


- (void) searchWatchAction
{
    if([BLEAppContext shareBleAppContext].isConnected)
    {
        [[JGBLEManager sharedManager] cancelDeviceConnect];
    }
    
    _helpLabel.hidden = YES;
    _topLabel.text = NSLocalizedString(@"正在搜索华唛手表", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchSuccess:) name:BLEDiscoverWatchNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoverCBPeripheralsNotification object:nil];
    _tailView.hidden = NO;
    if(!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(searchWatchAnimation) userInfo:nil repeats:YES];
    }
    if(![_timer isValid])
    {
        [_timer fire];
    }
    
    [_authorizedTimer invalidate];
    _authorizedTimer = nil;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_hsaSearchSuccessed==NO)
        {
            [self searchFailed:NSLocalizedString(@"连接失败", nil)];
        }
    });
    
}
- (void) searchWatchAnimation
{
    static float degree = 2*M_PI/12;
    _tailView.transform = CGAffineTransformMakeRotation(degree);
    degree+=2*M_PI/12;
}


- (void) searchFailed:(NSString*)hintString
{
//    [_searchBtn.layer removeAnimationForKey:@"scaleAnimation"];
   
//    [_searchBtn setTitle:NSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
    
    [_timer invalidate];
    _timer = nil;
    
    if(!_helpLabel)
    {
        _helpLabel = [[HelpLabelView alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
        HelpViewController* helpVc = [HelpViewController new];
        __block PairedViewController* anObject = self;
        _helpLabel.pushVc = ^{
            [anObject.navigationController pushViewController:helpVc animated:YES];
        };
        _helpLabel.center = CGPointMake(self.view.center.x, screen_height-100);
        [self.view addSubview:_helpLabel];
    }
    else
    {
        _helpLabel.hidden = NO;
    }
    
    
    _topLabel.text = hintString;
    _hintLabel.text = NSLocalizedString(@"请确保手表有电，打开蓝牙并靠近手机", nil);
}

//收到搜索成功的通知
- (void) searchSuccess:(NSNotification*)noti
{
   _hsaSearchSuccessed = YES;
    
//    _watchBackground.image = [UIImage imageNamed:@"img_search_clockbg"];
//    _watchBackground.frame = CGRectMake(_watchBackground.frame.origin.x+3, _watchBackground.frame.origin.y+5, _watchBackground.frame.size.width,_watchBackground.frame.size.height);
//    _watchBackground.contentMode = UIViewContentModeScaleAspectFill;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEDiscoverWatchNotification object:nil];
    JGBleDeviceInfo* info = [noti.userInfo objectForKey:@"device"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedSuccess) name:BLEDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEConnectNotification object:nil userInfo:@{BLEConnectCBPeripheralKey:info}];
}

//收到连接成功的通知
- (void) connectedSuccess
{
    _topLabel.text = NSLocalizedString(@"正在连接", nil);
    _hintLabel.text = NSLocalizedString(@"请等待手表震动三次后晃动手表确认连接", nil);

    [_timer invalidate];
    _timer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorizedSuccess) name:BLEAuthorizedSuccessNotification object:nil];
    
    if(_authorizedTimer == nil)
    {
        _authorizedTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(authorizedTimeOut) userInfo:nil repeats:NO];
    }
}

- (void) authorizedTimeOut
{
    if([BLEAppContext shareBleAppContext].isAuthorized == NO)
    {
        _hsaSearchSuccessed = NO;
        [[JGBLEManager sharedManager] cancelDeviceConnect];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchSuccess:) name:BLEDiscoverWatchNotification object:nil];
        [self searchFailed:NSLocalizedString(@"连接失败", nil)];
    }
}


//收到授权成功的通知
- (void) authorizedSuccess
{
   [self.navigationController popViewControllerAnimated:YES];
}


- (void) initLabel
{
    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    [_topLabel setFont:[UIFont systemFontOfSize:17]];
    _topLabel.text = NSLocalizedString(@"正在搜索华唛手表", nil);
    _topLabel.textColor = RGBColor(0x09, 0x09, 0x09);
    _topLabel.center = CGPointMake(self.view.center.x, 104);
    [self.view addSubview:_topLabel];
    
    _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    _hintLabel.numberOfLines = 0;
    _hintLabel.textColor = HexRGBAlpha(0x090909, 0.5);
    [_hintLabel setFont:[UIFont systemFontOfSize:12]];
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.text = NSLocalizedString(@"请确保手表有电，打开蓝牙并靠近手机", nil);
    _hintLabel.center = CGPointMake(self.view.center.x, _topLabel.center.y+40);
    [self.view addSubview:_hintLabel];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addNotification];
    [[JGBLEManager sharedManager] stopRetrieveConnTimer];
    [BLEAppContext shareBleAppContext].isInSearchVC = YES;
    [self searchWatchAction];
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotification];
    if(![BLEAppContext shareBleAppContext].isConnected)
    {
        [[JGBLEManager sharedManager] startRetrieveConnTimer];
    }
    [BLEAppContext shareBleAppContext].isInSearchVC = NO;
}


- (void) addNotification
{
    NSArray *notificationNames = @[BLEBleStateOnNotification,BLEDiscoveredDeviceNotification,BLEDidFinishScanNotification,BLEDidFailConnectNotification,BLEDidConnectedNotification,BLEAuthorizedSuccessNotification];
    for (NSString *notificationName in notificationNames) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotification:) name:notificationName object:nil];
    }
}

- (void) removeNotification
{
    NSArray *notificationNames = @[BLEBleStateOnNotification,BLEDiscoveredDeviceNotification,BLEDidFinishScanNotification,BLEDidFailConnectNotification,BLEDidConnectedNotification,BLEAuthorizedSuccessNotification];
    for (NSString *notificationName in notificationNames) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    }
}

- (void)dealWithNotification:(NSNotification *)noti {
    NSString *name = noti.name;
    NSDictionary *userInfo = noti.userInfo;
    if ([name isEqualToString:BLEDidFinishScanNotification])
    {
//        [self searchFailed];
    }
    else if ([name isEqualToString:BLEDidFailConnectNotification])
    {
    }
    else if ([name isEqualToString:BLEDiscoveredDeviceNotification])
    {
        
    }
    else if ([name isEqualToString:BLEBleStateOnNotification])
    {
    }
//    else if([name isEqualToString:BLEDidConnectedNotification])
    else if([name isEqualToString:BLEAuthorizedSuccessNotification])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([name isEqualToString:BLEDiscoverWatchNotification])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEDiscoverWatchNotification object:nil];
        
        JGBleDeviceInfo* info = [userInfo objectForKey:@"device"];
        _deviceInfo = info;
        [self performSelectorOnMainThread:@selector(searchSuccess:) withObject:nil waitUntilDone:YES];
        [[JGBLEManager sharedManager] connectDeviceByIdentifier:_deviceInfo.identifier timeout:3];
    }
}


@end


@implementation HelpLabelView

- (instancetype) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
    CGContextConcatCTM(ctx, flipVertical);
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"获取帮助", nil)];
    UIFont* font = [UIFont systemFontOfSize:14];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:CFBridgingRelease(fontRef) range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)RGBColor(0xef, 0x3d, 0x3f).CGColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:(__bridge id _Nonnull )((__bridge CFNumberRef)[NSNumber numberWithInt:0x01]) range:NSMakeRange(0, attributedString.length)];
    
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);
    CFRetain(ctFramesetter);
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    CGPathAddRect(path, NULL, bounds);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), path, NULL);
    CFRetain(ctFrame);
    CTFrameDraw(ctFrame,ctx);
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.pushVc)
    {
        _pushVc();
    }
}


@end
