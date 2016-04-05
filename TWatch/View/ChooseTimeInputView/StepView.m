//
//  StepView.m
//  TWatch
//
//  Created by LDHS－MACmini on 15/7/31.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "StepView.h"
#import "SportModel.h"

@implementation StepView
{
    CAShapeLayer *drawLayer;
    CGFloat bottomHeight;
    CGFloat topHeight;
    NSCalendar *calendar;
    NSCalendarUnit unit;
    
    CAShapeLayer *dataLayer;
    CAShapeLayer *selectLayer;
    UILabel * selectView;
    
    int data[24];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        bottomHeight=40;
        topHeight=30;
        [self initLayer];
        [self initBottomView];
        [self initLeftView];
        self.userInteractionEnabled=YES;
        calendar=[NSCalendar currentCalendar];
        unit=NSCalendarUnitHour;
        
        dataLayer = [CAShapeLayer new];
        dataLayer.fillColor = nil;
        dataLayer.lineCap = kCALineCapRound;
        dataLayer.frame = self.bounds;
        dataLayer.strokeColor=[UIColor yellowColor].CGColor;
       // dataLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:2], nil] ;//虚线 前1是内容宽度，后1是间隔宽度
        
        [self.layer addSublayer:dataLayer];
        
        selectLayer = [CAShapeLayer new];
        selectLayer.fillColor = nil;
        selectLayer.lineCap = kCALineCapRound;
        selectLayer.frame = self.bounds;
        selectLayer.strokeColor=[UIColor redColor].CGColor;
        [self.layer addSublayer:selectLayer]; 
        
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:singleRecognizer];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];

    }
    return  self;
}

-(void)initBottomView{
    UILabel *_titleView;
    
    CGRect frame;
    CGFloat viewWidth=self.frame.size.width/13.f;
    CGFloat viewHeight=bottomHeight;
    CGFloat viewY=self.frame.size.height-bottomHeight+10;
    for (int i=0; i<=12; i++) {
        frame=CGRectMake(viewWidth*i, viewY, viewWidth, viewHeight);
        _titleView=[[UILabel alloc]initWithFrame:frame];
        _titleView.textAlignment=NSTextAlignmentCenter;
        _titleView.font=[UIFont boldSystemFontOfSize:13];
        _titleView.textColor= RGBColor(56, 153, 233);
        if(i == 12)
        {
            _titleView.text = [NSString stringWithFormat:@"%d",0];
        }
        else
        {
            _titleView.text=[NSString stringWithFormat:@"%d",i*2];
        }
        [self addSubview:_titleView];
    }
}

-(void)initLeftView{
    CGFloat viewHeight=(self.frame.size.height-bottomHeight-topHeight)/4;
    CGFloat viewWidth=80;
    CGRect frame;
    UILabel *_titleView;
    int index=4000;
    for (int i=0; i<4; i++) {
        
        frame=CGRectMake(5, topHeight+viewHeight*i, viewWidth, 20);

        _titleView=[[UILabel alloc]initWithFrame:frame];
        _titleView.textAlignment=NSTextAlignmentLeft;
        _titleView.font=[UIFont boldSystemFontOfSize:13];
        _titleView.textColor= RGBColor(56, 153, 233);
        _titleView.text=[NSString stringWithFormat:@"%d",index];
        [self addSubview:_titleView];
        index-=1000;
    }
}

-(void)initLayer{
    drawLayer = [CAShapeLayer new];
    [self.layer addSublayer:drawLayer];
    
    drawLayer.fillColor = nil;
    drawLayer.lineCap = kCALineCapRound;
    drawLayer.frame = self.bounds;
    drawLayer.strokeColor= RGBColor(56, 153, 163).CGColor;
    drawLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:2], nil] ;//虚线 前1是内容宽度，后1是间隔宽度
    
    UIBezierPath *linePath=[[UIBezierPath alloc]init];
    linePath.lineWidth=0.1;
    
    CGFloat viewHeight=(self.frame.size.height-bottomHeight-topHeight)/4;
    CGPoint point;
    for (int i=0; i<5; i++) {
        point=CGPointMake(20, topHeight+i*viewHeight+10);
        [linePath moveToPoint:point];
        point=CGPointMake(self.frame.size.width, topHeight+i*viewHeight+10);
        [linePath addLineToPoint:point];
    }
    drawLayer.path=linePath.CGPath;
}

-(void)toChangeData:(NSArray *)array{
    for (int i=0; i<24; i++) {
         data[i]=0;
    }
    NSDateComponents *comm;
//    for (WatchBean *bean in array) {
//        comm= [calendar components:unit fromDate:bean.dateTime];
//        if (bean.dataType==2) {//是步
//            data[comm.hour]+=bean.step;
//        }
//    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for(SportModel* model in array){
        NSDate* date = [formatter dateFromString:model.sportTime];
        comm = [calendar components:unit fromDate:date];
        data[comm.hour]+=model.sportData;
    }
    
    
    UIBezierPath *dataPath=[[UIBezierPath alloc]init];
    dataPath.lineWidth=0.3;
    CGFloat lineX,lineY;
    CGFloat viewWidth=self.frame.size.width/26.f;
    CGPoint point;
    CGFloat viewHeight=(self.frame.size.height-bottomHeight-topHeight)/5000.f;
    for (int i=0; i<24;i++) {
        lineX=viewWidth*i+viewWidth;
        lineY=self.frame.size.height-topHeight-(data[i])*viewHeight;
        point=CGPointMake(lineX, lineY);
        if (i==0) {
            [dataPath moveToPoint:point];
        }else{
            [dataPath addLineToPoint:point];
        }
    }
    lineX=viewWidth*25;
    lineY=self.frame.size.height-topHeight;
    point=CGPointMake(lineX, lineY);
    
    [dataPath addLineToPoint:point];
    
    
    dataLayer.path=dataPath.CGPath;
}

- (void)handleSingleTapFrom:(UITapGestureRecognizer*)recognizer {
    CGPoint point= [recognizer locationInView:self];
    
    [self toDrawSelectLine:point];
}

- (void) handlePan: (UIPanGestureRecognizer *)rec{
    CGPoint point = [rec locationInView:self];
    
    [self toDrawSelectLine:point];
}

-(void)toDrawSelectLine:(CGPoint)point{
    UIBezierPath *linePath=[[UIBezierPath alloc]init];
    linePath.lineWidth=0.1;
    
    CGFloat viewWidth=self.frame.size.width/26.f;
    
    int index=(((int)point.x)/((int)viewWidth));
    
    NSLog(@"index =%i",index);
    
    if (index<=0||index>24) {
        return;
    }
    
    point.x=index*viewWidth;
    
    
    point=CGPointMake(point.x, topHeight+10);
    [linePath moveToPoint:point];
    point=CGPointMake(point.x, self.frame.size.height-bottomHeight+10);
    [linePath addLineToPoint:point];
    
    selectLayer.path=linePath.CGPath;
    
    if (selectView) {
        [selectView removeFromSuperview];
    }
    
    selectView=[[UILabel alloc]initWithFrame:CGRectMake(point.x-viewWidth-10, 10, 40, 20)];
    selectView.textAlignment=NSTextAlignmentCenter;
    selectView.font=[UIFont boldSystemFontOfSize:13];
    selectView.textColor=[UIColor redColor];
    selectView.text=[NSString stringWithFormat:@"%d",data[index-1]];
    [self addSubview:selectView];

}


@end
