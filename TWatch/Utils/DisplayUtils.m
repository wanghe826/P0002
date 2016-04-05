//
//  Utils.m
//  WineStore
//
//  Created by hexiao on 13-9-5.
//  Copyright (c) 2013年 hexiao. All rights reserved.
//

#import "DisplayUtils.h"
#import "MBProgressHUD.h"

@implementation DisplayUtils


/**
 * 显示文本
 * \param image 原始图
 * \param reSize 图片尺寸
 * \return 改变尺寸后的图
 */
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

/**
 * 显示文本
 * \param title 文本
 * \param viewController 视图
 */
+ (void)alert:(NSString*)title viewController:(UIViewController*)viewController
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = title;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1];
}

@end
