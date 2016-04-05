//
//  MHEventShowCell.m
//  sportsBracelets
//
//  Created by dingyl on 14/12/23.
//
//

#import "MHEventShowCell.h"

@interface MHEventShowCell()

@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation MHEventShowCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)equipCell:(MHEvent *)info {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    [formatter release];
    
    NSString *formate;
    if(is24h){
        formate = @"HH:mm yyyy.MM.dd";
    }else{
        formate = @"hh:mm a yyyy.MM.dd";
    }
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init] ;
    [formatter2 setDateFormat:formate];
    
    self.timeLabel.text = info.iTitle;
    self.dateLabel.text = [formatter2 stringFromDate:info.iDate];;
    self.contentLabel.text = info.iContent;
    [formatter2 release];
}

- (void)dealloc {
    [_dateLabel release];
    [_timeLabel release];
    [_contentLabel release];
    [super dealloc];
}
@end
