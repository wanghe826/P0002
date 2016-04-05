//
//  SearchWatchViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "SearchWatchViewController.h"
#import "CoreText/CoreText.h"
#import "SuccSearchViewController.h"
#import "HelpViewController.h"
#import "AutoTimingViewController.h"

#define kSearchTimeout  30

@implementation SearchWatchViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    _hasAlreadySearchedWatch = NO;
    [self initUI];
    
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BLEAppContext shareBleAppContext].isInSearchVC = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disCoveredWatch:) name:BLEDiscoverWatchNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthorizedSuccess) name:BLEAuthorizedSuccessNotification object:nil];


    dispatch_async(dispatch_get_main_queue(), ^{
        //一定要在主线程调用 蓝牙搜索 函数?
        [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoverCBPeripheralsNotification object:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSearchTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_hasAlreadySearchedWatch==NO)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:BLEStopScanDevice object:nil];
//            _labelView.labelStr = NSLocalizedString(@"未发现华唛手表", nil);
            _labelView.text = NSLocalizedString(@"连接失败", nil);
            [_labelView setNeedsDisplay];
            [self searchWatchFailed:NSLocalizedString(@"请确保手表有电，打开蓝牙并靠近手机", nil)];
        }
    });
}
//成功连接到手表的通知
- (void) didConnected
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEDidConnectedNotification object:nil];
    [_labelView performSelectorOnMainThread:@selector(setText:) withObject:NSLocalizedString(@"正在连接", nil) waitUntilDone:YES];
    [_hintLabel performSelectorOnMainThread:@selector(setText:) withObject:NSLocalizedString(@"请等待手表震动三次后晃动手表确认连接", nil) waitUntilDone:YES];
    
    [_timer invalidate];
    _timer = nil;
    _tailView.hidden = YES;
    
    if(_authorizedTimer == nil)
    {
        _authorizedTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(authorizedTimeout) userInfo:nil repeats:NO];
    }
}


- (void) authorizedTimeout
{
    if([BLEAppContext shareBleAppContext].isAuthorized==NO)
    {
        _labelView.text = NSLocalizedString(@"连接失败", nil);
        [[JGBLEManager sharedManager] cancelDeviceConnect];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disCoveredWatch:) name:BLEDiscoverWatchNotification object:nil];
        [self searchWatchFailed:NSLocalizedString(@"请确保手表有电，打开蓝牙并靠近手机", nil)];
    }
}

//成功搜索到手表的通知
- (void) disCoveredWatch:(NSNotification*)noti
{
    //搜索到之后要删除掉监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEDiscoverWatchNotification object:nil];
    _hasAlreadySearchedWatch = YES;
    NSDictionary* dic = noti.userInfo;
    JGBleDeviceInfo* info = [dic objectForKey:@"device"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnected) name:BLEDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEConnectNotification object:nil userInfo:@{BLEConnectCBPeripheralKey:info}];
}

//收到授权成功的通知
- (void) didAuthorizedSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEAuthorizedSuccessNotification object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AutoTimingViewController* timingVc = [[AutoTimingViewController alloc] init];
        [self.navigationController pushViewController:timingVc animated:YES];
    });
}

- (void) searchWatchFailed:(NSString*)hintString
{
    _hintLabel.text = hintString;
    [_timer invalidate];
    _timer = nil;
    _tailView.hidden = YES;
//    
//    if(!_researchBtn)
//    {
//        _researchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [_researchBtn setBackgroundImage:[UIImage imageNamed:@"btn_first_research_avr"] forState:UIControlStateNormal];
//        [_researchBtn setBackgroundImage:[UIImage imageNamed:@"btn_first_research_sel"] forState:UIControlStateHighlighted];
//        _researchBtn.frame = CGRectMake(0, 0, 150, 25);
//        [_researchBtn addTarget:self action:@selector(researchWatch) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_researchBtn];
//        _researchBtn.center = CGPointMake(self.view.center.x, screen_height-95);
//    }
//    else
//    {
//        _researchBtn.hidden = NO;
//    }
    
    
    if(!_helpBtn)
    {
        _helpBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _helpBtn.frame = CGRectMake(0, 0, 70, 30);
        [_helpBtn setTitleColor:HexRGBAlpha(0xef3d3f, 0.8) forState:UIControlStateNormal];
        NSMutableAttributedString* titleString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"获取帮助", nil)];
        [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, titleString.length)];
        [titleString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,titleString.length)];
        [_helpBtn setAttributedTitle:titleString forState:UIControlStateNormal];
        [_helpBtn addTarget:self action:@selector(toHelp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_helpBtn];
        _helpBtn.center = CGPointMake(self.view.center.x, screen_height-60);
    }
    else
    {
        _helpBtn.hidden = NO;
    }
}

- (void) researchWatch
{
    if(!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(searchWatch) userInfo:nil repeats:YES];
    }
    [_timer fire];
    
    [_authorizedTimer invalidate];
    _authorizedTimer = nil;
    
    if([BLEAppContext shareBleAppContext].isConnected)
    {
        [[JGBLEManager sharedManager] cancelDeviceConnect];
    }
    
    _hasAlreadySearchedWatch = NO;
    _labelView.text = NSLocalizedString(@"正在搜索华唛手表", nil);
    [_labelView setNeedsDisplay];
//    _researchBtn.hidden = YES;
    _helpBtn.hidden = YES;
    _tailView.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disCoveredWatch:) name:BLEDiscoverWatchNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoverCBPeripheralsNotification object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSearchTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_hasAlreadySearchedWatch==NO)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:BLEStopScanDevice object:nil];
            _labelView.text = NSLocalizedString(@"连接失败", nil);
            [_labelView setNeedsDisplay];
            [self searchWatchFailed:NSLocalizedString(@"请确保手表有电，打开蓝牙并靠近手机", nil)];
        }
    });
    
}

- (void) toHelp
{
    HelpViewController* helpVc = [HelpViewController new];
    [self.navigationController pushViewController:helpVc animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([_timer isValid])
    {
        [_timer invalidate];
    }
    _timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEDiscoverWatchNotification object:nil];
    [BLEAppContext shareBleAppContext].isInSearchVC = NO;
}

- (void) initUI
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    _labelView = [[UILabel alloc] initWithFrame:CGRectMake(50, 140, 250, 50)];
//    _labelView.labelStr = NSLocalizedString(@"正在搜索华唛手表", nil);
    _labelView.text = NSLocalizedString(@"正在搜索华唛手表", nil);
    _labelView.textColor = RGBColor(0xfd, 0xfd, 0xfd);
    _labelView.numberOfLines = 0;
    _labelView.font = [UIFont systemFontOfSize:17];
    _labelView.textAlignment = NSTextAlignmentCenter;
    _labelView.center = CGPointMake(self.view.center.x, 100);
    [self.view addSubview:_labelView];
    
    _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 40, 60)];
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.numberOfLines = 0;
    _hintLabel.text = NSLocalizedString(@"请确保手表有电，打开蓝牙并靠近手机", nil);
    
    [_hintLabel sizeToFit];
    [_hintLabel setFont:[UIFont systemFontOfSize:14]];
    _hintLabel.textColor = HexRGBAlpha(0xfdfdfd, 0.5);
    _hintLabel.center = CGPointMake(self.view.center.x, 150);
    [self.view addSubview:_hintLabel];
    
    [self addSearchWatchView];
}

- (void) addSearchWatchView
{
    UIImageView* watchView = [[UIImageView alloc] initWithFrame:kWatchRect];
    watchView.contentMode = UIViewContentModeScaleAspectFit;
    watchView.image = [UIImage imageNamed:@"img_first_bluetooth_clock_searching"];
    watchView.center = CGPointMake(self.view.center.x, self.view.center.y+50);
    [self.view addSubview:watchView];
    
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_searchBtn addTarget:self action:@selector(researchWatch) forControlEvents:UIControlEventTouchUpInside];
    _searchBtn.frame = CGRectMake(0, 0, 64, 64);
    [_searchBtn setBackgroundImage:[UIImage imageNamed:@"btn_conect_avr"] forState:UIControlStateNormal];
    [_searchBtn setBackgroundImage:[UIImage imageNamed:@"btn_conect_avr"] forState:UIControlStateHighlighted];
    [_searchBtn setTitle:NSLocalizedString(@"搜索", nil) forState:UIControlStateNormal];
    [_searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _searchBtn.center = watchView.center;
    [self.view addSubview:_searchBtn];
    
    
    _tailView = [[UIImageView alloc] initWithFrame:kWatchRect];
    _tailView.image = [UIImage imageNamed:@"img_searching_tail"];
    _tailView.center = watchView.center;
    [self.view addSubview:_tailView];
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(searchWatch) userInfo:nil repeats:YES];
}


- (void) searchWatch
{
    static float degree = 2*M_PI/12;
    _tailView.transform = CGAffineTransformMakeRotation(degree);
    degree+=2*M_PI/12;
}



@end


@implementation LabelView

- (instancetype) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = RGBColor(0x2f, 0x34, 0x3e);
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
    CGContextConcatCTM(ctx, flipVertical);
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:self.labelStr];
    UIFont* font = [UIFont systemFontOfSize:18];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:CFBridgingRelease(fontRef) range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)RGBColor(0xfd, 0xfd, 0xfd).CGColor range:NSMakeRange(0, attributedString.length)];
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);
    CFRetain(ctFramesetter);
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    CGPathAddRect(path, NULL, bounds);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), path, NULL);
    CFRetain(ctFrame);
    CTFrameDraw(ctFrame,ctx);
}

@end
