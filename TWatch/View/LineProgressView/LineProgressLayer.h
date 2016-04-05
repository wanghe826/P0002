//
//  LineProgressLayer.h
//  GLSX
//
//  Created by Carver Li on 14-12-1.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//这个继承了图层，这个是要干什么？这个值得学习。
@interface LineProgressLayer : CALayer

@property (nonatomic,assign) int total;
@property (nonatomic,strong) UIColor *color;
//这应该是个旗标。
@property (nonatomic,assign) int completed;
@property (nonatomic,strong) UIColor *completedColor;

//我想这个应该是圆角的半径。
@property (nonatomic,assign) CGFloat radius;
//这个应该是内半径。
@property (nonatomic,assign) CGFloat innerRadius;

//这个是什么的开始角？
@property CGFloat startAngle;
@property CGFloat endAngle;

@property (nonatomic, assign) CFTimeInterval animationDuration;

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
