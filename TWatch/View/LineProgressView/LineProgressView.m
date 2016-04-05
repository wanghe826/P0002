//
//  LineProgressView.m
//  Layer
//
//  Created by Carver Li on 14-12-1.
//
//

#import "LineProgressView.h"

@implementation LineProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _defaultInit];
        [self addCircle];
    }
    
    return self;
}

- (void) addCircle
{
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:self.center radius:self.frame.size.width/2 startAngle:-M_PI_2 endAngle:((1.0)*2*M_PI-M_PI_2) clockwise:YES];
    //    UIColor * color =  [UIColor redColor];
    path.lineJoinStyle = kCGLineJoinRound;
    
    CAShapeLayer* progressLayer = [CAShapeLayer layer];
    progressLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    progressLayer.borderColor = [UIColor clearColor ].CGColor;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    progressLayer.lineWidth = 4;
    [progressLayer setLineCap:kCALineCapRound];
    
    
    [self.layer addSublayer:progressLayer];
    progressLayer.path = path.CGPath;
    [progressLayer setStrokeColor:HexRGBAlpha(0xfdfdfd, 0.05).CGColor];
}

/*
- (void) addCircleAnimation
{
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:self.center radius:self.frame.size.width/2 startAngle:-M_PI_2 endAngle:((1.0)*2*M_PI-M_PI_2) clockwise:YES];
    //    UIColor * color =  [UIColor redColor];
    path.lineJoinStyle = kCGLineJoinRound;
    
    CAShapeLayer* progressLayer = [CAShapeLayer layer];
    progressLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    progressLayer.borderColor = [UIColor clearColor ].CGColor;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    progressLayer.lineWidth = 4;
    [progressLayer setLineCap:kCALineCapRound];
    
    
    [self.layer addSublayer:progressLayer];
    progressLayer.path = path.CGPath;
    [progressLayer setStrokeColor:HexRGBAlpha(0xfdfdfd, 0.4).CGColor];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0;//设置绘制动画持续的时间
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;//是否翻转绘制
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.repeatCount = 1;
    [progressLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (void)_defaultInit
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    self.total = 100;
    self.color = [UIColor blackColor];
    self.completed = 0;
    self.completedColor = HexRGBAlpha(0xfdfdfd, 0.8);
    
    self.radius = 30.0;
    self.innerRadius = 20.0;
    
    self.startAngle = 0;
    self.endAngle = M_PI*2;
}

+ (Class)layerClass
{
    return [LineProgressLayer class];
}

- (void)setTotal:(int)total
{
    _total = total;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.total = total;
    [layer setNeedsDisplay];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.color = color;
    [layer setNeedsDisplay];
}

- (void)setCompletedColor:(UIColor *)completedColor
{
    _completedColor = completedColor;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.completedColor = completedColor;
    [layer setNeedsDisplay];
}

-(void)setCompleted:(int)completed
{
    [self setCompleted:completed animated:NO];
}

- (void)setCompleted:(int)completed animated:(BOOL)animated
{
    if (completed == self.completed)
    {
        if (completed != 0) {
            return;
        }
    }
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    if (animated && self.animationDuration > 0.0f)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"completed"];
        animation.duration = self.animationDuration;
        animation.fromValue = [NSNumber numberWithFloat:self.completed];
        animation.toValue = [NSNumber numberWithFloat:completed];
        animation.delegate = self;
        [self.layer addAnimation:animation forKey:@"currentAnimation"];
    }
    
    layer.completed = completed;
    [layer setNeedsDisplay];
}


- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.radius = radius;
    [layer setNeedsDisplay];
}

- (void)setInnerRadius:(CGFloat)innerRadius
{
    _innerRadius = innerRadius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.innerRadius = innerRadius;
    [layer setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.startAngle = startAngle;
    [layer setNeedsDisplay];
}

- (void)setEndAngle:(CGFloat)endAngle
{
    _endAngle = endAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.endAngle = endAngle;
    [layer setNeedsDisplay];
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration
{
    _animationDuration = animationDuration;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.animationDuration = animationDuration;
    [layer setNeedsDisplay];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStart:)]) {
        [self.delegate LineProgressViewAnimationDidStart:self];
    }
//    [self addCircleAnimation];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStop:)]) {
        [self.delegate LineProgressViewAnimationDidStop:self];
    }
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
