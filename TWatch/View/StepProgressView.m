//
//  ProgressView.m
//  TWatch
//
//  Created by Yingbo on 15/6/11.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "StepProgressView.h"
#import "AppUtils.h"
#define LabelHeight 40

@interface StepProgressView()

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
@property(nonatomic,strong) CAShapeLayer * progressLayer;

@end

@implementation StepProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.keduBgView];
        //        [self addSubview:self.keduView];
        //        [self addSubview:self.loadingBgView];
        [self addSubview:self.loadingView];
        //        [self addSubview:self.dianView];
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
        _keduBgView.image = [UIImage imageNamed:@"yundong_kedu_bg"];
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
        //        _loadingView.image = [UIImage imageNamed:@"ribu_loading"];
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
    
    
    
    self.keduBgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
    self.keduBgView.center = self.center;
    
    self.loadingView.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
    self.loadingView.center = self.center;
    
    self.dianView.frame = CGRectMake(0, 0, 20, 20);
    self.dianView.center = CGPointMake(frame.size.width / 2 - 2*LabelHeight + 24, frame.size.width /2 - LabelHeight);
    
    self.topContentLabel.frame = CGRectMake(0, 0, self.loadingView.frame.size.width, 20);
    self.topContentLabel.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 - 30);
    self.topContentLabel.text = NSLocalizedString(@"总步数", nil);
    
    self.contentLabel.frame = CGRectMake(0, 0, self.loadingView.frame.size.width, 20);
    self.contentLabel.center = self.center;
    self.contentLabel.text = @"2559";
    
    self.bottomContentLabel.frame = CGRectMake(0, 0, self.loadingView.frame.size.width, 20);
    self.bottomContentLabel.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 + 30);
    self.bottomContentLabel.text = @"目标:40000步";
    
    //    CGRect rect = self.topTextLabel.frame;
    //    rect.size.height = 60;
    //    self.topTextLabel.frame = rect;
    //    self.bgView.frame = frame;
}
-(void)toChangeViewData:(NSString *)topString center:(NSString *)centerString boottom:(NSString *)bottomString{
    self.topContentLabel.text=topString;
    self.contentLabel.text=centerString;
    self.bottomContentLabel.text=bottomString;
    float target;
    //    centerString = [[NSString alloc]initWithFormat:@"%d",arc4random()%6];
    UIColor * lineColor;
    BOOL isEn;
    if ([[AppUtils getCurrentLanguagesStr]isEqualToString:@"en-CN"])
    {
        isEn = YES;
    }else isEn = NO;
    if ([bottomString rangeOfString:NSLocalizedString(@"步", nil)].location != NSNotFound)
    {
        lineColor = RGBColor(190, 42, 51);
        NSString * str =[bottomString substringWithRange:NSMakeRange(isEn?7: 2,isEn?bottomString.length - 12 :bottomString.length- 3)];
        target = [str floatValue];
        
    }
    else if ([bottomString rangeOfString:NSLocalizedString(@"小时", nil)].location != NSNotFound)
    {
        NSString * str =[bottomString substringWithRange:NSMakeRange(isEn?7:2,isEn?bottomString.length - 12: bottomString.length- 4)];
        target = [str floatValue];
        lineColor = RGBColor(63, 179, 81);
        
    }
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.width/2) radius:self.frame.size.width/2-23 startAngle:-M_PI_2 endAngle:(([centerString floatValue]/target)*2*M_PI-M_PI_2) clockwise:YES];
    //    UIColor * color =  [UIColor redColor];
    path.lineJoinStyle = kCGLineJoinRound;
    //    path.lineWidth = 10;
    //    [color set];
    //    [path stroke];
    
    if (!_progressLayer)
    {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        _progressLayer.borderColor = [UIColor clearColor ].CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        _progressLayer.lineWidth = 4;
        [_progressLayer setLineCap:kCALineCapRound];
        
    }
    
    
    [self.layer addSublayer:_progressLayer];
    _progressLayer.path = path.CGPath;
    [_progressLayer setStrokeColor:lineColor.CGColor];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.1;//设置绘制动画持续的时间
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;//是否翻转绘制
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.repeatCount = 1;
    [_progressLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}
-(UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}
@end
