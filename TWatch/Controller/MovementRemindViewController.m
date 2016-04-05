//
//  MovementRemindViewController.m
//  TWatch
//
//  Created by Bob on 15/6/6.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "MovementRemindViewController.h"
#import "MovementRemindSettingViewController.h"
#import "MovementRemindView.h"
#import "SportSleepSettingViewController.h"

#import "SVProgressHUD.h"
#import "SportsDataUtil.h"

@interface MovementRemindViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong) UIScrollView *rootView;

@property(nonatomic,strong) MovementRemindView *movemntView;

@end

@implementation MovementRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"运动", nil);
    [self initNavigationBarView];
    [self.view addSubview:self.movemntView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = RGBColor(53, 151, 243);
    [self.movemntView tochangedata];
}

- (void)initNavigationBarView
{
    UIButton *btnBack=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnBack.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:@"navagation_back_nor"] forState:UIControlStateNormal];
    UIBarButtonItem *itemBack=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem=itemBack;
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnShare.imageEdgeInsets=UIEdgeInsetsMake(0, 20, 0, 0);
    [btnShare addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [btnShare setImage:[UIImage imageNamed:@"top_share_icon"] forState:UIControlStateNormal];
    UIBarButtonItem *itemShare=[[UIBarButtonItem alloc]initWithCustomView:btnShare];
    self.navigationItem.rightBarButtonItem=itemShare;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = NO;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)share
{
    [self.movemntView setContentViewOffset];
    UIImage * image1;
    UIImage * image2;
    CGFloat offset;
    CGFloat hight = [UIScreen mainScreen].bounds.size.height;
    if (hight == 480)
    {
        offset = 124;
    }
    else if (hight == 568)
    {
        offset = 124;
    }
    else if (hight == 667)
    {
        offset = 120;
    }
    else if (hight == 736)
    {
        offset = 124;
    }
    if (hight == 480)
    {
        self.movemntView.rootView.contentOffset = CGPointMake(0, self.movemntView.rootView.contentSize.height*.6);
    }else self.movemntView.rootView.contentOffset = CGPointMake(0, self.movemntView.rootView.contentSize.height/2);
    
    image1 = [self imageFromView:self.view atFrame:[UIScreen mainScreen].bounds and:offset];
    self.movemntView.rootView.contentOffset = CGPointZero;
    image2 = [self imageFromView:self.view atFrame:[UIScreen mainScreen].bounds and:0];
    UIImage * image  =[self combine:image2 :image1];
    
    
    if (hight == 736)
    {
        image = image2;
    }
//    NSLog(@"image%@",NSStringFromCGSize(image.size));
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
//    [UMSocialData defaultData].extConfig.tencentData.shareImage = [UMSocialData defaultData].extConfig.tencentData.shareImage;
//    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
//    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
//    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
//    //QQ空间不支持纯图片的分享
//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:@"5572b7ca67e58ecdb0003f67"
//                                      shareText:@"T-Watch"
//                                     shareImage:image
//                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone, nil]
//                                       delegate:self];
    
}
//-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
//{
//    if (response.responseCode == UMSResponseCodeSuccess)
//    {
//        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"分享成功", nil)];
//    }
//}
- (MovementRemindView *)movemntView
{
    if (_movemntView == nil) {
        __weak id anObject = self;
        _movemntView = [[MovementRemindView alloc]initWithFrame:self.view.frame];
        _movemntView.gotoVc = ^(){
            SportSleepSettingViewController* moveVc = [[SportSleepSettingViewController alloc] init];
            [[(UIViewController*)anObject navigationController] pushViewController:moveVc animated:YES];
        };
    }
    return _movemntView;
}

//获得某个范围内的屏幕图像
- (UIImage *)imageFromView: (UIView *) theView   atFrame:(CGRect)r and:(CGFloat)top
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
    UIRectClip(CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height-top));
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 1);
    } else {
        UIGraphicsBeginImageContext(self.view.frame.size);
    }
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"%@",NSStringFromCGSize(theImage.size));
    CGFloat hight = [UIScreen mainScreen].bounds.size.height;
    //调整拼图
    if (hight == 667 && top != 0) {
        theImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(theImage.CGImage, CGRectMake(0, 380, self.view.frame.size.width, 40))];
    }
    else if ( hight == 568 & top != 0)
    {
        theImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(theImage.CGImage, CGRectMake(0, 273.5, self.view.frame.size.width, 300))];
    }
    else if (hight == 480 & top != 0)
    {
        theImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(theImage.CGImage, CGRectMake(0, 130, theImage.size.width, 400))];
    }
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}
#pragma mark - 图像拼接
- (UIImage *) combine:(UIImage*)leftImage :(UIImage*)rightImage {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = leftImage.size.height-64 + rightImage.size.height;
    CGSize offScreenSize = CGSizeMake(self.view.frame.size.width, height);
    
    UIGraphicsBeginImageContext(offScreenSize);
    
    CGRect rect = CGRectMake(0, 0, width, leftImage.size.height);
    [leftImage drawInRect:rect];
    
    rect.origin.y = leftImage.size.height;
    [rightImage drawInRect:CGRectMake(0, rect.origin.y, self.view.frame.size.width, rightImage.size.height)];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imagez;
}
//裁剪图片以用于适应当前更改.....
-(UIImage *)chableImage:(UIImage *)imageName LCwidth:(float)width TCheight:(float)height
{
    UIImage *sourceImage = imageName;
    UIImage *chableImage = [sourceImage  stretchableImageWithLeftCapWidth:width topCapHeight:height];
    return chableImage;
}

@end
