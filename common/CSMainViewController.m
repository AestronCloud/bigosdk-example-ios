//
//  CSMainViewController.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/27.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSMainViewController.h"
#import "CSDataStore.h"
#import "CSUtils.h"
#import "CSInfoAlert.h"
#import "CSTestArgSettingManager.h"

@interface CSMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *welcomeLB;
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UILabel *powerbyLB;


@end

@implementation CSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.welcomeLB.text = [[CSDataStore sharedInstance] welcomeText];
    self.powerbyLB.text = [[CSDataStore sharedInstance] powerByText];
    
    self.usernameTF.text = [CSDataStore sharedInstance].lastUserName;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"goInputChannelName"]) {
        if (self.usernameTF.text.length == 0) {
            [CSInfoAlert showInfo:@"用户名不能为空"];
            return NO;
        }
    }
    
    [CSDataStore sharedInstance].lastUserName = [CSUtils trimedString:self.usernameTF.text];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - Action
- (IBAction)actionDidTapBg:(id)sender {
    [self.usernameTF resignFirstResponder];
}

@end
