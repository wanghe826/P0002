/**
 选择时间视图
 */

#import <UIKit/UIKit.h>

typedef void (^BarItemClickBlock)(BOOL isCancel,NSDate * date,NSString *value);

@interface GLChooseTimeInputView : UIView

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *countPicker;
@property (copy, nonatomic) BarItemClickBlock itemClickBlock;
@property (strong, nonatomic) NSArray *dataSource;

@end
