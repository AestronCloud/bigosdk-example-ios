//
//  CSDebugViewController.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/9/28.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSDebugViewController.h"
#import "CSTranscodingInfoManager.h"
#import "CSTestArgSettingManager.h"
#import "CSInfoAlert.h"
#import "CSUtils.h"
#import "PAirSandbox.h"

@interface CSDebugViewController ()

@end

@implementation CSDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[CSModiTranscodingFormController formControllerWithPkOrMic:NO] animated:YES];
        } else if (indexPath.row == 1) {
            [self.navigationController pushViewController:[CSModiTranscodingFormController formControllerWithPkOrMic:YES] animated:YES];
        } else if (indexPath.row == 2) {
            [CSUtils showAlertWithTitle:@"重置上麦场景参数" msg:@"确认重置后将恢复到默认参数" fromController:self sureAction:^{
                [[CSTranscodingInfoManager sharedInstance] restoreDefaultTranscodingInPk:NO];
                [CSInfoAlert showInfo:@"已重置上麦场景参数"];
            }];
        } else if (indexPath.row == 3) {
            [CSUtils showAlertWithTitle:@"重置PK场景参数" msg:@"确认重置后将恢复到默认参数" fromController:self sureAction:^{
                [[CSTranscodingInfoManager sharedInstance] restoreDefaultTranscodingInPk:YES];
                [CSInfoAlert showInfo:@"已重置PK场景参数"];
            }];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[CSTestArgSettingViewController controller] animated:YES];
        } else if (indexPath.row == 1) {
            [[PAirSandbox sharedInstance] presentSanboxInVC:self];
        }
    }
}

@end
