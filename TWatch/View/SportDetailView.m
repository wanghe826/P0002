//
//  SportDetailView.m
//  TWatch
//
//  Created by QFITS－iOS on 16/3/2.
//  Copyright © 2016年 ZeroSoft. All rights reserved.
//

#import "SportDetailView.h"

@implementation SportDetailView

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

+ (instancetype) sportDetailViewWithFrame:(CGRect)frame
{
    SportDetailView* view = [[[NSBundle mainBundle] loadNibNamed:@"SportDetailView" owner:nil options:nil] lastObject];
    view.frame = frame;
    view.sportLabel.text = NSLocalizedString(@"当天活动里程:米", nil);
    view.footLabel.text = NSLocalizedString(@"当天步数:步", nil);
    view.calorieLabel.text = NSLocalizedString(@"当天能量消耗:千卡", nil);
    view.sportLabel.textColor = [UIColor blackColor];
    view.footLabel.textColor = [UIColor blackColor];
    view.calorieLabel.textColor = [UIColor blackColor];
    return view;
}


@end
