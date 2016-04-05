//
//  Utils.h
//  WineStore
//
//  Created by hexiao on 13-9-5.
//  Copyright (c) 2013年 hexiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayUtils : NSObject
/**
 * 显示文本
 * \param image 原始图
 * \param reSize 图片尺寸
 * \return 改变尺寸后的图
 */
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

/**
 * 显示文本
 * \param title 文本
 * \param viewController 视图
 */
+ (void)alert:(NSString*)title viewController:(UIViewController*)viewController;

@end
