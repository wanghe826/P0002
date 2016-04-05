#import "GLChooseTimeInputView.h"

@interface GLChooseTimeInputView()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ensureBarItem;

@end

@implementation GLChooseTimeInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    self.countPicker.dataSource = self;
    self.countPicker.delegate = self;
    self.datePicker.locale = [NSLocale currentLocale];
}

- (IBAction)buttonClick:(id)sender {
    if (sender == self.cancelBarItem) {
        self.itemClickBlock(YES,nil,nil);
    }
    else if (sender == self.ensureBarItem) {
        if (!self.datePicker.hidden) {
            NSDate *date = self.datePicker.date;
            self.itemClickBlock(NO,date,nil);
        }
        else if (!self.countPicker.hidden) {
            int index = [self.countPicker selectedRowInComponent:0];
            NSString *value = self.dataSource[index];
            self.itemClickBlock(NO,nil,value);
        }
    }
}

#pragma mark - picker view

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.dataSource) {
        return 1;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.dataSource) {
        return self.dataSource.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.dataSource[row];
}

@end
