//
//  MHEventShowViewController.m
//  sportsBracelets
//
//  Created by dingyl on 14/12/23.
//
//

#import "MHEventShowViewController.h"
#import "UIColor+Addition.h"
#import "UIImage+Addition.h"
#import "MHEventShowCell.h"
#import "MHEventEditViewController.h"

@interface MHEventShowViewController()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) IBOutlet UIButton *addEventButton;
@property (retain, nonatomic) IBOutlet UILabel *noEventLabel;
@property (retain, nonatomic) IBOutlet UITableView *eventShowTable;
@property (retain, nonatomic) NSMutableArray *dataSource;

@end

@implementation MHEventShowViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor convertHexColorToUIColor:0x1ba9ba];
    self.title = NSLocalizedString(@"EVENT", nil);
    self.view.backgroundColor = [UIColor convertHexColorToUIColor:0xe0e0e0];
    [self configureSubView];
}

- (void)configureSubView {
    [self.addEventButton setTitle:NSLocalizedString(@"New_Event", nil) forState:UIControlStateNormal];
    [self setButtonBackgroundImage:self.addEventButton fromClolor:0xffffff forState:UIControlStateNormal];
    [self setButtonBackgroundImage:self.addEventButton fromClolor:0x1499ad forState:UIControlStateHighlighted];
    self.addEventButton.layer.cornerRadius = 4.0f;
    self.addEventButton.layer.borderWidth = 1.0f;
    self.addEventButton.layer.borderColor = [UIColor convertHexColorToUIColor:0xb7b7b7].CGColor;
    self.addEventButton.layer.masksToBounds = YES;
    self.noEventLabel.text = NSLocalizedString(@"no_event", nil);
    self.eventShowTable.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataSource = [ApplicationDelegate queryEvents];
    [self visibleTable];
    [self.eventShowTable reloadData];
}

- (void)setButtonBackgroundImage:(UIButton *)button fromClolor:(NSInteger)hexColor forState:(UIControlState)state {
    [button setBackgroundImage:[UIImage imageFromColor:[UIColor convertHexColorToUIColor:hexColor]] forState:state];
}

- (void)dealloc {
    [_addEventButton release];
    [_noEventLabel release];
    [_eventShowTable release];
    [super dealloc];
}

- (void)visibleTable {
    if (self.dataSource && self.dataSource.count) {
        self.eventShowTable.hidden = NO;
        self.noEventLabel.hidden = YES;
    }
    else {
        self.eventShowTable.hidden = YES;
        self.noEventLabel.hidden = NO;
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addEvent"]) {
        [(MHEventEditViewController *)segue.destinationViewController setIsCreateFlag:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MHEventShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventShowCell"];
    MHEvent *event = self.dataSource[indexPath.row];
    [cell equipCell:event];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MHEventEditViewController *vc = [[UIStoryboard storyboardWithName:@"EventStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MHEventEditViewController"];
    vc.eventInfo = self.dataSource[indexPath.row];
    vc.isCreateFlag = NO;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MHEvent *eventInfo = self.dataSource[indexPath.row];
        NSArray *notys = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *noty in notys) {
            if ([noty.userInfo[@"key"] isEqualToString:[NSString stringWithFormat:@"%d",eventInfo.eventID]]) {
                [[UIApplication sharedApplication] cancelLocalNotification:noty];
                break;
            }
        }
        [ApplicationDelegate deleteEvent:eventInfo];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.eventShowTable reloadData];
    }
}

@end
