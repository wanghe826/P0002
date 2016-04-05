//
//  SplashViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/18.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "SplashViewController.h"
#import "SearchWatchViewController.h"
#import "AppUtils.h"

@interface SplashViewController ()<UIScrollViewDelegate>
{
    UIButton* _beginBtn;
    NSArray *arr;
    
}
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [self makeLaunchView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeLaunchView
{
 
    if([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
    {
         arr = [NSArray arrayWithObjects:@"Pic_ydy_01副本",@"Pic_ydy_02副本",@"Pic_ydy_03副本",nil];
    }
    else
    {
        arr = [NSArray arrayWithObjects:@"lead1",@"lead2",@"lead3", nil];
    }
    
    UIScrollView *scr=[[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, screen_width, screen_height+20)];
    scr.contentSize=CGSizeMake(self.view.frame.size.width*arr.count, 0);
    scr.showsHorizontalScrollIndicator = NO;
    scr.showsVerticalScrollIndicator = NO;
    scr.pagingEnabled=YES;
    scr.delegate = self;
    scr.bounces = NO;
    [self.view addSubview:scr];
    for (int i=0; i<arr.count; i++)
    {
        UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(screen_width*i, 0, screen_width, screen_height)];
        img.image=[UIImage imageNamed:arr[i]];
        [scr addSubview:img];
    }
    
    _beginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _beginBtn.frame = CGRectMake(0, 0, 100, 50);
    _beginBtn.layer.cornerRadius = 10;
    [_beginBtn setBackgroundColor:[UIColor grayColor]];
    [_beginBtn setTitleColor:HexRGBAlpha(0xfdfdfd, 1.0) forState:UIControlStateNormal];
    [_beginBtn setTitleColor:HexRGBAlpha(0xfdfdfd, 0.5) forState:UIControlStateHighlighted];
    [_beginBtn setTitle:NSLocalizedStringFromTable(@"开始体验", @"Localizable", nil) forState:UIControlStateNormal];
//    [_beginBtn setTitle:@"开始体验" forState:UIControlStateNormal];
    _beginBtn.center = CGPointMake(self.view.center.x, screen_height-50);
    [self.view addSubview:_beginBtn];
    [_beginBtn addTarget:self action:@selector(begin) forControlEvents:UIControlEventTouchUpInside];
    _beginBtn.hidden = YES;
}

- (void) begin
{
    BOOL BleStateOn = [ApplicationDelegate checkBleStateOn];
    if(!BleStateOn)
    {
        return;
    }
    
    SearchWatchViewController* searchVc = [[SearchWatchViewController alloc] init];
    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:searchVc];
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}


#pragma scrollView

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.x>=screen_width*2)
    {
        _beginBtn.hidden = NO;
    }
    else
    {
        _beginBtn.hidden = YES;
    }
}


@end
