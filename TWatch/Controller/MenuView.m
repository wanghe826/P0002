//
//  MenuView.m
//  TWatch
//
//  Created by HMM－MACmini on 15/12/29.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "MenuView.h"
#import "FXBlurView.h"
#import "BLEAppContext.h"

@interface MenuView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *myTableView; // 手写代码实现UITableView
@property (nonatomic, strong) NSMutableArray *dataArr; // 静态数据的数据源

@end

@implementation MenuView

// 刷新连接状态
- (void)refreshUIMenu {
    if([BLEAppContext shareBleAppContext].isConnected)
    {
        self.dataArr[3] = NSLocalizedString(@"断开连接", nil);
    }
    else
    {
        self.dataArr[3] = NSLocalizedString(@"手表配对", nil);
    }
    [self.myTableView reloadData];
}

// 懒加载初始化 myTableView
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.scrollEnabled = NO;
        _myTableView.separatorColor =  HexRGBAlpha(0xfdfdfd, 0.3);
        
        UIView* view = [UIView new];
        _myTableView.tableFooterView = view;
    }
    return _myTableView;
}
// 懒加载初始化 dataArr
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        NSString* connStatusStr =  NSLocalizedString(@"手表配对", nil);
        if([BLEAppContext shareBleAppContext].isConnected)
        {
            connStatusStr = NSLocalizedString(@"断开连接", nil);
        }
        
        _dataArr = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"个人信息", nil), NSLocalizedString(@"智能闹钟", nil), NSLocalizedString(@"智能校时", nil), connStatusStr, NSLocalizedString(@"运动设置", nil), NSLocalizedString(@"关于系统", nil), NSLocalizedString(@"帮助", nil)]];
    }
    return _dataArr;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self.myTableView setBackgroundView:nil];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.myTableView];
    [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableSampleIdentifier"];
    [_myTableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
}


#pragma mark - UITableViewDataSource
// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    // 用TableSampleIdentifier表示需要重用的单元
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier forIndexPath:indexPath];
    // 如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:tableSampleIdentifier];
    }
    
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.textLabel.text = self.dataArr[indexPath.row];
    cell.textLabel.alpha = 0.7;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
// 选中 cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.returnBlock(indexPath.row);
}

// 返回组视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"icon_cross"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(view.frame.size.width - 40, 5, 30, 30);
    [view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

// 返回组头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 100;
//}

// 返回 cell 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


/**
 *  btnClick 关闭按钮点击时间
 */
- (void)btnClick:(id)sender {
    
    self.alpha = 0;
    self.returnBlock(88);
}

@end
