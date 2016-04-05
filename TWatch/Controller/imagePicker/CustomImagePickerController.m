#import "CustomImagePickerController.h"
#import "IphoneScreen.h"
#import "UIImage+Cut.h"
#import "ImagePickerViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
@interface CustomImagePickerController ()

@end

@implementation CustomImagePickerController

@synthesize customDelegate = _customDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePhoto) name:@"takePhoto" object:nil];
        [self performSelectorInBackground:@selector(loadImageFromPhotoLibrary) withObject:nil];
        //[self performSelectorOnMainThread:@selector(loadImageFromPhotoLibrary) withObject:nil waitUntilDone:YES];
    }
    return self;
}

#pragma mark get/show the UIView we want
- (UIView *)findView:(UIView *)aView withName:(NSString *)name {
	Class cl = [aView class];
	NSString *desc = [cl description];
	
	if ([name isEqualToString:desc])
		return aView;
	
	for (NSUInteger i = 0; i < [aView.subviews count]; i++) {
		UIView *subView = [aView.subviews objectAtIndex:i];
		subView = [self findView:subView withName:name];
		if (subView)
			return subView;
	}
	return nil;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{    
    if(self.sourceType == UIImagePickerControllerSourceTypeCamera){
        UIImage *deviceImage = [UIImage imageNamed:@"camera_button_switch_camera"];
        UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deviceBtn setBackgroundImage:deviceImage forState:UIControlStateNormal];
        [deviceBtn addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
        [deviceBtn setFrame:CGRectMake(250, 20, deviceImage.size.width, deviceImage.size.height)];
        
        UIView *PLCameraView=[self findView:viewController.view withName:@"PLCameraView"];
        [PLCameraView addSubview:deviceBtn];
        
        [self setShowsCameraControls:NO];
        
        UIView *overlyView;
        if (IS_IPHONE5) {
            overlyView = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height - 96, screen_width, 96)];
        } else {
            overlyView = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height - 54, screen_width, 54)];
        }
        
        UIImageView *backGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, overlyView.frame.size.width, overlyView.frame.size.height)];
        backGround.contentMode  = UIViewContentModeScaleAspectFill;
        backGround.image = [UIImage imageNamed:@"lcd_top_simple"];
        [overlyView addSubview:backGround];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *backImage = [UIImage imageNamed:@"camera_cancel"];
        [backBtn setImage: backImage forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setFrame:CGRectMake(5, (overlyView.frame.size.height - backImage.size.height*1.5)/2, backImage.size.width*1.5, backImage.size.height*1.5)];
        [overlyView addSubview:backBtn];
        
        UIImage *camerImage = [UIImage imageNamed:@"camera_shoot"];
        UIButton *cameraBtn = [[UIButton alloc] initWithFrame:
                               CGRectMake((screen_width - camerImage.size.width*1.5)/2, (overlyView.frame.size.height - camerImage.size.height*1.5)/2, camerImage.size.width*1.5, camerImage.size.height*1.5)];
        [cameraBtn setImage:camerImage forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        [overlyView addSubview:cameraBtn];
        
        UIImage *photoImage = [UIImage imageNamed:@"camera_album"];
        
//        if (self.lastSavedImg == nil) {
//            self.lastSavedImg = photoImage;
//        }
        
        UIButton *photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(220, (overlyView.frame.size.height - 60)/2, 105, 60)];
        photoBtn.tag = 100;
        [photoBtn setImage:photoImage forState:UIControlStateNormal];
        [photoBtn addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchUpInside];
        [overlyView addSubview:photoBtn];
        
        self.cameraOverlayView = overlyView;
    } else {
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePicture) name:TAKEPHOTO object:nil];
    animationView = [[UIView alloc] initWithFrame:self.view.frame];
    animationView.backgroundColor = [UIColor whiteColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (self.lastSavedImg != nil) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:100];
        [btn setImage:self.lastSavedImg forState:UIControlStateNormal];
    }
}

#pragma mark - notification

- (void)takePhoto
{
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera)
    {

        [self takePicture];
    }

}

#pragma mark - ButtonAction Methods

- (IBAction)swapFrontAndBackCameras:(id)sender {
    if (self.cameraDevice ==UIImagePickerControllerCameraDeviceRear ) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }else {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePicture
{
    [super takePicture];
}

- (void)showPhoto
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.view addSubview:animationView];
        animationView.alpha = 0;} completion:^(BOOL finish){
            if (finish) {
                [animationView removeFromSuperview];
                animationView.alpha = 1;
            }
        }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (IS_IPHONE5) {
        image = [image clipImageWithScaleWithsize:CGSizeMake(screen_width, screen_height - 20)];
    } else {
        image = [image clipImageWithScaleWithsize:CGSizeMake(screen_width, screen_height - 20)];
    }
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self savePhoto:image];
    } else {
        ImagePickerViewController *imagePicker;
        if (IS_IPHONE5) {
            imagePicker = [[ImagePickerViewController alloc] initWithNibName:@"ImagePickerViewController_5" bundle:nil];
        } else {
            imagePicker = [[ImagePickerViewController alloc] initWithNibName:@"ImagePickerViewController_4" bundle:nil];
        }
        CGRect frame = CGRectMake(0, 0, screen_width, screen_height - 54);
        imagePicker.view.frame = frame;
        imagePicker.photo = image;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imagePicker];
        nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{//UIStatusBarStyleBlackOpaque
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

    if(picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum)
    {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }

    
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
//    if(_isSingle){
//        [picker dismissModalViewControllerAnimated:YES];
//    }else{
//        if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
//            self.sourceType = UIImagePickerControllerSourceTypeCamera;
//        }else{
//            [picker dismissModalViewControllerAnimated:YES];
//        }
//    }
}

- (void)savePhoto:(UIImage *)image  //选择完图片
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector (image:didFinishSavingWithError:contextInfo:) , nil ) ;
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message…
        NSLog(@"保存图片失败: %@", [error description]);
        [self showNoDevicesAlert];
        
    }
    else  // No errors
    {
        NSLog(@"保存图片成功");
        // Show message image successfully saved
        
        
        
        self.lastSavedImg = [image clipImageWithScaleWithsize:CGSizeMake(40, 40)];
        
        UIButton *btn = (UIButton *)[self.view viewWithTag:100];
        [btn setImage:self.lastSavedImg forState:UIControlStateNormal];
        
        

    }
}


- (void)showNoDevicesAlert
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat height = rect.size.height-20;
    
    UIView* alertView = [[UIView alloc] initWithFrame:CGRectMake(30, height/2-80, 260, 160)];
    alertView.backgroundColor = [UIColor whiteColor];
    UIImageView* headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"titel"]];
    headImageView.frame = CGRectMake(0, 0, alertView.bounds.size.width, 40);
    [alertView addSubview:headImageView];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:headImageView.frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"Hint", nil);
    [alertView addSubview:titleLabel];
    
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 200, 80)];
    nameLabel.text = NSLocalizedString(@"CAME_SAVE_ERRO", nil);
    nameLabel.numberOfLines = 0;
    [alertView addSubview:nameLabel];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note"]];
    [imageView sizeToFit];
    imageView.center = CGPointMake(nameLabel.bounds.size.width + imageView.bounds.size.width / 2, nameLabel.center.y);
    [alertView addSubview:imageView];
    
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, nameLabel.frame.size.height + nameLabel.frame.origin.y, alertView.bounds.size.width, 40);
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"list-normal"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"list-pressed"] forState:UIControlStateNormal];
    [self.view addSubview:alertView];
    [cancelButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onAlertCancle:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:cancelButton];
}

- (void)onAlertCancle:(UIButton*)button
{
    [button.superview removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}




// 打印信息，仅做演示
//- (void)printALAssetInfo:(ALAsset*)asset
//{
//    //取图片的url
//    NSString *photoURL=[NSString stringWithFormat:@"%@",asset.defaultRepresentation.url];
//    NSLog(@"photoURL:%@", photoURL);
//    // 取图片
//    UIImage* photo = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//    NSLog(@"PHOTO:%@", photo);
//    NSLog(@"photoSize:%@", NSStringFromCGSize(photo.size));
//    // 取图片缩图图
//    UIImage* photoThumbnail = [UIImage imageWithCGImage:asset.thumbnail];
//    NSLog(@"PHOTO2:%@", photoThumbnail);
//    NSLog(@"photoSize2:%@", NSStringFromCGSize(photoThumbnail.size));
//}

-(void)loadImageFromPhotoLibrary
{
    
    //__block UIImage *lastImg = [[UIImage alloc] init];
    __weak typeof(self)  weakSelf = self;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    
                    UIImage *img = [UIImage imageWithCGImage:result.thumbnail];
                    weakSelf.lastSavedImg = [img clipImageWithScaleWithsize:CGSizeMake(40, 40)];
                    
                    UIButton *btn = (UIButton *)[weakSelf.view viewWithTag:100];
                    [btn setImage:weakSelf.lastSavedImg forState:UIControlStateNormal];
                    //NSLog(@"photoSize:%@", NSStringFromCGSize(self.lastSavedImg.size));
                }
            }];
        } else {
            
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed.");
    }];
    

//    if(lastImg != nil)
//    {
//        self.lastSavedImg = lastImg;
//    }
//    
//    [lastImg release];
    
    
    
    
//    // 为了防止界面卡住，可以异步执行
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        __block UIImage *lastImg = nil;
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            if (group) {
//                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                    if (result) {
//  
//                        UIImage *img = [UIImage imageWithCGImage:result.thumbnail];
//                        lastImg = img;
//                        NSLog(@"photoSize:%@", NSStringFromCGSize(img.size));
//                    }
//                }];
//            } else {
//
//            }
//        } failureBlock:^(NSError *error) {
//            NSLog(@"Failed.");
//        }];
//        
//        
//        UIButton *btn = (UIButton *)[self.view viewWithTag:100];
//        if(btn != nil && lastImg != nil)
//        {            
//            [btn setImage:lastImg forState:UIControlStateNormal];
//            self.lastSavedImg = lastImg;
//        }
//        
//        [library release];
    
//        // 获取相册每个组里的具体照片
//        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
//            if (result!=nil) {
//                // 检查是否是照片，还可能是视频或其它的
//                // 所以这里我们还能类举出枚举视频的方法。。。
//                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
//                    [self printALAssetInfo:result];
//                }
//            }
//        };
//        //获取相册的组
//        ALAssetsLibraryGroupsEnumerationResultsBlock groupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
//            if (group!=nil) {
//                NSString *groupInfo=[NSString stringWithFormat:@"%@",group];
//                NSLog(@"GROUP INFO:%@",groupInfo);
//                
//                [group enumerateAssetsUsingBlock:groupEnumerAtion];
//            }
//        };
//        
//        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error){
//            // 相册访问失败的回调，可以打印一下失败原因
//            NSLog(@"相册访问失败，ERROR:%@", [error localizedDescription]);
//        };
//        
//        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
//        [library enumerateGroupsWithTypes:ALAssetsGroupAll
//                               usingBlock:groupsEnumeration
//                             failureBlock:failureblock];
//        [library release];
//    });
    
}

// 同上面的原理，我们再做一个根据URL取图片及缩略图的方法
//- (void)loadImageForURL:(NSURL*)photoUrl
//{
//    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
//    [assetLibrary assetForURL:photoUrl
//                  resultBlock:^(ALAsset *asset)
//     {
//         [self printALAssetInfo:asset];
//     }
//                 failureBlock:^(NSError *error)
//     {
//         NSLog(@"error=%@",error);
//     }];
//}


@end
