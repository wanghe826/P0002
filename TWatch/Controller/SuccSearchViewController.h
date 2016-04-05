//
//  SuccSearchViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SuccSearchViewController : BaseViewController
{
    BOOL _hasConnected;
    UILabel* _titleLabel;
    
}
@property(nonatomic,strong) UIDynamicAnimator* animator;
@property(strong,nonatomic) JGBleDeviceInfo* deviceInfo;
@end


@interface WatchView : UIView<UIDynamicItem>
@property(nonatomic,strong) void (^callback)(void);
@end