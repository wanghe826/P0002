//
//  UIImage+ImageType.m
//  TWatch
//
//  Created by QFITS－iOS on 15/8/4.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "UIImage+ImageType.h"

@implementation UIImage (ImageType)
-(int) imageType:(long) flag

{
    int rtn = 0;
    
    //  long r = (flag^0b01000111010011100101000010001001);
    
    //JPEG File Interchange Format .jpg ff d8 ff e0
    
    if (((flag ^0xe0ffd8ff)) ==0x00000000) {
        
        rtn = 1;
        
    }
    
    //PNG format .png 89 50 4e 47
    
    else if (((flag^0x474e5089)) ==0x00000000) {
        
        rtn = 2;
        
    }
    
    return rtn;
    
}
@end
