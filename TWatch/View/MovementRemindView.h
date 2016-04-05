//
//  MovementRemindView.h
//  TWatch
//
//  Created by Yingbo on 15/7/4.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@interface MovementRemindView : UIView

@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) void (^gotoVc)();
@property(nonatomic,strong) UIScrollView *rootView;
/**
 *  重置Scroller的偏移量
 */
-(void)setContentViewOffset;
-(void) tochangedata;
/**
 *  截取图片
 *
 *  @return 截图
 */
-(UIImage *)TakeScrennShot;

-(UIImage *)setContentOffset:(CGPoint)point;
@end
