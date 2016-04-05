//
//  SearchWatchViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class LabelView;
@interface SearchWatchViewController : BaseViewController
{
//    LabelView* _labelView;
    UILabel* _labelView;
    
    
    NSTimer* _timer;
    UIImageView* _tailView;
    BOOL _hasAlreadySearchedWatch;
    
//    UIButton* _researchBtn;
    UIButton* _helpBtn;
    
    UILabel* _hintLabel;
    
    NSTimer* _authorizedTimer;
    UIButton* _searchBtn;
}

@end


@interface LabelView : UIView
@property(copy,nonatomic) NSString* labelStr;
@end