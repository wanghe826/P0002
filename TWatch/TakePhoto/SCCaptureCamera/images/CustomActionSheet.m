//
//  CustomActionSheet.m
//  SCCaptureCameraDemo
//
//  Created by QFITS－iOS on 15/7/29.
//  Copyright (c) 2015年 Aevitx. All rights reserved.
//

#import "CustomActionSheet.h"

@implementation CustomActionSheet
@synthesize view;

@synthesize toolBar;

-(id)initWithHeight:(float)height WithSheetTitle:(NSString*)title
{
    self = [super init];
    
    if (self)
    {
        
        int theight = height - 40;
        
        int btnnum = theight/50;
        
        for(int i=0; i<btnnum; i++)
        {
            [self addButtonWithTitle:@" "];
            
        }
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        toolBar.barStyle = UIBarStyleBlackOpaque;
        
        
        UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:nil
                                                                       action:nil];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(done)];
        UIBarButtonItem *leftButton  = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(docancel)];
        UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
        NSArray *array = [[NSArray alloc] initWithObjects:leftButton,fixedButton,titleButton,fixedButton,rightButton,nil];
        [toolBar setItems: array];
        [self addSubview:toolBar];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, height-44)];
        
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        [self addSubview:view];
        
    }
    
    return self;
    
}

-(void)done

{
    [self dismissWithClickedButtonIndex:0 animated:YES];
    
}

-(void)docancel

{
    [self dismissWithClickedButtonIndex:0 animated:YES];
}



@end
