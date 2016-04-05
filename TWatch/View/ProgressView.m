//
//  ProgressView.m
//  TWatch
//
//  Created by Yingbo on 15/6/11.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "ProgressView.h"

#define LabelHeight 40

@interface ProgressView()

@property(nonatomic,strong) UIImageView *keduBgView;

@property(nonatomic,strong) UIImageView *keduView;

@property(nonatomic,strong) UIImageView *loadingBgView;

@property(nonatomic,strong) UIImageView *loadingView;

@property(nonatomic,strong) UIImageView *dianView;

@property(nonatomic,strong) UILabel *topTextLabel;

@property(nonatomic,strong) UILabel *leftTextLabel;

@property(nonatomic,strong) UILabel *rightTextLabel;

@property(nonatomic,strong) UILabel *bottomTextLabel;

@property(nonatomic,strong) UILabel *topContentLabel;

@property(nonatomic,strong) UILabel *contentLabel;

@property(nonatomic,strong) UILabel *bottomContentLabel;

@end

@implementation ProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.keduBgView];
        [self addSubview:self.keduView];
        [self addSubview:self.loadingBgView];
        [self addSubview:self.loadingView];
        [self addSubview:self.dianView];
//        [self addSubview:self.topTextLabel];
//        [self addSubview:self.rightTextLabel];
//        [self addSubview:self.bottomTextLabel];
//        [self addSubview:self.leftTextLabel];
        [self addSubview:self.topContentLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.bottomContentLabel];
    }
    return self;
}

- (UIImageView *)keduBgView
{
    if (_keduBgView == nil) {
        _keduBgView = [[UIImageView alloc]init];
        _keduBgView.image = [UIImage imageNamed:@"kedu_bg"];
        _keduBgView.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
//        _keduBgView.layer.shouldRasterize = YES;
    }
    return _keduBgView;
}

- (UIImageView *)keduView
{
    if (_keduView == nil) {
        _keduView = [[UIImageView alloc]init];
        _keduView.image = [UIImage imageNamed:@"kedu_jiazai"];
        _keduView.frame = self.frame;
//        _keduView.layer.shouldRasterize = YES;
    }
    return _keduView;
}

- (UIImageView *)loadingBgView
{
    if (_loadingBgView == nil) {
        _loadingBgView = [[UIImageView alloc]init];
        _loadingBgView.image = [UIImage imageNamed:@"loading_bg"];
        _loadingBgView.frame = self.frame;
//        _loadingBgView.layer.shouldRasterize = YES;
    }
    return _loadingBgView;
}

- (UIImageView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[UIImageView alloc]init];
        _loadingView.image = [UIImage imageNamed:@"loading_jiazai"];
        _loadingView.frame = self.frame;
//        _loadingView.layer.shouldRasterize = YES;
    }
    return _loadingView;
}

- (UIImageView *)dianView
{
    if (_dianView == nil) {
        _dianView = [[UIImageView alloc]init];
        _dianView.image = [UIImage imageNamed:@"dian"];
        _dianView.frame = self.frame;
    }
    return _dianView;
}

- (UILabel *)topTextLabel
{
    if (_topTextLabel == nil) {
        _topTextLabel = [[UILabel alloc]init];
        _topTextLabel.textColor = [UIColor grayColor];
        _topTextLabel.font = [UIFont systemFontOfSize:12];
        _topTextLabel.textAlignment = NSTextAlignmentCenter;
        _topTextLabel.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
        _topTextLabel.text = @"0";
    }
    return _topTextLabel;
}

- (UILabel *)leftTextLabel
{
    if (_leftTextLabel == nil) {
        _leftTextLabel = [[UILabel alloc]init];
        _leftTextLabel.textColor = [UIColor grayColor];
        _leftTextLabel.font = [UIFont systemFontOfSize:12];
        _leftTextLabel.textAlignment = NSTextAlignmentCenter;
        _leftTextLabel.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
        _leftTextLabel.text = @"75%";
    }
    return _leftTextLabel;
}

- (UILabel *)rightTextLabel
{
    if (_rightTextLabel == nil) {
        _rightTextLabel = [[UILabel alloc]init];
        _rightTextLabel.textColor = [UIColor grayColor];
        _rightTextLabel.font = [UIFont systemFontOfSize:12];
        _rightTextLabel.textAlignment = NSTextAlignmentCenter;
        _rightTextLabel.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
        _rightTextLabel.text = @"25%";
    }
    return _rightTextLabel;
}

- (UILabel *)bottomTextLabel
{
    if (_bottomTextLabel == nil) {
        _bottomTextLabel = [[UILabel alloc]init];
        _bottomTextLabel.textColor = [UIColor grayColor];
        _bottomTextLabel.font = [UIFont systemFontOfSize:12];
        _bottomTextLabel.textAlignment = NSTextAlignmentCenter;
        _bottomTextLabel.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
        _bottomTextLabel.text = @"50%";
    }
    return _bottomTextLabel;
}

- (UILabel *)topContentLabel
{
    if (_topContentLabel == nil) {
        _topContentLabel = [[UILabel alloc]init];
        _topContentLabel.textColor = [UIColor grayColor];
        _topContentLabel.font = [UIFont systemFontOfSize:12];
        _topContentLabel.textAlignment = NSTextAlignmentCenter;
        _topContentLabel.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
    }
    return _topContentLabel;
}

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.textColor = RGBColor(108, 174, 251);
        _contentLabel.font = [UIFont systemFontOfSize:22];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
    }
    return _contentLabel;
}

- (UILabel *)bottomContentLabel
{
    if (_bottomContentLabel == nil) {
        _bottomContentLabel = [[UILabel alloc]init];
        _bottomContentLabel.textColor = [UIColor grayColor];
        _bottomContentLabel.font = [UIFont systemFontOfSize:12];
        _bottomContentLabel.textAlignment = NSTextAlignmentCenter;
        _bottomContentLabel.frame = CGRectMake(0, 0, LabelHeight, LabelHeight);
    }
    return _bottomContentLabel;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGPoint center = self.topTextLabel.center;
    center.x = frame.size.width / 2;
    self.topTextLabel.center = center;
    
    center = self.rightTextLabel.center;
    center.x = frame.size.width - LabelHeight / 2;
    center.y = frame.size.height / 2;
    self.rightTextLabel.center = center;
    
    center = self.bottomTextLabel.center;
    center.x = frame.size.width / 2;
    center.y = frame.size.height - LabelHeight / 2;
    self.bottomTextLabel.center = center;
    
    center = self.leftTextLabel.center;
    center.x = LabelHeight / 2;
    center.y = frame.size.height / 2;
    self.leftTextLabel.center = center;
    
    self.keduBgView.frame = CGRectMake(0, 0, frame.size.width - 2*LabelHeight, frame.size.width - 2*LabelHeight);
    self.keduBgView.center = self.center;
    
    self.keduView.frame = CGRectMake(0, 0, frame.size.width - 2*LabelHeight, frame.size.width - 2*LabelHeight);
    self.keduView.center = self.center;
    
    self.loadingBgView.frame = CGRectMake(0, 0, frame.size.width - 2*LabelHeight, frame.size.width - 2*LabelHeight);
    self.loadingBgView.center = self.center;
    
    self.loadingView.frame = CGRectMake(0, 0, frame.size.width - 2*LabelHeight, frame.size.width - 2*LabelHeight);
    self.loadingView.center = self.center;
    
    self.dianView.frame = CGRectMake(0, 0, 20, 20);
    self.dianView.center = CGPointMake(frame.size.width / 2 - 2*LabelHeight + 24, frame.size.width /2 - LabelHeight);
    
    self.contentLabel.frame = CGRectMake(0, 0, self.loadingBgView.frame.size.width, 20);
    self.contentLabel.center = self.center;
    self.contentLabel.text = @"80%";
    
    self.bottomContentLabel.frame = CGRectMake(0, 0, self.loadingBgView.frame.size.width, 20);
    self.bottomContentLabel.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 + 30);
    self.bottomContentLabel.text = @"剩余电量";
    
//    CGRect rect = self.topTextLabel.frame;
//    rect.size.height = 60;
//    self.topTextLabel.frame = rect;
//    self.bgView.frame = frame;
}

@end
