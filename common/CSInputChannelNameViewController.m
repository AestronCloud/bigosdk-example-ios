//
//  CSInputChannelNameViewController.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/27.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSInputChannelNameViewController.h"
#import "CSDataStore.h"
#import "CSUtils.h"
#import "CSInfoAlert.h"
#import "CSBaseLiveViewController.h"

static NSString * const kPkBtnTitle = @"PK";
@interface CSInputChannelNameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLB;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLB;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet CSButton *action1Btn;
@property (weak, nonatomic) IBOutlet CSButton *action2Btn;
@property (weak, nonatomic) IBOutlet UILabel *powerByLB;


@end

@implementation CSInputChannelNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameLB.text = [NSString stringWithFormat:@"用户:%@", [CSDataStore sharedInstance].lastUserName];
    self.welcomeLB.text = [[CSDataStore sharedInstance] welcomeText];
    self.textField.text = [CSDataStore sharedInstance].lastChannelName;
    self.powerByLB.text = [[CSDataStore sharedInstance] powerByText];
    
    switch ([CSDataStore sharedInstance].app) {
        case CSAppVideoLive: {
            self.textField.placeholder = @"请输入频道名称";
            [self.action1Btn setTitle:@"进入直播" forState:UIControlStateNormal];
            self.action2Btn.hidden = NO;
            [self.action2Btn setTitle:kPkBtnTitle forState:UIControlStateNormal];
            break;
        }
        case CSAppAudioLive: {
            self.textField.placeholder = @"请输入频道名称";
            [self.action1Btn setTitle:@"进入多人语音" forState:UIControlStateNormal];
            break;
        }
        case CSAppVideoCall1V1: {
            self.textField.placeholder = @"请输入通话id";
            [self.action1Btn setTitle:@"进入1v1视频" forState:UIControlStateNormal];
            break;
        }
        case CSAppAudioCall1V1: {
            self.textField.placeholder = @"请输入通话id";
            [self.action1Btn setTitle:@"进入1v1音频" forState:UIControlStateNormal];
            break;
        }
        case CSAppVideoLiveBasicBeauty: {
            self.textField.placeholder = @"请输入频道名称";
            [self.action1Btn setTitle:@"进入基础美颜直播" forState:UIControlStateNormal];
            self.action2Btn.hidden = NO;
            [self.action2Btn setTitle:kPkBtnTitle forState:UIControlStateNormal];
            break;
        }
        case CSAppVideoCall1V1BasicBeauty: {
            self.textField.placeholder = @"请输入通话id";
            [self.action1Btn setTitle:@"进入1v1基础美颜" forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - Action
- (IBAction)actionDidTapBg:(id)sender {
    [self.textField resignFirstResponder];
}

- (IBAction)actionDidTapButton1:(UIButton *)sender {
    [self.textField resignFirstResponder];
    NSString *channelName = self.textField.text;
    if (channelName.length == 0) {
        switch ([CSDataStore sharedInstance].app) {
            case CSAppVideoLiveBasicBeauty:
            case CSAppVideoLive:
            case CSAppAudioLive: {
                [CSInfoAlert showInfo:@"频道名称不能为空"];
                break;
            }
            case CSAppVideoCall1V1BasicBeauty:
            case CSAppVideoCall1V1:
            case CSAppAudioCall1V1: {
                [CSInfoAlert showInfo:@"通话ID不能为空"];
                break;
            }
            default: {
                break;
            }
        }
        
        return;
    }
    [CSDataStore sharedInstance].lastChannelName = channelName;
    switch ([CSDataStore sharedInstance].app) {
        case CSAppVideoLiveBasicBeauty:
        case CSAppVideoLive:
        case CSAppAudioLive: {
            if ([sender.titleLabel.text isEqualToString:kPkBtnTitle]) {
                [self cs_doJumpToLiveVCWithChannelName:channelName role:CSMClientRoleBroadcaster vcName:@"CSPkLiveViewController"];
            } else {
                [self cs_goVideoLiveWithChannelName:channelName vcName:nil];
            }
            break;
        }
        case CSAppVideoCall1V1BasicBeauty:
        case CSAppVideoCall1V1:
        case CSAppAudioCall1V1: {
            [self cs_doJumpToLiveVCWithChannelName:channelName role:CSMClientRoleBroadcaster vcName:nil];
            break;
        }
        default:
            break;
    }
}

- (IBAction)actionDidTapButton2:(id)sender {
    
}

#pragma mark - Action Of Button 1
- (void)cs_goVideoLiveWithChannelName:(NSString *)channelName vcName:(NSString *)vcName {
    void(^goLive)(CSMClientRole) =^(CSMClientRole role){
        [self cs_doJumpToLiveVCWithChannelName:channelName role:role vcName:vcName];
    };
    
    NSString *model= [[UIDevice currentDevice] model];
    BOOL isIPad = ([model rangeOfString:@"iPad"].location != NSNotFound);

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:isIPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"开播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        goLive(CSMClientRoleBroadcaster);
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"观看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        goLive(CSMClientRoleAudience);
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)cs_doJumpToLiveVCWithChannelName:(NSString *)channelName role:(CSMClientRole)role vcName:(NSString *)vcName {
    CSBaseLiveViewController *controller;
    if (vcName) {
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:vcName];
    } else {
        controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    }
    if ([controller isKindOfClass:[CSBaseLiveViewController class]]) {
        [controller setClientRole:role];
        controller.username = [CSDataStore sharedInstance].lastUserName;
        controller.channelName = channelName;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

@end
