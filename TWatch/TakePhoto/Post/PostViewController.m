//
//  PostViewController.m
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-21.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

/**
 本部分代码实现的功能就是拍照
 */

#import "PostViewController.h"

@interface PostViewController ()

@end

//就这个界面根本没有必要写那么多代码。
@implementation PostViewController

//从某bundle中的nib文件进行load。
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    这就是一个单纯的从父类继承而已。
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    如果有照片就加载图片视图。
    if (_postImage) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:_postImage];
//        子视图的边界是否被限制在父视图的边框之中。
        imgView.clipsToBounds = YES;
//        这是设置内容的填充模式。
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
        imgView.center = self.view.center;
        [self.view addSubview:imgView];
//        这个过程实际上就是把照片添加到子视图中并把子视图添加到self.view的过程。
    }
    
//    这是设定一个圆角矩形按钮。
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    这种设定按钮的frame的方式是极其不好的。
    backBtn.frame = CGRectMake(0, self.view.frame.size.height - 40, 80, 40);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
//    这实际上就是在导航栏上面添加返回按钮，太简单了。
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBtnPressed:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}






@end
