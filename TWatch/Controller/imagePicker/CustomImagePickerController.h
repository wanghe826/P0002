#import <UIKit/UIKit.h>

#define TAKEPHOTO @"takephoto"

@protocol CustomImagePickerControllerDelegate;

@interface CustomImagePickerController : UIImagePickerController
<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
//    id<CustomImagePickerControllerDelegate> _customDelegate;
    UIView *animationView;
}
@property(nonatomic)BOOL isSingle;
@property (nonatomic, retain) UIImage *lastSavedImg;

@property(nonatomic,assign)id<CustomImagePickerControllerDelegate> customDelegate;
@end

@protocol CustomImagePickerControllerDelegate <NSObject>

- (void)cameraPhoto:(UIImage *)image;
//- (void)cancelCamera;
@end
