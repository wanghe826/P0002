#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ImagePickerViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
}
@property (nonatomic,retain) UIImage *photo;
@end
