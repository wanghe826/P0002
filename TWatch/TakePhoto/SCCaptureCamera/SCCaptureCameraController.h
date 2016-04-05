//
//  SCCaptureCameraController.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCCaptureSessionManager.h"

@interface SCCaptureCameraController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, assign) CGRect previewRect;
@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;
@property (nonatomic,assign) BOOL isPersonTake;


@end
