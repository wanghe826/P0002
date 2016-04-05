//
//  ClockViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/10/12.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "XLFormViewController.h"
#import "ClockModel.h"
#import "CustomViewController.h"

#define ClockArrayKey @"ClockArrayDataKey"

@interface ClockViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray <ClockModel*>* clockModelArray;


@end


@interface ClockViewCell : UITableViewCell
+(instancetype)createCustomTableViewCell:(UITableView*)tableView;
@property (weak, nonatomic) IBOutlet UILabel* timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatDateLabel;
@property (strong, nonatomic) UISwitch* clockSwitch;

@end