//
//  SportDetailView.h
//  TWatch
//
//  Created by QFITS－iOS on 16/3/2.
//  Copyright © 2016年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SportDetailView : UIView

+ (instancetype) sportDetailViewWithFrame:(CGRect)frame;

@property (weak, nonatomic) IBOutlet UILabel *sportLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *footLabel;
@property (weak, nonatomic) IBOutlet UILabel *footDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieDataLabel;

@end
