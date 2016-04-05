//
//  HistoryViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 16/3/2.
//  Copyright © 2016年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface HistoryViewController :CustomViewController

@end

@interface MyView : UIView
@property (nonatomic, strong) void (^refreshView)(NSDictionary* dic);
@property (nonatomic, strong) NSDictionary* dataDic;

@end