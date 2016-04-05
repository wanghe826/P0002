//
//  PairedViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/11/6.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "CustomViewController.h"
@class HelpLabelView;
@class JGBleDeviceInfo;
@interface PairedViewController : CustomViewController
{
    UIButton* _searchBtn;
    
    UILabel* _topLabel;
    UILabel* _hintLabel;
    HelpLabelView* _helpLabel;
    UIButton* _researchBtn;
    
    UIImageView* _watchBackground;
    UIImageView* _tailView;
    NSTimer* _timer;
    BOOL _hsaSearchSuccessed;
    JGBleDeviceInfo* _deviceInfo;
    
    NSTimer* _authorizedTimer;
}

@end


@interface HelpLabelView : UIView

@property(nonatomic, strong) void (^pushVc)();

@end