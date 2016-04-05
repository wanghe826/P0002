//
//  SuccSearchViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "SuccSearchViewController.h"
#import "AutoTimingViewController.h"

@implementation SuccSearchViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    _hasConnected = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[JGBLEManager sharedManager] stopRetrieveConnTimer];
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectedSuccess) name:BLEDidConnectedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthorizedSuccess) name:BLEAuthorizedSuccessNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEConnectNotification object:nil userInfo:@{BLEConnectCBPeripheralKey:self.deviceInfo}];
    [BLEAppContext shareBleAppContext].isInSearchVC = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JGBLEManager sharedManager] startRetrieveConnTimer];
    [BLEAppContext shareBleAppContext].isInSearchVC = NO;
}

- (void)initUI
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    label.text = NSLocalizedString(@"成功搜索到华唛手表", nil);
    label.textColor = RGBColor(0xfd, 0xfd, 0xfd);
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(self.view.center.x, 100);
    _titleLabel = label;
    [self.view addSubview:label];
    
    UILabel* label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    label2.text = NSLocalizedString(@"点击图标当手表震动时翻转手表即可连接", nil);
    [label2 setFont:[UIFont systemFontOfSize:14]];
    label2.textColor = HexRGBAlpha(0xfdfdfd, 0.5);
    label2.textAlignment = NSTextAlignmentCenter;
    [label2 sizeToFit];
    label2.center = CGPointMake(self.view.center.x, 150);
    [self.view addSubview:label2];
    
    CGFloat height = 630;
    CGRect backViewRect = CGRectMake(0, 0, 200, 350);
    
    if(screen_height == 568)
    {
        height = 680;
    }
    else if(screen_height == 667)
    {
        backViewRect = CGRectMake(0, 0, 300, 500);
        height = 725;
    }
    else if(screen_height == 736)
    {
        backViewRect = CGRectMake(0, 0, 300, 500);
        height = 760;
    }
    
    
    UIImageView* backView = [[UIImageView alloc] initWithFrame:backViewRect];
    backView.image = [UIImage imageNamed:@"img_first_searching_clockbg"];
    backView.center = CGPointMake(self.view.center.x, self.view.center.y+50);
    backView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:backView];
    
    UIButton* watchView = [UIButton buttonWithType:UIButtonTypeCustom];
    [watchView setTitle:NSLocalizedString(@"连接", nil) forState:UIControlStateNormal];
    watchView.layer.cornerRadius = 36;
    watchView.frame = CGRectMake(100, 100, 80, 80);
    watchView.layer.masksToBounds = YES;
    [watchView setBackgroundImage:[UIImage imageNamed:@"btn_conect_avr"] forState:UIControlStateNormal];
    [watchView setBackgroundImage:[UIImage imageNamed:@"btn_conect_sel"] forState:UIControlStateHighlighted];
    [watchView addTarget:self action:@selector(connnnect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:watchView];

    
    watchView.center = CGPointMake(self.view.center.x, 0);
    [self.view addSubview:watchView];
    
    UIDynamicAnimator* animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:watchView attachedToAnchor:CGPointMake(self.view.center.x-8, height)];
    [attachmentBehavior setLength:350];
    [attachmentBehavior setDamping:0.05];
    [attachmentBehavior setFrequency:5];
    [animator addBehavior:attachmentBehavior];
    
    self.animator = animator;
}

- (void) connnnect:(UIButton*)sender
{
    if(_hasConnected==NO)
    {
        return;
    }
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.5];
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.repeatCount = MAXFLOAT;
    scaleAnimation.duration = 0.8;
    [sender.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
    [sender setTitle:NSLocalizedString(@"连接中", nil) forState:UIControlStateNormal];
    sender.enabled = NO;
    
    //请求授权
    if(_hasConnected)
    {
        [[JGBLEManager sharedManager] requestAuthorizedFromWatch:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([BLEAppContext shareBleAppContext].isInSearchVC == YES)
            {
                _titleLabel.text = NSLocalizedString(@"连接华唛手表失败", nil);
                [sender.layer removeAnimationForKey:@"scaleAnimation"];
                [sender setTitle:NSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
                sender.enabled = YES;
            }
        });
    }
}


#pragma 连接成功
- (void) didConnectedSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEDidConnectedNotification object:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        AutoTimingViewController* timingVc = [[AutoTimingViewController alloc] init];
//        [self.navigationController pushViewController:timingVc animated:YES];
//    });
    _hasConnected = YES;
}

- (void) didAuthorizedSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLEAuthorizedSuccessNotification object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AutoTimingViewController* timingVc = [[AutoTimingViewController alloc] init];
        [self.navigationController pushViewController:timingVc animated:YES];
    });
}


@end


@implementation WatchView
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = HexRGBAlpha(0x2f343e, 0);
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0f);
    UIColor* aColor = [UIColor blueColor];
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.width/2, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    UIFont* font = [UIFont systemFontOfSize:25];
    [@"连接" drawInRect:CGRectMake(rect.origin.x+17, rect.origin.y+25, rect.size.width, rect.size.height) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.callback)
    {
        _callback();
    }
}


@end
