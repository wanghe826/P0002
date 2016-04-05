//
//  MovementRemindSettingViewController.m
//  TWatch
//
//  Created by Bob on 15/6/25.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "MovementRemindSettingViewController.h"

@interface MovementRemindSettingViewController ()

@property(nonatomic,strong) UIImageView *bgView;

@end

@implementation MovementRemindSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"目标设置", @"Localizable", nil);
    [self initNavigationBarView];
    [self.view addSubview:self.bgView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBarView
{
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:@"navagation_back_nor"] forState:UIControlStateNormal];
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    
//    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = NO;
    //    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImageView *)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIImageView alloc]init];
        _bgView.frame = CGRectMake(0, 64, screen_width, 320);
        _bgView.image = [UIImage imageNamed:@"move_setting"];
    }
    return _bgView;
}


@end
