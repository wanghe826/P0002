//
//  SportSleepSettingViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/8/1.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "XLFormViewController.h"
#import "XLFormBaseCell.h"

@interface SportSleepSettingViewController : XLFormViewController<UIAlertViewDelegate>

@end





static NSString* const XLFormRowTypeClearButton;
@interface CustomFormRowCell : XLFormBaseCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;

@property (weak, nonatomic) IBOutlet UIImageView *customImage;
- (IBAction)clearAction:(id)sender;

@end