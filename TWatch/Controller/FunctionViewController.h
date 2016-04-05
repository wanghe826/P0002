//
//  FunctionViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/31.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SCNavigationController.h"
@class StepProgressView;
@class LineProgressView;
@class FitnessViewController;
@interface FunctionViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate   /*JKPopMenuViewSelectDelegate,SCNavigationControllerDelegate*/>
{
    UIScrollView* _scrollView;
    UIPageControl* _pageControl;
    CGFloat _logoSize;
    
    UIView* _bottomView;
    UIButton* _bottomBtn;
    UIButton* _leftBtn;
    
    NSArray* _sportDatas;
    
    UIImageView* _fitnessCircleView;
    
    StepProgressView* _progressView;
    UILabel* _connectLabel;
    
    ///
    LineProgressView* _lineProgressView;
    UILabel* _allStep;
    UILabel* _energyAndKm;
    
    FitnessViewController* _fitVc;
    
    UILabel* _userNameLabel;
    
    NSUInteger _lastPage;
}

@property (nonatomic,strong) StepProgressView* progressView;

@end
