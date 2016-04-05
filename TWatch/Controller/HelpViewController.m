//
//  HelpViewController.m
//  TWatch
//
//  Created by HMM－MACmini on 15/12/14.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "HelpViewController.h"
#import "Masonry.h"

#define KWITHD self.view.bounds.size.width
#define KHIGHT self.view.bounds.size.height

@interface HelpViewController ()

@property(nonatomic,strong)UIScrollView * bgScrollView;
@property(nonatomic,strong)UILabel * topLabel1;
@property(nonatomic,strong)UILabel * label1;
@property(nonatomic,strong)UILabel * topLabel2;
@property(nonatomic,strong)UILabel * label2;
@property(nonatomic,strong)UILabel * topLabel3;
@property(nonatomic,strong)UILabel * label3;
@property(nonatomic,strong)UILabel * topLabel4;
@property(nonatomic,strong)UILabel * label4;
@property(nonatomic,strong)UILabel * topLabel5;
@property(nonatomic,strong)UILabel * label5;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view from its nib.
    self.backBtn.frame = CGRectMake(0, screen_height-40, screen_width, 40);
    self.title = NSLocalizedString(@"帮助", nil);
    
    //帮助界面GUI布局
    [self createHelperGUI];
    
}

#pragma mark  帮助界面GUI布局
-(void)createHelperGUI
{
    
       //滚动视图
    _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    _bgScrollView.backgroundColor = [UIColor clearColor];
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.showsVerticalScrollIndicator = NO;
    _bgScrollView.frame = self.view.bounds;
    
    if (screen_height  == 480) {
        _bgScrollView.contentSize = CGSizeMake(KWITHD, 568);
    }else
        _bgScrollView.contentSize = CGSizeMake(KWITHD, KHIGHT);
    [self.view  addSubview:_bgScrollView];
       //第一个label
    _topLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 75, KWITHD- 60, 15)];
    _topLabel1.text =  NSLocalizedString(@"手表是否在手机附近？", nil);
    _topLabel1.textColor = [UIColor blackColor];
    _topLabel1.font = [UIFont systemFontOfSize:14];
    [_bgScrollView addSubview:_topLabel1];
    
    _label1 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_topLabel1.frame) , KWITHD - 60, 50)];
    _label1.text =  NSLocalizedString(@"华唛手表使用蓝牙和手机连接，所以当连接手表时，手机和手表的距离越近越有利于找到手表。", nil);
    _label1.textColor = [UIColor lightGrayColor];
    _label1.numberOfLines = 0;
    _label1.font = [UIFont systemFontOfSize:12];
    [_bgScrollView addSubview:_label1];
    
    //第二个Label
    _topLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_label1.frame),KWITHD - 60, 15)];
    _topLabel2.text =  NSLocalizedString(@"蓝牙是否已开启？", nil);
    _topLabel2.textColor = [UIColor blackColor];
    _topLabel2.font = [UIFont systemFontOfSize:14];
    [_bgScrollView addSubview:_topLabel2];
    
    _label2 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_topLabel2.frame) , KWITHD - 60, 110)];
    _label2.text = NSLocalizedString(@"如果手表有电，且贴近手机仍无法被查找到，请检查手表蓝牙是否开启或尝试将手表蓝牙关闭，长按3H位按键3至5秒钟，12H位指示灯闪烁一次，稍等片刻，再打开蓝牙，重新搜索手表。", nil);
    _label2.textColor = [UIColor lightGrayColor];
    _label2.numberOfLines = 0;
    _label2.font = [UIFont systemFontOfSize:12];
    [_bgScrollView addSubview:_label2];

    //第三个Label
    _topLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_label2.frame),KWITHD - 60, 15)];
    _topLabel3.text =  NSLocalizedString(@"手表已和其他手机绑定？", nil);
    _topLabel3.textColor = [UIColor blackColor];
    _topLabel3.font = [UIFont systemFontOfSize:14];
    [_bgScrollView addSubview:_topLabel3];
    
    _label3 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_topLabel3.frame) , KWITHD - 60, 50)];
    _label3.text = NSLocalizedString(@"如果你的手表已经和其他手机绑定，并且绑定的手机仍在手表附近，这时你需要解除已经绑定的手机或者关闭已经绑定的手机蓝牙，然后重新用新手机搜索手表。", nil);
    _label3.textColor = [UIColor lightGrayColor];
    _label3.numberOfLines = 0;
    _label3.font = [UIFont systemFontOfSize:12];
    [_bgScrollView addSubview:_label3];
    
    //第四个Label
    _topLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_label3.frame),KWITHD - 60, 15)];
    _topLabel4.text = NSLocalizedString(@"尝试重启手机", nil);
    _topLabel4.textColor = [UIColor blackColor];
    _topLabel4.font = [UIFont systemFontOfSize:14];
    [_bgScrollView addSubview:_topLabel4];
    
    _label4 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_topLabel4.frame) , KWITHD - 60, 40)];
    _label4.text = NSLocalizedString(@"请尝试重启手机，重新打开华唛智能应用。", nil);
    _label4.textColor = [UIColor lightGrayColor];
    _label4.numberOfLines = 0;
    _label4.font = [UIFont systemFontOfSize:12];
    [_bgScrollView addSubview:_label4];

    //第五个Label
    _topLabel5 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_label4.frame),KWITHD - 60, 15)];
    _topLabel5.text =  NSLocalizedString(@"手表电量是否耗尽？", nil);
    _topLabel5.textColor = [UIColor blackColor];
    _topLabel5.font = [UIFont systemFontOfSize:14];
    [_bgScrollView addSubview:_topLabel5];
    
    _label5 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_topLabel5.frame) , KWITHD - 60, 60)];
    _label5.text = NSLocalizedString(@"如果手表和手机距离很近还是没有查找到，可能是因为手表没电了。请将手表更换电池，这时再尝试使用手机连接手表。", nil);
    _label5.textColor = [UIColor lightGrayColor];
    _label5.numberOfLines = 0;
    _label5.font = [UIFont systemFontOfSize:12];
    [_bgScrollView addSubview:_label5];


}



@end
