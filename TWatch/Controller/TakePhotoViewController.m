//
//  TakePhotoViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/12/21.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "Masonry.h"
#import "SCCommon.h"

@interface TakePhotoViewController ()
{
    BOOL _currentCameraFront;
    
    UIScrollView* _countTimeSelector;
    NSTimer* _timer;
    
    UIButton* _countDownBtn;
    
    UIButton* _selectPhotoBtn;
}

@end

@implementation TakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentCameraFront = NO;
    self.navigationController.navigationBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processTakePicture) name:@"takePhoto" object:nil];
    
    [self lll];
    [self initTakePhotoUI];
    
    _countDownBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _countDownBtn.center = self.view.center;
    _countDownBtn.backgroundColor = HexRGBAlpha(0x090909, 0.5);
    _countDownBtn.layer.cornerRadius = 22;
    [_countDownBtn setTitleColor:HexRGBAlpha(0xfdfdfd, 1.0) forState:UIControlStateNormal];
    [_countDownBtn setTitle:@"3" forState:UIControlStateNormal];
    [self.view addSubview:_countDownBtn];
    _countDownBtn.hidden = YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"takePhoto" object:nil];
}

- (void) lll
{
    SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
    
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, screen_width, screen_height);
    }
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    self.captureManager = manager;
    
    [_captureManager.session startRunning];
}


- (void)stillInCamera
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEOnTakePhotoVCNotification object:nil];
}

- (void) processTakePicture
{
    
    if(_countDownBtn.hidden == NO)
    {
        return;
    }
    
    int delay = (int)[[NSUserDefaults standardUserDefaults] integerForKey:DelayTakePhotoKey];
    
    if(delay!=0)
    {
        _countDownBtn.hidden = NO;
    }
    else
    {
        _countDownBtn.hidden = YES;
    }
    [self countDownFor:delay];
}

- (void)countDownFor:(int)seconds
{
    [_countDownBtn setTitle:[NSString stringWithFormat:@"%d", seconds] forState:UIControlStateNormal];
    if (seconds == 0) {
        _countDownBtn.hidden = YES;
        NSLog(@"智能拍照");
        [self takePhoto];
        return;
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self countDownFor:(seconds - 1)];
    });
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).isInCamera = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEOnTakePhotoVCNotification object:nil];
    
    if(!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(stillInCamera) userInfo:nil repeats:YES];
    }
    
    if(![_timer isValid])
    {
        [_timer fire];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).isInCamera = NO;
    if(_timer)
    {
        if([_timer isValid])
        {
            [_timer invalidate];
        }
    }
    _timer = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLENotOnTakePhotoVCNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) takePhoto
{
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actiView.center = self.view.center;
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    NSLog(@"拍照拍照--------");
    [self.captureManager takePicture:^(UIImage *stillImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SCCommon saveImageToPhotoAlbum:stillImage];//存至本机
        });
        
        [_selectPhotoBtn setBackgroundImage:stillImage forState:UIControlStateNormal];
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
    }];
}

- (void) initTakePhotoUI
{
    UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 75)];
    topView.backgroundColor = HexRGBAlpha(0x090909, 0.5);
    [self.view addSubview:topView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _countTimeSelector = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width/2, 40)];
    _countTimeSelector.contentSize = CGSizeMake(1800+8*1800/60, 0);
    _countTimeSelector.showsHorizontalScrollIndicator = NO;
    _countTimeSelector.showsVerticalScrollIndicator = NO;
    _countTimeSelector.delegate = self;
    
    int delayTime = (int)[[NSUserDefaults standardUserDefaults] integerForKey:DelayTakePhotoKey];
    
    for(int i=0; i<=59; i++)
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(4*1800/60+((i-1)*1800/60), 20, 1800/60, 20)];
        label.tag = 123+i;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%d",i];
        [label setFont:[UIFont systemFontOfSize:13]];
        label.textColor = HexRGBAlpha(0xfdfdfd, 0.8);
        
        [_countTimeSelector addSubview:label];
    }
    _countTimeSelector.center = topView.center;
    
    
    _countTimeSelector.contentOffset = CGPointMake(30*delayTime, 0);
    
    UILabel* initialLabel = (UILabel*)[_countTimeSelector viewWithTag:delayTime+123];
    initialLabel.text = [initialLabel.text stringByAppendingString:NSLocalizedString(@"秒", nil)];
//    initialLabel.textColor = [UIColor redColor];
    initialLabel.textColor = [UIColor whiteColor];
    initialLabel.textAlignment = NSTextAlignmentLeft;
    [initialLabel setFont:[UIFont systemFontOfSize:14]];
    
    [topView addSubview:_countTimeSelector];
//    UILabel* secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [secondLabel setFont:[UIFont systemFontOfSize:12]];
//    secondLabel.textAlignment = NSTextAlignmentCenter;
//    secondLabel.center = CGPointMake(_countTimeSelector.center.x+15, _countTimeSelector.center.y+10);
//    secondLabel.text = NSLocalizedString(@"秒", nil);
//    [topView addSubview:secondLabel];
    
    UILabel* delayLabel = [[UILabel alloc] initWithFrame:CGRectMake(_countTimeSelector.frame.origin.x-60, topView.center.y-5, 60, 30)];
    delayLabel.textAlignment = NSTextAlignmentRight;
    delayLabel.textColor = HexRGBAlpha(0xfdfdfd, 0.8);
    delayLabel.text = NSLocalizedString(@"延时", nil);
    [topView addSubview:delayLabel];
    
//    UIButton* takeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [takeBtn setTitle:@"拍照" forState:UIControlStateNormal];
//    [takeBtn setFrame:CGRectMake(20, 20, 100, 40)];
//    [takeBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:takeBtn];
    
    UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height-75, screen_width, 75)];
    bottomView.backgroundColor = HexRGBAlpha(0x090909, 0.5);
    [self.view addSubview:bottomView];
    
    _selectPhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_selectPhotoBtn setBackgroundImage:[UIImage imageNamed:@"icon_camera_photos"] forState:UIControlStateNormal];
    [bottomView addSubview:_selectPhotoBtn];
    [_selectPhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(bottomView);
        make.left.mas_equalTo(self.view).offset(30);
    }];
    [_selectPhotoBtn addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* takePhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takePhotoBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    [takePhotoBtn setBackgroundImage:[UIImage imageNamed:@"icon_camera_cut"] forState:UIControlStateNormal];
    [bottomView addSubview:takePhotoBtn];
    [takePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(bottomView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_cross"] forState:UIControlStateNormal];
    [bottomView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-30);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(bottomView);
    }];
    [closeBtn addTarget:self action:@selector(dismissVc) forControlEvents:UIControlEventTouchUpInside];
}

- (void) dismissVc
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) selectPhoto
{
    UIImagePickerController* pickVc = [[UIImagePickerController alloc] init];
    pickVc.delegate = self;
//    pickVc.allowsEditing = YES;
    pickVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickVc animated:YES completion:nil];
}

#pragma mark UIMagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage])
    {
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageView* iv= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
        [iv setImage:image];
        iv.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            [picker.view addSubview:iv];
        }];
        
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [iv addGestureRecognizer:tapGes];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.navigationController.navigationBar.alpha = 0.5;
}

- (void) tapImageView:(UITapGestureRecognizer*)ges
{
    UIImageView *view = (UIImageView*)[ges view];
    [UIView animateWithDuration:0.5 animations:^{
        [view removeFromSuperview];
    }];
}


- (void) switchCamera
{
    if(_currentCameraFront == NO)
    {
       [self.captureManager switchCamera:YES];
        _currentCameraFront = YES;
    }
    else
    {
        [self.captureManager switchCamera:NO];
        _currentCameraFront = NO;
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int count = ((int)scrollView.contentOffset.x)/30;
    
    if(count>=60)
    {
        count = 60;
    }
    
    if(count<=0)
    {
        count = 0;
    }
    
    [scrollView setContentOffset:CGPointMake(count*30, 0) animated:YES];
    
    
    NSLog(@"-------dddd %d", count);
    UILabel* label = [_countTimeSelector viewWithTag:count+123];
    label.textColor = HexRGBAlpha(0xfdfdfd, 1.0);
//    label.textColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%d%@",count, NSLocalizedString(@"秒", nil)];
    label.adjustsFontSizeToFitWidth = YES;
    [label setFont:[UIFont systemFontOfSize:14]];
    label.textAlignment = NSTextAlignmentLeft;
    
    
    for(UIView* view in _countTimeSelector.subviews)
    {
        if([[view class] isSubclassOfClass:[UILabel class]])
        {
            if(view.tag != count+123)
            {
                [(UILabel*)view setText:[NSString stringWithFormat:@"%ld",(view.tag)-123]];
                [(UILabel*)view setTextColor:HexRGBAlpha(0xfdfdfd, 0.8)];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:DelayTakePhotoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(count == 0)
    {
        _countDownBtn.hidden = YES;
    }

}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//
    int count = ((int)scrollView.contentOffset.x)/30;
    if(count>=60)
    {
        count = 60;
    }
    
    if(count<=0)
    {
        count = 0;
    }
    
    [scrollView setContentOffset:CGPointMake(count*30, 0) animated:YES];
    NSLog(@"-------dddd %d", count);
    UILabel* label = [_countTimeSelector viewWithTag:count+123];
    label.textColor = HexRGBAlpha(0xfdfdfd, 1.0);
//    label.textColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = [NSString stringWithFormat:@"%d%@",count, NSLocalizedString(@"秒", nil)];
    label.adjustsFontSizeToFitWidth = YES;
    [label setFont:[UIFont systemFontOfSize:14]];
    NSLog(@"------- %d", count);
    
    for(UIView* view in _countTimeSelector.subviews)
    {
        if([[view class] isSubclassOfClass:[UILabel class]])
        {
            if(view.tag != count+123)
            {
                [(UILabel*)view setText:[NSString stringWithFormat:@"%ld",(view.tag)-123]];
                [(UILabel*)view setTextColor:HexRGBAlpha(0xfdfdfd, 0.8)];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:DelayTakePhotoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(count == 0)
    {
        _countDownBtn.hidden = YES;
    }
}


@end
