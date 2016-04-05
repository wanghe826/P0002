//
//  TakePhotoViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/12/21.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "SCCaptureSessionManager.h"

@interface TakePhotoViewController : UIViewController<UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, assign)       CGRect                      previewRect;
@property (nonatomic, strong)       SCCaptureSessionManager     *captureManager;

@end
