//
//  CustomViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/2.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "CustomViewController.h"
#import "UIImage+Addition.h"

@implementation CustomViewController

-(void) viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
    
    UIButton *btnNone=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnNone.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    UIBarButtonItem *itemNone=[[UIBarButtonItem alloc]initWithCustomView:btnNone];
    self.navigationItem.leftBarButtonItem=itemNone;
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    NSLog(@"-----视图个数是-> %lu", self.navigationController.viewControllers.count);
//    if(self.navigationController.viewControllers.count < 2)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view addSubview:self.backBtn];
}

-(UIButton*)backBtn
{
    if(!_backBtn)
    {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.tag = 2016;
        _backBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _backBtn.frame = CGRectMake(0, screen_height-40, screen_width, 40);
//        [_backBtn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        _backBtn.center = CGPointMake(self.view.center.x, screen_height-20);
        [_backBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
        UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, _backBtn.frame.origin.y, screen_width, 1)];
        view.tag = 2017;
        view.backgroundColor = SeparatorColor;
        [self.view addSubview:view];
    }
    return _backBtn;
}


-(void) returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

@end
