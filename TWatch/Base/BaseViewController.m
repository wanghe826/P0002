//
//  BaseViewController.m
//  Template
//
//  Created by Bob on 12-4-28.
//  父控制器
//

#import "BaseViewController.h"

@interface BaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.view.backgroundColor = RGBColor(0x2f, 0x34, 0x3e);
    self.navigationController.navigationBar.hidden = YES;
    
    if (screen_height == 568)
    {
        kWatchRect = CGRectMake(0,0,190,190);
    }
    else if (screen_height == 667)
    {
        kWatchRect = CGRectMake(0, 0, 250, 250);
    }
    else if(screen_height == 736)
    {
        kWatchRect = CGRectMake(0, 0, 280, 280);
    }
    else
    {
        kWatchRect = CGRectMake(0,0,150,150);
    }
    
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}


//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if(self.navigationController.viewControllers.count == 1)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
