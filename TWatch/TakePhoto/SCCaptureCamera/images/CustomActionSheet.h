//
//  CustomActionSheet.h
//  SCCaptureCameraDemo
//
//  Created by QFITS－iOS on 15/7/29.
//  Copyright (c) 2015年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActionSheet : UIActionSheet
{
    UIToolbar* toolBar;
    UIView* view;
}

@property(nonatomic,retain)UIView* view;
@property(nonatomic,retain)UIToolbar* toolBar;


/*因为是通过给ActionSheet 加 Button来改变ActionSheet, 所以大小要与actionsheet的button数有关
 
 *height = 84, 134, 184, 234, 284, 334, 384, 434, 484
 
 *如果要用self.view = anotherview.  那么another的大小也必须与view的大小一样
 
 */

-(id)initWithHeight:(float)height WithSheetTitle:(NSString*)title;
@end
