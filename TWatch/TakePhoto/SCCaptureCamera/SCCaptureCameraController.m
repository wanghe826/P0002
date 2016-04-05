//
//  SCCaptureCameraController.m
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import "SCCaptureCameraController.h"
#import "SCSlider.h"
#import "SCCommon.h"
#import "SVProgressHUD.h"
#import "CustomActionSheet.h"
#import "SCNavigationController.h"

//static void * CapturingStillImageContext = &CapturingStillImageContext;
//static void * RecordingContext = &RecordingContext;
//static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

#define SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE      0   //对焦框是否一直闪到对焦完成

#define SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA   1   //没有拍照功能的设备，是否给一张默认图片体验一下

//height
#define CAMERA_TOPVIEW_HEIGHT   44  //title
#define CAMERA_MENU_VIEW_HEIGH  44  //menu

//color
#define bottomContainerView_UP_COLOR     [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.f]       //bottomContainerView的上半部分
#define bottomContainerView_DOWN_COLOR   [UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1.f]       //bottomContainerView的下半部分
#define DARK_GREEN_COLOR        [UIColor colorWithRed:10/255.0f green:107/255.0f blue:42/255.0f alpha:1.f]    //深绿色
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:143/255.0f green:191/255.0f blue:62/255.0f alpha:1.f]    //浅绿色


//对焦
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   0.7f
#define HIGH_ALPHA  1.0f

//typedef enum {
//    bottomContainerViewTypeCamera    =   0,  //拍照页面
//    bottomContainerViewTypeAudio     =   1   //录音页面
//} BottomContainerViewType;

@interface SCCaptureCameraController ()<UIImagePickerControllerDelegate> {
    int alphaTimes;
    CGPoint currTouchPoint;
    NSMutableArray* _array;
    UIButton* _delayBtn;
    
    BOOL _isDelayComplete;
    UIButton* _selectImageBtn;
    UIImageView * showIV;               //照片选择页面的照片显示
    UIImagePickerController * Picker;
//    UIButton* _selectBtn;
    
    NSTimer* _timer ;
}

@property (nonatomic, strong) SCCaptureSessionManager *captureManager;

@property (nonatomic, strong) UIView *topContainerView;//顶部view
@property (nonatomic, strong) UILabel *topLbl;//顶部的标题

@property (nonatomic, strong) UIView *bottomContainerView;//除了顶部标题、拍照区域剩下的所有区域
@property (nonatomic, strong) UIView *cameraMenuView;//网格、闪光灯、前后摄像头等按钮
@property (nonatomic, strong) NSMutableSet *cameraBtnSet;

@property (nonatomic, strong) UIView *doneCameraUpView;
@property (nonatomic, strong) UIView *doneCameraDownView;

//对焦
@property (nonatomic, strong) UIImageView *focusImageView;

@property (nonatomic, strong) SCSlider *scSlider;

//@property (nonatomic) id runtimeErrorHandlingObserver;
//@property (nonatomic) BOOL lockInterfaceRotation;

@property (nonatomic, strong) UIPickerView* pickerView;
@property (nonatomic, strong) UIView* btnBackView;
@property (nonatomic, strong) UIButton* cancelBtn;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIButton* confirmBtn;

@end

@implementation SCCaptureCameraController

#pragma mark -------------life cycle---------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alphaTimes = -1;
        currTouchPoint = CGPointZero;
        
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (UIView*)btnBackView
{
    if(_btnBackView == nil){
        _btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.pickerView.frame.origin.y-40, 320, 40)];
        _btnBackView.backgroundColor = [UIColor grayColor];
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 60, 30)];
        title.text = NSLocalizedString(@"拍照延时", nil);
        title.textColor = [UIColor blackColor];
        [title sizeToFit];
        //        title.center = _btnBackView.center;
        title.center = CGPointMake(_btnBackView.center.x, 20);
        [_btnBackView addSubview:title];
        
        UIButton* cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setFrame:CGRectMake(10, 5, 40, 40)];
        [cancelBtn sizeToFit];
        [_btnBackView addSubview:cancelBtn];
        
        UIButton* confirmBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [confirmBtn setFrame:CGRectMake(_btnBackView.frame.size.width-50, 5, 40, 40)];
        [confirmBtn sizeToFit];
        [_btnBackView addSubview:confirmBtn];
    }
    return _btnBackView;
}

- (void) cancelAction:(UIButton*)sender
{
    [self.btnBackView removeFromSuperview];
    [self.pickerView removeFromSuperview];
}

- (void) confirmAction:(UIButton*)sender
{
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    
    [[NSUserDefaults standardUserDefaults] setInteger:row+1 forKey:DelayTakePhotoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString* sec = [NSString stringWithFormat:@"%ld", row+1];
    if(_delayBtn!=nil){
        [_delayBtn setTitle:sec forState:UIControlStateNormal];
    }
    [self.btnBackView removeFromSuperview];
    [self.pickerView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isDelayComplete = YES;
    //navigation bar
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    //status bar
    if (!self.navigationController) {
        _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
        if ([UIApplication sharedApplication].statusBarHidden == NO) {
            //iOS7，需要plist里设置 View controller-based status bar appearance 为NO
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    //notification
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:kNotificationOrientationChange object:nil];
    
    //session manager
    SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
    
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, SC_APP_SIZE.width, SC_APP_SIZE.width + CAMERA_TOPVIEW_HEIGHT);
    }
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    self.captureManager = manager;
    
    [self addTopViewWithText:@""];
    [self addbottomContainerView];
    [self addCameraMenuView];
    [self addFocusView];
    [self addCameraCover];
    [self addPinchGesture];
    
    [_captureManager.session startRunning];
    
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"设备不支持拍照功能"];
    }
#endif
}

- (void)stillInCamera
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEOnTakePhotoVCNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).isInCamera = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEOnTakePhotoVCNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(process) name:@"takePhoto" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissViewController) name:@"FinishTakePhoto" object:nil];
    if(!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(stillInCamera) userInfo:nil repeats:YES];
    }

    if(![_timer isValid])
    {
        [_timer fire];
    }
}
-(void)dismissViewController
{
    if (_isPersonTake) [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    
}
- (void) process
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLEOnTakePhotoVCNotification object:nil];
    if(_isDelayComplete){
        [self takePictureBtnPressed:nil];
        _isDelayComplete = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
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

//- (void)viewWillAppear:(BOOL)animated {
//	dispatch_async(_captureManager.sessionQueue, ^{
//		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
//		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
//		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[_captureManager.inputDevice device]];
//
//		WEAKSELF_SC
//		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:_captureManager.session queue:nil usingBlock:^(NSNotification *note) {
//			SCCaptureCameraController *strongSelf = weakSelf_SC;
//			dispatch_async(strongSelf.captureManager.sessionQueue, ^{
//				// Manually restarting the session since it must have been stopped due to an error.
//				[strongSelf.captureManager.session startRunning];
//			});
//		}]];
//		[_captureManager.session startRunning];
//	});
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//	dispatch_async(_captureManager.sessionQueue, ^{
//		[_captureManager.session stopRunning];
//
//		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[_captureManager.inputDevice device]];
//		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
//
//		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
//		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
//		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
//	});
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    if (!self.navigationController) {
        if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device removeObserver:self forKeyPath:ADJUSTINT_FOCUS context:nil];
    }
#endif
    
    self.captureManager = nil;
}

#pragma mark -------------UI---------------
//顶部标题
- (void)addTopViewWithText:(NSString*)text {
    if (!_topContainerView) {
        CGRect topFrame = CGRectMake(0, 0, SC_APP_SIZE.width, CAMERA_TOPVIEW_HEIGHT);
        
        UIView *tView = [[UIView alloc] initWithFrame:topFrame];
        tView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tView];
        self.topContainerView = tView;
        
        UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topFrame.size.width, topFrame.size.height)];
        emptyView.backgroundColor = [UIColor blackColor];
        emptyView.alpha = 0.4f;
        [_topContainerView addSubview:emptyView];
        
        topFrame.origin.x += 10;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, topFrame.size.height)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:25.f];
        [_topContainerView addSubview:lbl];
        self.topLbl = lbl;
    }
    _topLbl.text = text;
}

//bottomContainerView，总体
- (void)addbottomContainerView {
    
    CGFloat bottomY = _captureManager.previewLayer.frame.origin.y + _captureManager.previewLayer.frame.size.height;
    CGRect bottomFrame = CGRectMake(0, bottomY, SC_APP_SIZE.width, SC_APP_SIZE.height - bottomY);
    
    UIView *view = [[UIView alloc] initWithFrame:bottomFrame];
    view.backgroundColor = bottomContainerView_UP_COLOR;
    [self.view addSubview:view];
    self.bottomContainerView = view;
}

//拍照菜单栏
- (void)addCameraMenuView {
    
    //拍照按钮
    CGFloat downH = (isHigherThaniPhone4_SC ? CAMERA_MENU_VIEW_HEIGH : 0);
    CGFloat cameraBtnLength = 90;
    [self buildButton:CGRectMake((SC_APP_SIZE.width - cameraBtnLength) / 2, (_bottomContainerView.frame.size.height - downH - cameraBtnLength) / 2 , cameraBtnLength, cameraBtnLength)
         normalImgStr:@"shot.png"
      highlightImgStr:@"shot_h.png"
       selectedImgStr:@""
               action:@selector(takePictureBtnPressed:)
           parentView:_bottomContainerView];
    
    
    //拍照的菜单栏view（屏幕高度大于480的，此view在上面，其他情况在下面）
    CGFloat menuViewY = (isHigherThaniPhone4_SC ? SC_DEVICE_SIZE.height - CAMERA_MENU_VIEW_HEIGH : 0);
    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, menuViewY, self.view.frame.size.width, CAMERA_MENU_VIEW_HEIGH)];
    menuView.backgroundColor = (isHigherThaniPhone4_SC ? bottomContainerView_DOWN_COLOR : [UIColor clearColor]);
    [self.view addSubview:menuView];
    self.cameraMenuView = menuView;
    
    [self addMenuViewButtons];
}

//拍照菜单栏上的按钮
- (void)addMenuViewButtons {
    NSMutableArray *normalArr = [[NSMutableArray alloc] initWithObjects:@"huitui.png", @"camera_line.png", @"switch_camera.png", @"flashing_off.png", nil];
    NSMutableArray *highlightArr = [[NSMutableArray alloc] initWithObjects:@"close_cha_h.png", @"", @"", @"", nil];
    NSMutableArray *selectedArr = [[NSMutableArray alloc] initWithObjects:@"", @"camera_line_h.png", @"switch_camera_h.png", @"", nil];
    
    NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"dismissBtnPressed:", @"gridBtnPressed:", @"switchCameraBtnPressed:", @"flashBtnPressed:", nil];
    
    CGFloat eachW = SC_APP_SIZE.width / actionArr.count;
    
    [SCCommon drawALineWithFrame:CGRectMake(eachW, 0, 1, CAMERA_MENU_VIEW_HEIGH) andColor:rgba_SC(102, 102, 102, 1.0000) inLayer:_cameraMenuView.layer];
    
    
    //屏幕高度大于480的，后退按钮放在_cameraMenuView；小于480的，放在_bottomContainerView
    for (int i = 0; i < actionArr.count; i++) {
        
        CGFloat theH = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView.frame.size.height : CAMERA_MENU_VIEW_HEIGH);
        UIView *parent = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView : _cameraMenuView);
        
        UIButton* btn = nil;
        
        if(i==3){
            btn = [self buildButton:CGRectMake(self.view.frame.size.width-60, 1, 40, 40)
                       normalImgStr:nil
                    highlightImgStr:nil
                     selectedImgStr:nil
                             action:NSSelectorFromString([actionArr objectAtIndex:i])
                         parentView:parent];
            btn.layer.backgroundColor = [UIColor whiteColor].CGColor;
            btn.layer.borderWidth = 0.5;
            btn.layer.cornerRadius = 20;
            
            NSString* strTitle = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:DelayTakePhotoKey]];
            [btn setTitle:strTitle forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            _delayBtn = btn;
            
        }else if(i==1){
            btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            CGRect rect = CGRectMake(eachW * i, 0, eachW, theH);
            
            
            [btn setFrame:CGRectMake(eachW * i, 0, rect.size.width/2, rect.size.height-10)];
            btn.center = CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
            [btn setBackgroundImage:[UIImage imageNamed:[normalArr objectAtIndex:i]] forState:UIControlStateNormal];
            [btn addTarget:self action:NSSelectorFromString([actionArr objectAtIndex:i]) forControlEvents:UIControlEventTouchUpInside];
            [parent addSubview:btn];
            _selectImageBtn = btn;
        }else{
            btn = [self buildButton:CGRectMake(eachW * i, 5, eachW, theH-10)
                       normalImgStr:[normalArr objectAtIndex:i]
                    highlightImgStr:[highlightArr objectAtIndex:i]
                     selectedImgStr:[selectedArr objectAtIndex:i]
                             action:NSSelectorFromString([actionArr objectAtIndex:i])
                         parentView:parent];
        }
        
        
        btn.showsTouchWhenHighlighted = YES;
        
        [_cameraBtnSet addObject:btn];
    }
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:normalImgStr] forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}

//对焦的框
- (void)addFocusView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touch_focus_x.png"]];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device addObserver:self forKeyPath:ADJUSTINT_FOCUS options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
}

//拍完照后的遮罩
- (void)addCameraCover {
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SC_APP_SIZE.width, 0)];
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    self.doneCameraUpView = upView;
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, _bottomContainerView.frame.origin.y, SC_APP_SIZE.width, 0)];
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    self.doneCameraDownView = downView;
}

- (void)showCameraCover:(BOOL)toShow {
    
    [UIView animateWithDuration:0.38f animations:^{
        CGRect upFrame = _doneCameraUpView.frame;
        upFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : 0);
        _doneCameraUpView.frame = upFrame;
        
        CGRect downFrame = _doneCameraDownView.frame;
        downFrame.origin.y = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : _bottomContainerView.frame.origin.y);
        downFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 : 0);
        _doneCameraDownView.frame = downFrame;
    }];
}

//伸缩镜头的手势
- (void)addPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
    
    //横向
    //    CGFloat width = _previewRect.size.width - 100;
    //    CGFloat height = 40;
    //    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake((SC_APP_SIZE.width - width) / 2, SC_APP_SIZE.width + CAMERA_MENU_VIEW_HEIGH - height, width, height)];
    
    //竖向
    CGFloat width = 40;
    CGFloat height = _previewRect.size.height - 100;
    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(_previewRect.size.width - width, (_previewRect.size.height + CAMERA_MENU_VIEW_HEIGH - height) / 2, width, height) direction:SCSliderDirectionVertical];
    slider.alpha = 0.f;
    slider.minValue = MIN_PINCH_SCALE_NUM;
    slider.maxValue = MAX_PINCH_SCALE_NUM;
    
    WEAKSELF_SC
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [weakSelf_SC.captureManager pinchCameraViewWithScalNum:value];
    }];
    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [weakSelf_SC setSliderAlpha:isTouchEnd];
    }];
    
    [self.view addSubview:slider];
    
    self.scSlider = slider;
}

void c_slideAlpha() {
    
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}

#pragma mark -------------touch to focus---------------
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
//监听对焦是否完成了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        //        SCDLog(@"Is adjusting focus? %@", isAdjustingFocus ? @"YES" : @"NO" );
        //        SCDLog(@"Change dictionary: %@", change);
        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}

- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    [super touchesBegan:touches withEvent:event];
    
    alphaTimes = -1;
    
    UITouch *touch = [touches anyObject];
    currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_captureManager.previewLayer.bounds, currTouchPoint) == NO) {
        return;
    }
    
    [_captureManager focusInPoint:currTouchPoint];
    
    //对焦框
    [_focusImageView setCenter:currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    [UIView animateWithDuration:0.1f animations:^{
        _focusImageView.alpha = HIGH_ALPHA;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self showFocusInPoint:currTouchPoint];
    }];
#else
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
#endif
}

#pragma mark -------------button actions---------------
//拍照页面，拍照按钮
- (void)takePictureBtnPressed:(UIButton*)sender {
    int delayTime = (int)[[NSUserDefaults standardUserDefaults] integerForKey:DelayTakePhotoKey];
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    [self performSelector:@selector(takePhoto:) withObject:sender afterDelay:delayTime];
    [self countDown:_delayBtn withTime:delayTime];
}

- (void) countDown:(UIButton*)sender withTime:(int)countTime
{
    __block int timeout=countTime; //倒计时时间
    __block UIButton* button = sender;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* strTitle = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:DelayTakePhotoKey]];
                [button setTitle:strTitle forState:UIControlStateNormal];
                _isDelayComplete = YES;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setTitle:[NSString stringWithFormat:@"%d",timeout] forState:UIControlStateNormal];
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}

- (void)takePhoto:(UIButton*)sender{
//    UIButton* sender = [[timer userInfo] objectForKey:@"button"];
    
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"设备不支持拍照功能T_T"];
        return;
    }
#endif
    
    sender.userInteractionEnabled = NO;
    
    [self showCameraCover:YES];
    
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actiView.center = CGPointMake(self.view.center.x, self.view.center.y - CAMERA_TOPVIEW_HEIGHT);
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    WEAKSELF_SC
    [_captureManager takePicture:^(UIImage *stillImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SCCommon saveImageToPhotoAlbum:stillImage];//存至本机
        });
//        [_selectBtn setImage:stillImage forState:UIControlStateNormal];
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
        
        double delayInSeconds = 2.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            sender.userInteractionEnabled = YES;
            [weakSelf_SC showCameraCover:NO];
        });
        
        //your code 0
//        [_selectImageBtn setImage:stillImage forState:UIControlStateNormal];
        [_selectImageBtn setBackgroundImage:stillImage forState:UIControlStateNormal];
        SCNavigationController *nav = (SCNavigationController*)weakSelf_SC.navigationController;
        if ([nav.scNaigationDelegate respondsToSelector:@selector(didTakePicture:image:)]) {
            [nav.scNaigationDelegate didTakePicture:nav image:stillImage];
        }
        //or your code 1
        //        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTakePicture object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:stillImage, kImage, nil]];
        
        //or your code 2
        //    PostViewController *con = [[PostViewController alloc] init];
        //    con.postImage = stillImage;
        //    [self.navigationController pushViewController:con animated:YES];
    }];
}

- (void)tmpBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//拍照页面，"X"按钮
- (void)dismissBtnPressed:(id)sender {
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationController dismissModalViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}


//拍照页面，选择图片
- (void)gridBtnPressed:(UIButton*)sender {
//    sender.selected = !sender.selected;
    //    [_captureManager switchGrid:sender.selected];
    UIImagePickerController* imagePick = [[UIImagePickerController alloc] init];
    imagePick.delegate = self;
//    imagePick.allowsEditing = YES;
    imagePick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.navigationController presentViewController:imagePick animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (!showIV)
    {
        showIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
        showIV.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scaleShowImageIV:)];
        [showIV addGestureRecognizer:tap];
    }
    Picker = picker;
    UIViewController *  controller = [picker.childViewControllers objectAtIndex:1];
    [controller.view addSubview:showIV];
    showIV.frame  = CGRectZero;
    showIV.center = controller.view.center;
    showIV.hidden  = NO;
//    showIV.hidden = YES;
    showIV.tag = 10;
    NSLog(@"%@",picker.childViewControllers);
    
   
    showIV.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [UIView animateWithDuration:0.35 animations:^{
//        showIV.hidden = NO;
        //showIV.transform = CGAffineTransformMakeScale(10, 10);
        showIV.frame =  CGRectMake(0, 0, screen_width, screen_height);
        showIV.contentMode = UIViewContentModeScaleAspectFit;
    } completion:^(BOOL finished) {
        //
    }];
}
-(void)scaleShowImageIV:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.5 animations:^{
//        showIV.transform = CGAffineTransformMakeScale(0.1, 0.1);
        showIV.frame = CGRectZero;
         UIViewController *  controller = [Picker.childViewControllers objectAtIndex:1];
        showIV.center = controller.view.center;
        
    } completion:^(BOOL finished) {
//        NSLog(@"")
        showIV.hidden = YES;
    }];
}
//拍照页面，切换前后摄像头按钮按钮
- (void)switchCameraBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_captureManager switchCamera:sender.selected];
}

//拍照页面，闪光灯按钮
- (void)flashBtnPressed:(UIButton*)sender {
    //    [_captureManager switchFlashMode:sender];
    //拍照延迟
    //    UIActionSheet* delayPhoto = [[UIActionSheet alloc] initWithTitle:@"拍照延时" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
    //    CustomActionSheet* delayPhoto = [[CustomActionSheet alloc] initWithHeight:244.0f WithSheetTitle:@"拍照延时"];
    
    if(_array == nil){
        _array = [[NSMutableArray alloc] initWithCapacity:60];
        for(int i=1; i<=60; i++){
            [_array addObject:[NSNumber numberWithInt:i]];
        }
    }
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.btnBackView];
    [self.view bringSubviewToFront:self.btnBackView];
    
}

- (UIPickerView*)pickerView
{
    if(_pickerView == nil){
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-216, 320, 216)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

#pragma pickerView dataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_array count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d%@",[[_array objectAtIndex:row] intValue],NSLocalizedString(@"秒", nil)];
}

#pragma mark -------------pinch camera---------------
//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    
    [_captureManager pinchCameraView:gesture];
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        [_scSlider setValue:_captureManager.scaleNum shouldCallBack:NO];
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        } else {
            [self setSliderAlpha:NO];
        }
    }
}


//#pragma mark -------------save image to local---------------
////保存照片至本机
//- (void)saveImageToPhotoAlbum:(UIImage*)image {
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//}
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    if (error != NULL) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了!" message:@"存不了T_T" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    } else {
//        SCDLog(@"保存成功");
//    }
//}

#pragma mark ------------notification-------------
- (void)orientationDidChange:(NSNotification*)noti {
    
    //    [_captureManager.previewLayer.connection setVideoOrientation:(AVCaptureVideoOrientation)[UIDevice currentDevice].orientation];
    
    if (!_cameraBtnSet || _cameraBtnSet.count <= 0) {
        return;
    }
    [_cameraBtnSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *btn = ([obj isKindOfClass:[UIButton class]] ? (UIButton*)obj : nil);
        if (!btn) {
            *stop = YES;
            return ;
        }
        
        btn.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait://1
            {
                transform = CGAffineTransformMakeRotation(0);
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown://2
            {
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
            }
            case UIDeviceOrientationLandscapeLeft://3
            {
                transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            }
            case UIDeviceOrientationLandscapeRight://4
            {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
            }
            default:
                break;
        }
        [UIView animateWithDuration:0.3f animations:^{
            btn.transform = transform;
        }];
    }];
}

#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
//<iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//iOS6+
- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    //    return [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationPortrait;
}
#endif

@end
