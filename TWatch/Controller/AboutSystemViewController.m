//
//  AboutSystemViewController
//  TWatch
//
//  Created by Bob on 15/6/12.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//
#import "FirmwareUpgradeHomeViewController.h"
#import "AboutSystemViewController.h"
#import "JGBleDeviceInfo.h"
#import <PgySDK/PgyManager.h>
#import "BLEAppContext.h"
#import "SVProgressHUD.h"
#import "FirmwareFileDownloadUtils.h"
#import "AppUtils.h"

@interface AboutSystemViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    BOOL _isAppCanUpdate;
    BOOL _isFwCanUpdate;
    UIPickerView* _filePicker;
    
    UIWebView* _webView;
}

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSMutableArray *dataArray;

@end

//http://www.tianbawatch.com/cn/index.aspx
@implementation AboutSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"shishishuaxin" object:nil];
    [self initTableView];
    [self initData];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[PgyManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(canUpdate:)];
    });
    NSLog(@"要升级的文件名是%@", ApplicationDelegate.upgradeFileName);
    self.title = NSLocalizedString(@"关于系统", nil);
}
- (void)canUpdate:(NSDictionary*)dic
{
    if(dic != nil)
    {
        _isAppCanUpdate = YES;
        [self performSelectorOnMainThread:@selector(refreshView) withObject:nil waitUntilDone:YES];
    }
}
- (void) refreshView{
    
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

- (void)back
{
    if(_webView && !_webView.isHidden){
        [_webView setHidden:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initData
{
    _isAppCanUpdate = NO;
    _isFwCanUpdate = NO;
    _dataArray = [[NSMutableArray alloc]init];
    [_dataArray addObject:NSLocalizedString(@"系统版本号", nil)];
    [_dataArray addObject:NSLocalizedString(@"设备固件版本号", nil)];
    [_dataArray addObject:NSLocalizedString(@"电池电量状态", nil)];
}

- (void)openNet
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.tianbawatch.com/cn/index.aspx"]];
}


- (void)initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,screen_width, screen_height - 64 ) style:UITableViewStylePlain];
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = SeparatorColor;
    _tableView.backgroundColor  = [UIColor clearColor];
//    _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    _tableView.scrollEnabled = NO;
    _tableView.rowHeight = 60;
    [self.view addSubview:_tableView];
}

#pragma mark- UITableVIew Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectio
//{
//    return 0.01;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.01;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        if(_isAppCanUpdate)
        {
            UIView* view = [cell.contentView viewWithTag:1234];
            if(view)
            {
                view.hidden = NO;
            }
            else
            {
                UIImageView* newApp = [[UIImageView alloc] initWithFrame:CGRectMake(110, 20, 40, 20)];
                newApp.image = [UIImage imageNamed:@"img_about_new"];
                newApp.tag = 1234;
                [cell.contentView addSubview:newApp];
            }
//            cell.imageView.image = [UIImage imageNamed:@"img_about_new"];
        }
        else
        {
            UIView* view = [cell.contentView viewWithTag:1234];
            if(view)
            {
                view.hidden = YES;
            }
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 1) {
        if(ApplicationDelegate.upgradeFileName!=nil)
        {
            UIView* view = [cell.contentView viewWithTag:1235];
            if(view)
            {
                view.hidden = NO;
            }
            else
            {
                UIImageView* new = [[UIImageView alloc] initWithFrame:CGRectMake(140, 20, 40, 20)];
                
                if([[AppUtils getCurrentLanguagesStr] isEqualToString:@"en-CN"])
                {
                    new.image = [UIImage imageNamed:@"img_about_new_en"];
                }
                else
                {
                    new.image = [UIImage imageNamed:@"img_about_new"];
                }
                
                [cell.contentView addSubview:new];
                new.tag = 1235;
            }
//            cell.imageView.image = [UIImage imageNamed:@"img_about_new"];
        }
        else
        {
            UIView* view = [cell.contentView viewWithTag:1235];
            if(view)
            {
                view.hidden = YES;
            }
        }
        
        if([BLEAppContext shareBleAppContext].isAuthorized != YES)
        {
            UIView* view = [cell.contentView viewWithTag:1235];
            if(view)
            {
                view.hidden = YES;
            }
        }
        
        if([BLEAppContext shareBleAppContext].isPaired == YES){
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if(ApplicationDelegate.deviceVer){
                NSString* firmwareVersion = ApplicationDelegate.deviceVer;
                
                NSString* fwVersion = [firmwareVersion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", fwVersion];
            }
        }else{
            cell.detailTextLabel.text = @"";
        }
        
    }
    
    if(indexPath.row == 2){
        
        if([BLEAppContext shareBleAppContext].isConnected == YES){
            int pow = ApplicationDelegate.power;
            UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40, 25, 25, 10)];
            iv.tag = 365;
            NSString* ivStr;
            
            if (pow < 30) {
                ivStr = @"img_battery_low";
            } else if (pow >= 30 && pow < 60) {
                ivStr = @"img_battery_half";
            } else if (pow >= 60 && pow < 80) {
                ivStr = @"img_battery_half";
            } else if (pow >= 80) {
                ivStr = @"img_battery_full";
            }
            
            
            iv.image = [UIImage imageNamed:ivStr];
            if(pow!=0){
                [cell.contentView addSubview:iv];
            }
        }else{
            for(UIView* view in cell.contentView.subviews){
                if(view.tag == 365){
                    [view removeFromSuperview];
                }
            }
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if (indexPath.row == 0){
        
        if(![FirmwareFileDownloadUtils isConnectionAvailable])
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接不可用", @"")];
            return;
        }
        
        [[PgyManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(checkAppUpdate:)];
    }
    else if(indexPath.row == 1){
        if(![BLEAppContext shareBleAppContext].isConnected || ![BLEAppContext shareBleAppContext].isPaired){
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请连接手表", @"")];
            return;
        }else if([BLEAppContext shareBleAppContext].isConnected && [BLEAppContext shareBleAppContext].isPaired){
            [self checkFirmwareVersionAndUpdate];
        }
    }
}


- (void) checkAppUpdate:(NSDictionary*)dictionary{
    if(dictionary == nil){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"暂无新版本，请耐心等待", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
        [alertView show];
    }else{
        [[PgyManager sharedPgyManager] checkUpdate];
    }
    
}

- (void) checkFirmwareVersionAndUpdate
{
    if(ApplicationDelegate.upgradeFileName==nil)
    {
        if(![FirmwareFileDownloadUtils isConnectionAvailable])
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接不可用", @"")];
            return;
        }
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"暂无新版本，请耐心等待", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
        [alertView show];
        
        if([[JGBLEManager sharedManager] downloadBinFile])
        {
            dispatch_async(dispatch_get_global_queue(0, 0), [[JGBLEManager sharedManager] downloadBinFile]);
        }
        return;
    }
    
    FirmwareUpgradeHomeViewController* frmwareUpgradeVc = [[FirmwareUpgradeHomeViewController alloc] init];
    [self presentViewController:frmwareUpgradeVc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end