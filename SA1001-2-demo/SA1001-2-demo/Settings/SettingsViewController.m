//
//  SettingsViewController.m
//  SA1001-2-demo
//
//  Created by jie yang on 2018/11/13.
//  Copyright © 2018年 jie yang. All rights reserved.
//

#import "SettingsViewController.h"
#import "AlarmListViewController.h"
#import "AromaTimeListViewController.h"
#import "CenterSettingViewController.h"
#import "TitleSubTitleArrowCell.h"
#import <SA1001_2/SA1001_2.h>
#import "ResetCell.h"

enum {
    Row_Alarm = 0,
    Row_AromaTime,
    Row_CenterSetting,
    Row_ResetDevice,
    Row_Bottom,
};

@interface SettingsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    
    [self addNotificationObservre];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showConnected:SharedDataManager.connected];
}

- (void)addNotificationObservre {
    NSNotificationCenter *notificationCeter = [NSNotificationCenter defaultCenter];
    [notificationCeter addObserver:self selector:@selector(deviceConnected:) name:kNotificationNameBLEDeviceConnected object:nil];
    [notificationCeter addObserver:self selector:@selector(deviceDisconnected:) name:kNotificationNameBLEDeviceDisconnect object:nil];
}

- (void)deviceConnected:(NSNotification *)notification {
    SharedDataManager.connected = YES;
    [self showConnected:YES];
}

- (void)deviceDisconnected:(NSNotification *)notfication {
    SharedDataManager.connected = NO;
    [self showConnected:NO];
}

- (void)showConnected:(BOOL)connected {
    CGFloat alpha = connected ? 1.0 : 0.3;
    [self.view setAlpha:alpha];
    
    [self.view setUserInteractionEnabled:connected];
}

- (void)setUI
{
    self.titleLabel.text = LocalizedString(@"setting");
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

#pragma mark UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return Row_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 60;
    if (indexPath.row == Row_ResetDevice) {
        height = 130;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleSubTitleArrowCell *cell = (TitleSubTitleArrowCell *)[SLPUtils tableView:tableView cellNibName:@"TitleSubTitleArrowCell"];
    NSString *title = LocalizedString(@"alarm");
    if (indexPath.row == Row_AromaTime) {
        title = LocalizedString(@"sa_timer_on");
    }else if (indexPath.row == Row_CenterSetting) {
        title = LocalizedString(@"sa_center_set");
    }else if (indexPath.row == Row_ResetDevice){
        ResetCell *resetCell = (ResetCell *)[SLPUtils tableView:tableView cellNibName:@"ResetCell"];
        __weak typeof(self) weakSelf = self;
        resetCell.resetBlock = ^{
            [weakSelf resetDevice];
        };
        return resetCell;
    }
    [Utils configCellTitleLabel:cell.textLabel];
    [cell.textLabel setText:title];
    return cell;
}

- (void)resetDevice
{
    if (![SLPBLESharedManager blueToothIsOpen]) {
        [Utils showMessage:LocalizedString(@"phone_bluetooth_not_open") controller:self];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [SLPBLESharedManager SAB:SharedDataManager.peripheral deviceInitTimeout:0 callback:^(SLPDataTransferStatus status, id data) {
        if (status != SLPDataTransferStatus_Succeed) {
            [Utils showDeviceOperationFailed:status atViewController:weakSelf];
        }else{
            [SharedDataManager reset];
//            [Utils showAlertTitle:@"" message:LocalizedString(@"factory_reset_send") confirmTitle:LocalizedString(@"confirm") atViewController:weakSelf];
            
            [Utils showMessage:LocalizedString(@"factory_reset_send") controller:weakSelf];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == Row_Alarm) {
        [self goAlarmPage];
    }else if (indexPath.row == Row_AromaTime){
        [self goAromaTimePage];
    }else if (indexPath.row == Row_CenterSetting){
        [self goCenterSettingPage];
    }
}

- (void)goAlarmPage
{
    AlarmListViewController *vc = [AlarmListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goAromaTimePage
{
    AromaTimeListViewController *vc = [AromaTimeListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goCenterSettingPage
{
    CenterSettingViewController *vc = [CenterSettingViewController new];
    vc.selectItemsNum = SharedDataManager.selectItemsNum;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
