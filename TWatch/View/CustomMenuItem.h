//
//  CustomMenuItem.h
//  TWatch
//
//  Created by QFITS－iOS on 15/11/18.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YALContextMenuCell.h"

@interface CustomMenuItem : UITableViewCell<YALContextMenuCell>

@property(strong, nonatomic) UILabel* connectLabel;
@property(strong, nonatomic) UILabel* menuTitle;
@property(strong, nonatomic) UIImageView* menuIcon;

+ (CustomMenuItem*)customMenuItem:(UITableView*)tableView;
@end
