//
//  MHEventEditViewController.m
//  sportsBracelets
//
//  Created by dingyl on 14/12/23.
//
//

#import "MHEventEditViewController.h"
//#import "UIColor+Addition.h"
//#import "UIImage+Addition.h"
//#import "GLChooseTimeInputView.h"

@interface MHEventEditViewController()<UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UITextField *dateTextField;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UITextField *timeTextField;
@property (retain, nonatomic) IBOutlet UILabel *contentLabel;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (retain, nonatomic) IBOutlet UIView *containerView0;
@property (retain, nonatomic) IBOutlet UIView *containerView1;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation MHEventEditViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"EVENT", nil);
    
    [self.cancelButton setTitle:NSLocalizedString(@"Cancle", nil) forState:UIControlStateNormal];
    [self.sureButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    NSArray *btns = @[self.cancelButton,self.sureButton];
    for (UIButton *btn in btns) {
        btn.layer.cornerRadius = 4.0f;
        btn.layer.borderWidth = 1.0f;
        btn.layer.borderColor = HexRGBAlpha(0xb7b7b7, 1).CGColor;//[UIColor convertHexColorToUIColor:].CGColor;
        btn.layer.masksToBounds = YES;
        [self setButtonBackgroundImage:btn fromClolor:0xffffff forState:UIControlStateNormal];
        [self setButtonBackgroundImage:btn fromClolor:0x1499ad forState:UIControlStateHighlighted];
    }
    
    self.titleLabel.text = NSLocalizedString(@"EVENT_Title", nil);
    self.dateTimeLabel.text = NSLocalizedString(@"EVENT_Time", nil);
    self.contentLabel.text = NSLocalizedString(@"EVENT_Content", nil);
    self.dateLabel.text = NSLocalizedString(@"date", nil);
    self.timeLabel.text = NSLocalizedString(@"detailtime", nil);
    self.titleTextField.placeholder = NSLocalizedString(@"input time", nil);
    
    NSArray *views = @[self.titleTextField,self.containerView0,self.containerView1,self.contentTextView];
    for (UIView *iv in views) {
        iv.layer.cornerRadius = 4.0f;
        iv.layer.borderWidth = 1.0f;
        iv.layer.borderColor = HexRGBAlpha(0xb7b7b7, 1).CGColor;//[UIColor convertHexColorToUIColor:0xb7b7b7].CGColor;
        iv.layer.masksToBounds = YES;
    }

    if (self.isCreateFlag) {
        MHEvent *event = [[MHEvent alloc] init];
        event.iDate = [[NSDate date] dateByAddingTimeInterval:30 * 60];
        self.eventInfo = event;
    }
    
    self.titleTextField.text = self.eventInfo.iTitle;
    self.contentTextView.text = self.eventInfo.iContent;
    [self equipDateTimeTextField];
    
    
    MHEventEditViewController *weakSelf = self;
    GLChooseTimeInputView *inputView = [[NSBundle mainBundle] loadNibNamed:@"GLChooseTimeInputView" owner:self options:nil][0];
    inputView.datePicker.datePickerMode = UIDatePickerModeDate;
    inputView.datePicker.minimumDate = [NSDate date];
    BarItemClickBlock block = ^(BOOL isCancel,NSDate *date,NSString *value) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!isCancel) {
            NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
            NSDateComponents *comp1 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:strongSelf.eventInfo.iDate];
            comp1.year = comp.year;
            comp1.month = comp.month;
            comp1.day = comp.day;
            strongSelf.eventInfo.iDate = [[NSCalendar currentCalendar] dateFromComponents:comp1];
            [strongSelf equipDateTimeTextField];
        }
        [strongSelf.dateTextField resignFirstResponder];
    };
    inputView.itemClickBlock = block;
    self.dateTextField.inputView = inputView;
    
    GLChooseTimeInputView *inputView2 = [[NSBundle mainBundle] loadNibNamed:@"GLChooseTimeInputView" owner:self options:nil][0];
    inputView2.datePicker.datePickerMode = UIDatePickerModeTime;
    BarItemClickBlock block2 = ^(BOOL isCancel,NSDate *date,NSString *value) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!isCancel) {
            NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
            NSDateComponents *comp1 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:strongSelf.eventInfo.iDate];
            comp1.hour = comp.hour;
            comp1.minute = comp.minute;
            comp1.second = comp.second;
            NSDate *iDate = [[NSCalendar currentCalendar] dateFromComponents:comp1];
            if ([iDate compare:[NSDate date]] == NSOrderedAscending) {
                iDate = [iDate dateByAddingTimeInterval:(24 * 60 * 60)];
            }
            strongSelf.eventInfo.iDate = iDate;
            [strongSelf equipDateTimeTextField];
        }
        [strongSelf.timeTextField resignFirstResponder];
    };
    inputView2.itemClickBlock = block2;
    self.timeTextField.inputView = inputView2;
    
}

- (void)setButtonBackgroundImage:(UIButton *)button fromClolor:(NSInteger)hexColor forState:(UIControlState)state {
    [button setBackgroundImage:[UIImage imageFromColor:[UIColor convertHexColorToUIColor:hexColor]] forState:state];
}

- (void)dealloc {
    [_cancelButton release];
    [_sureButton release];
    [super dealloc];
}

#pragma mark - equip dateTextField,timeTextField

- (void)equipDateTimeTextField {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.eventInfo.iDate];
    self.timeTextField.text = [NSString stringWithFormat:@"%.2d:%.2d",comp.hour,comp.minute];
    self.dateTextField.text = [NSString stringWithFormat:@"%d.%d.%d",comp.year,comp.month,comp.day];
}

#pragma mark - IBAction

- (IBAction)buttonClick:(id)sender {
    if (sender == self.sureButton) {
        if ([self checkRegex]) {
            self.eventInfo.iContent = self.contentTextView.text;
            self.eventInfo.iTitle = self.titleTextField.text;
            if (self.isCreateFlag) {
                int rowId = [ApplicationDelegate insertEvent:self.eventInfo];
                if (rowId != -1) {
                    [self createNotificationWithRowID:rowId];
                }
            }
            else {
                NSArray *notys = [[UIApplication sharedApplication] scheduledLocalNotifications];
                for (UILocalNotification *noty in notys) {
                    if ([noty.userInfo[@"key"] isEqualToString:[NSString stringWithFormat:@"%d",self.eventInfo.eventID]]) {
                        [[UIApplication sharedApplication] cancelLocalNotification:noty];
                        break;
                    }
                }
                [self createNotificationWithRowID:self.eventInfo.eventID];
                [ApplicationDelegate updateEvent:self.eventInfo];
            }
        }else{
            return;
        }
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)createNotificationWithRowID:(int)rowId {
    UILocalNotification *noty = [[UILocalNotification alloc] init];
    noty.fireDate = self.eventInfo.iDate;
    noty.alertBody = self.eventInfo.iTitle;
    if([self.eventInfo.iContent length]){
        noty.alertBody = [[self.eventInfo.iTitle stringByAppendingString:@":"] stringByAppendingString:self.eventInfo.iContent];
    }
    noty.repeatInterval = 0;
    noty.userInfo = @{@"key": [NSString stringWithFormat:@"%d",rowId]};
    [[UIApplication sharedApplication] scheduleLocalNotification:noty];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)checkRegex {
    return self.titleTextField.text && ![self.titleTextField.text isEqualToString:@""];
}

- (IBAction)controlClick:(id)sender {
    if (self.contentTextView.isFirstResponder) {
        [self.contentTextView resignFirstResponder];
    }
    if (self.titleTextField.isFirstResponder) {
        [self.titleTextField resignFirstResponder];
    }
}

@end
