//
//  CustomViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/11/2.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomViewController : UIViewController<UIGestureRecognizerDelegate>

@property(nonatomic,strong) UIButton* backBtn;
@property(nonatomic,copy) NSString* myTitle;
-(void) returnBack;
@end
