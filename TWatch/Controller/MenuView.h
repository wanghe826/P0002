//
//  MenuView.h
//  TWatch
//
//  Created by HMM－MACmini on 15/12/29.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReturnBlock) (NSInteger selectedRow);

@interface MenuView : UIView

@property (nonatomic, strong) ReturnBlock returnBlock;

// 刷新连接状态
- (void)refreshUIMenu;

@end
