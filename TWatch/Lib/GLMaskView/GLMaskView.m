#import "GLMaskView.h"

@interface GLMaskView()
@property (assign, nonatomic) UIView *childView;
@property (assign, nonatomic) UIImageView *imageView;
@end

NSString* DismissNotification = @"DismissMask";

@implementation GLMaskView

- (instancetype)initWithSubView:(UIView *)childView {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopup) name:@"DismissMask" object:nil];
        
        UIImageView *iv = [[UIImageView alloc] init];
        iv.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
        iv.userInteractionEnabled = YES;
        [self addSubview:iv];
        self.imageView = iv;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDismiss)];
        tapGesture.numberOfTapsRequired = 1;
        [self.imageView addGestureRecognizer:tapGesture];
        
        [self addSubview:childView];
        self.childView = childView;
        
        self.backgroundColor = [UIColor clearColor];
        self.alpha = .0f;
    }
    return self;
}

-(void)dismissPopup
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = .0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)tapDismiss {
    if (!self.ignoreBackgroundTapGesture) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"invalidateTime" object:nil];
        [self dismissPopup];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showInView:(UIView *)iv {
    self.frame = CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height);
    self.imageView.frame = self.bounds;
    switch (self.animation) {
        case AnimationDrop:
        {
            self.childView.frame = CGRectMake((self.frame.size.width - self.childView.frame.size.width) / 2, -self.childView.frame.size.height, self.childView.frame.size.width, self.childView.frame.size.height);
        }
            break;
        case AnimationClimb:
        {
            self.childView.frame = CGRectMake((self.frame.size.width - self.childView.frame.size.width) / 2, self.frame.size.height, self.childView.frame.size.width, self.childView.frame.size.height);
        }
            break;
        default:
        {
            self.childView.frame = CGRectMake((self.frame.size.width - self.childView.frame.size.width) / 2, (self.frame.size.height - self.childView.frame.size.height) / 2, self.childView.frame.size.width, self.childView.frame.size.height);
        }
            break;
    }
    [iv addSubview:self];
    
    switch (self.animation) {
        case AnimationAlert:
        {
            self.alpha = 1.0f;
            
            CAKeyframeAnimation * animation;
            animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            animation.duration = 0.5;
            animation.removedOnCompletion = YES;
            animation.fillMode = kCAFillModeForwards;
            NSMutableArray *values = [NSMutableArray array];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
            animation.values = values;
            [self.childView.layer addAnimation:animation forKey:nil];
        }
            break;
        case AnimationDrop:
        {
            self.alpha = 1.0f;
            
            CGRect rect = self.childView.frame;
            rect.origin.y = .0f;
            [UIView animateWithDuration:0.3 animations:^{
                self.childView.frame = rect;
            } completion:nil];
        }
            break;
        case AnimationClimb:
        {
            self.alpha = 1.0f;
            
            CGRect rect = self.childView.frame;
            rect.origin.y = self.frame.size.height - rect.size.height;
            [UIView animateWithDuration:0.3 animations:^{
                self.childView.frame = rect;
            } completion:nil];
        }
            break;
        default:
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.0f;
            }];
        }
            break;
    }
}

@end
