//
//  FitnessViewController.h
//  TWatch
//
//  Created by QFITS－iOS on 15/11/7.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "CustomViewController.h"

//#define k10MinuteWidth (2*screen_width-2*screen_width/25)/144
#define k10MinuteWidth 10
#define kContentViewWidth (k10MinuteWidth*144 + 143)

@interface FitnessViewController : CustomViewController
{
    UILabel* _currentSelectLabel;
    
    float _rateHeight;
    
    int _allFootData;
    float _allFootKm;
    int _allFootTime;
    float _allFootKcal;
    
    NSMutableArray<UIView*>* _views;
    
    
    //scrollView应该偏移的位置
    int _scrollViewOffset;
}

@property (nonatomic, strong) NSArray* sportDatas;

- (void) initFitnessUI;

-(int)personWeight;
-(int)personHeight;

@end

@interface FitnessView : UIView
{
    UIImage* _image;
    NSString* _title;
}

- (instancetype) initWithFrame:(CGRect)frame
                       withImg:(UIImage*)image
                     withLabel:(NSString*)str
                    withResult:(float)rsult;

@property(assign,nonatomic) float result;
@end

@interface MyTapGestureRecognizer : UITapGestureRecognizer
@property (assign, nonatomic) int sportData;
@property (assign, nonatomic) int sportViewIndex;
@end