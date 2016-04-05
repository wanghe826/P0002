//
//  PersonInfoSettingViewController.m
//  TWatch
//
//  Created by QFITS－iOS on 15/7/31.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//
#import "UIImage+ResizeToRadius.h"
#import "PersonInfoSettingViewController.h"
#import "XLForm.h"
#import "SCNavigationController.h"
#import "PersonInfoModel.h"
#import "UserDefaultsUtils.h"
#import "SVProgressHUD.h"
#import "AppUtils.h"
@interface PersonInfoSettingViewController () <UITextViewDelegate> {
    PersonInfoModel* _personInfoModel;
    
    UIButton* _headIconView;
    UITextField* _nickName;
}
//@property(nonatomic,strong) XLFormRowDescriptor* touxiangRow;
//@property(nonatomic,strong) XLFormRowDescriptor* usernameRow;
@property(nonatomic,strong) XLFormRowDescriptor* sexRow;
@property(nonatomic,strong) XLFormRowDescriptor* birthRow;
@property(nonatomic,strong) XLFormRowDescriptor* weightRow;
@property(nonatomic,strong) XLFormRowDescriptor* heightRow;

@end

@implementation PersonInfoSettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if([[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo]){
        NSData* data = [[NSUserDefaults standardUserDefaults] valueForKey:APersonInfo];
        _personInfoModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    [self initNavigationBarView];
    self.tableView.separatorColor = SeparatorColor;
    @autoreleasepool {
        [self initialForm];
    }
    self.tableView.scrollEnabled = NO;
    
}

-(UIView*) head
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 120)];
    view.backgroundColor = [UIColor clearColor];
    _headIconView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80,80)];
    _headIconView.backgroundColor = [UIColor grayColor];
    _headIconView.layer.cornerRadius = 40.0f;
    //    [_headIconView setImage:[UIImage imageNamed:@"icon_personal_head"] forState:UIControlStateNormal];
    [_headIconView setBackgroundImage:[UIImage imageNamed:@"icon_personal_head"] forState:UIControlStateNormal];
    _headIconView.center = CGPointMake(self.view.center.x, 45);
    [_headIconView addTarget:self action:@selector(touxiangSelect) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_headIconView];
    
    _nickName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    _nickName.adjustsFontSizeToFitWidth = YES;
    _nickName.delegate = self;
    _nickName.textAlignment = NSTextAlignmentCenter;
    _nickName.placeholder = NSLocalizedString(@"华唛科技", nil);
    _nickName.center = CGPointMake(self.view.center.x, 100);
    [view addSubview:_nickName];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tapGes];
    
    _headIconView.clipsToBounds = YES;
    _headIconView.layer.cornerRadius = _headIconView.frame.size.width / 2.0;
    
    return view;
}

#pragma mark - UITextViewDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)tapView {
    [self.view endEditing:YES];
}

-(UIView*)foot
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 60)];
    view.backgroundColor = [UIColor clearColor];
    UIButton* saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    saveBtn.frame = CGRectMake(0, 0, 30*(460/68), 30);
    saveBtn.frame = CGRectMake(0, 0, 230, 34);
    

    if ([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"]) {
        
        [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_personal_save_avr_en"] forState:UIControlStateNormal];
        [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_personal_save_sel_en"] forState:UIControlStateHighlighted];
        
    }else
    {
        [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_personal_save_avr"] forState:UIControlStateNormal];
        [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_personal_save_sel"] forState:UIControlStateHighlighted];
    }
    
//    saveBtn.layer.cornerRadius = 5.0f;
//    saveBtn.layer.borderColor = [UIColor blackColor].CGColor;
//    
//    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [saveBtn setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
//    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [saveBtn addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.center = view.center;
    [view addSubview:saveBtn];
    return view;
}


- (void) initialForm
{
    XLFormDescriptor* form = [XLFormDescriptor formDescriptor];
    
    self.tableView.tableHeaderView = [self head];
    self.tableView.tableFooterView = [self foot];
    
    
    XLFormSectionDescriptor* section = [XLFormSectionDescriptor formSection];


    UIImage* image = [UIImage imageNamed:@"head_icon"];
    NSString* userName = NSLocalizedString(@"华唛智能", nil);
    NSString* sex = NSLocalizedString(@"男", nil);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-mm-dd"];
    
    
    NSDate* date = [formatter dateFromString:@"1990-01-31"];
    NSString* weightStr = @"60 Kg";
    NSString* heightStr = @"170 CM";
    if (_personInfoModel) {
        image = [UIImage imageWithData:_personInfoModel.touxiang];
        userName = _personInfoModel.username;
        sex = [_personInfoModel.sex isEqualToString:@"1"]?NSLocalizedString(@"男", nil):NSLocalizedString(@"女", nil);
        date = _personInfoModel.birthday;
        weightStr = _personInfoModel.weight;
        heightStr = _personInfoModel.height;
    }else{
        _personInfoModel = [[PersonInfoModel alloc] init];
        _personInfoModel.touxiang = UIImagePNGRepresentation([UIImage imageNamed:@"head_icon"]);
    }
    
//    [_headIconView setImage:image forState:UIControlStateNormal];
    [_headIconView setBackgroundImage:image forState:UIControlStateNormal];
    _nickName.text = userName;
    
    self.sexRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeSelectorActionSheet title:NSLocalizedString(@"性别", nil)];
    self.sexRow.value = sex;
   
    
    self.sexRow.selectorOptions = @[NSLocalizedString(@"男", nil),NSLocalizedString(@"女", nil) ];
    [section addFormRow:self.sexRow];
    
    self.birthRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeDate title:NSLocalizedString(@"生日", nil)];
    [self.birthRow.cellConfigAtConfigure setObject:[NSDate date] forKey:@"maximumDate"];
    self.birthRow.value = date;
    [section addFormRow:self.birthRow];
    [self.birthRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_gender_birth"] forKey:@"imageView.image"];
    
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:280];

    for(int i=0;i<221;++i){
        [array addObject:[NSString stringWithFormat:@"%d Kg",i+30]];
    }
    self.weightRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeSelectorPickerView title:NSLocalizedString(@"体重", nil)];
    self.weightRow.value = weightStr;
    self.weightRow.selectorOptions = array;
    [self.weightRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_weight"] forKey:@"imageView.image"];
    
    NSMutableArray* array2 = [[NSMutableArray alloc] initWithCapacity:280];
    for(int i=0;i<191;++i){
        [array2 addObject:[NSString stringWithFormat:@"%d CM",i+60]];
    }
    self.heightRow = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeSelectorPickerView title:NSLocalizedString(@"身高", nil)];
    self.heightRow.value = heightStr;
    self.heightRow.selectorOptions = array2;
    [section addFormRow:self.heightRow];
    [section addFormRow:self.weightRow];
    
    
    
    
    if([sex isEqualToString:NSLocalizedString(@"男", nil)])
    {
        [self.sexRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_gender_male"] forKey:@"imageView.image"];
        [self.heightRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_height_male"] forKey:@"imageView.image"];
    }
    else
    {
        [self.sexRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_gender_female"] forKey:@"imageView.image"];
        [self.heightRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_height_female"] forKey:@"imageView.image"];
    }
    
    
    
    [form addFormSection:section];
    self.form = form;
    
}

- (void) touxiangSelect
{
    [self.view endEditing:YES];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:NSLocalizedString(@"拍照", nil) otherButtonTitles:NSLocalizedString(@"从相册选择", nil), nil];
    [actionSheet showInView:self.view];
}

- (void)initNavigationBarView
{
    self.title = NSLocalizedString(@"个人信息", nil);
        
    UIButton *btnNone=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    btnNone.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
    UIBarButtonItem *itemNone=[[UIBarButtonItem alloc]initWithCustomView:btnNone];
    self.navigationItem.leftBarButtonItem=itemNone;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationController.navigationBar.barTintColor = RGBColor(0x2f, 0x34, 0x3e);
    
    UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, screen_height-35, screen_width, 35)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.layer.borderColor = [UIColor grayColor].CGColor;
    backBtn.frame = CGRectMake(0, screen_height-46, screen_width, 35);
//    [backBtn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    backBtn.center = view.center;
    [backBtn addTarget:self action:@selector(returnToBackVc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void) returnToBackVc
{
   [self.navigationController popViewControllerAnimated:YES];
}

- (void)commit
{
    [self.navigationController popViewControllerAnimated:YES];
    if([self checkData]){
        _personInfoModel.username = _nickName.text;
        _personInfoModel.sex = [self.sexRow.value isEqualToString:NSLocalizedString(@"男", nil)]?@"1":@"2";
        _personInfoModel.birthday = self.birthRow.value;
        _personInfoModel.weight = self.weightRow.value;
        _personInfoModel.height = self.heightRow.value;
        
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_personInfoModel];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:APersonInfo];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"修改成功", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (BOOL)checkData{
    if([_nickName.text isEqualToString:@""] || !_nickName){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请填写昵称", nil)];
        return NO;
    }
    if ([self.sexRow.value isEqualToString:@""] || !self.sexRow.value) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请填写性别", nil)];
        return NO;
    }
    if(!self.birthRow.value){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请填写生日", nil)];
        return NO;
    }
    if ([self.weightRow.value isEqualToString:@""] || !self.weightRow.value) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请填写体重", nil)];
        return NO;
    }
    if([self.heightRow.value isEqualToString:@""] || !self.heightRow.value){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请填写身高", nil)];
        return NO;
    }
    return YES;
}

- (void) personBackToLord
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){         //拍照
//        SCNavigationController *nav = [[SCNavigationController alloc] init];
//        nav.scNaigationDelegate = self;
//        nav.isPersonTake = YES;
//        [nav showCameraWithParentController:self];
        
        //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
//        [self presentModalViewController:picker animated:YES];
        [self.navigationController presentViewController:picker animated:YES completion:nil];
        
    }else if(buttonIndex==1){   //从相册选择
        UIImagePickerController* pickVc = [[UIImagePickerController alloc] init];
        pickVc.delegate = self;
        pickVc.allowsEditing = YES;
        pickVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickVc animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"--->%lu",(unsigned long)[info count]);
    if([[[info allValues] objectAtIndex:0] isKindOfClass:[UIImage class]]){
        UIImage* image  = [[info allValues] objectAtIndex:0];
        [self setImageAndSave:image];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}





-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SCNavigationController delegate
- (void)didTakePicture:(SCNavigationController *)navigationController image:(UIImage *)image {
    [self setImageAndSave:image];
}

- (void)setImageAndSave:(UIImage*)image
{
    UIImage* myImage = [self squareImageFromImage:image scaledToSize:800];
    myImage = [myImage cutImageWithRadius:15 ];
    
    //    _headIconView.image = myImage;
    //    [_headIconView setImage:myImage forState:UIControlStateNormal];
    [_headIconView setBackgroundImage:myImage forState:UIControlStateNormal];
    _headIconView.clipsToBounds = YES;
    _headIconView.layer.cornerRadius = _headIconView.frame.size.width / 2.0;
    [self.tableView reloadData];
    
    
    
    //判断图片是不是png格式的文件
    if (UIImagePNGRepresentation(myImage)) {
        //返回为png图像。
        _personInfoModel.touxiang = UIImagePNGRepresentation(myImage);
    }else {
        //返回为JPEG图像。
        _personInfoModel.touxiang = UIImageJPEGRepresentation(myImage, 2.0);
    }
}

- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        //image原始高度为200，缩放image的高度为400pixels，所以缩放比率为2
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        //设置绘制原始图片的画笔坐标为CGPoint(-100, 0)pixels
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    //创建画板为(400x400)pixels
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //将image原始图片(400x200)pixels缩放为(800x400)pixels
    CGContextConcatCTM(context, scaleTransform);
    //origin也会从原始(-100, 0)缩放到(-200, 0)
    [image drawAtPoint:origin];
    
    //获取缩放后剪切的image图片
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    if(CGRectContainsPoint(_headIconView.frame, currentPoint))
    {
        [self touxiangSelect];
    }
}


-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    if(formRow == self.sexRow)
    {
        if([newValue isEqualToString:NSLocalizedString(@"男", nil)])
        {
            [self.sexRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_gender_male"] forKey:@"imageView.image"];
            [self.heightRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_height_male"] forKey:@"imageView.image"];
        }
        else
        {
            [self.sexRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_gender_female"] forKey:@"imageView.image"];
            [self.heightRow.cellConfig setObject:[UIImage imageNamed:@"icon_personal_height_female"] forKey:@"imageView.image"];
        }
    }
                                          
                                          
}


@end
