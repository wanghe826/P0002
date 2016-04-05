/**
 类似UIAlertView,遮罩点击消失，提供3中显示效果。
 
 demo:
 
 ```
    GLMaskView *mv = [[GLMaskView alloc] initWithSubView:childView];
    mv.animation = AnimationType;
    [mv showInView:fatherView];
 ```
 
 */

#import <UIKit/UIKit.h>

typedef enum : int
{
    AnimationDefault,//淡入淡出效果
    AnimationAlert,//放大缩小效果
    AnimationDrop,//顶端落下效果
    AnimationClimb,//底端向上效果
}AnimationType;

extern NSString* DismissNotification;

@interface GLMaskView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) AnimationType animation;

@property (nonatomic) BOOL ignoreBackgroundTapGesture;

/** 构造方法
 @param     childView       包含的视图
 @return    instancetype    GLMaskView
 */
- (instancetype)initWithSubView:(UIView *)childView;

/** 显示maskView
 @param     iv              父视图
 */
- (void)showInView:(UIView *)iv;

/** 消失maskView
 */
- (void)dismissPopup;

@end
