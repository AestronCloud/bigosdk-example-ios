//
//  CSVoiceChangerViewController.m
//  cstore-example-ios
//
//  Created by 周好冲 on 2020/12/2.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSVoiceChangerViewController.h"
#import "DropdownList/CSDropdownListView.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>

@interface CSVoiceChangerViewController ()
@property (weak, nonatomic) IBOutlet CSDropdownListView *voiceChangerListView;
@property (weak, nonatomic) IBOutlet CSDropdownListView *voiceReverbPresetListView;
@property (weak, nonatomic) IBOutlet CSDropdownListView *voiceEqualizerPresetListView;

@end

@implementation CSVoiceChangerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initListViewData];
}

- (IBAction)actionDidTapBg:(UIControl *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapBgOfVoiceChangerViewController:)]) {
        [self.delegate didTapBgOfVoiceChangerViewController:self];
    }
}

static inline CSDropdownListItem* ListItem(NSString *ItemId, NSString *ItemName) {
    if (ItemName.length > 0) {
        return [[CSDropdownListItem alloc] initWithItem:ItemId itemName:ItemName];
    }
    return nil;
}

-(void)initListViewData {
    
    NSArray<CSDropdownListItem *> *changer = @[
        ListItem(@"1", @"原效果"),
        ListItem(@"2", @"老男孩"),
        ListItem(@"3", @"小男孩"),
        ListItem(@"4", @"小女孩"),
        ListItem(@"5", @"猪八戒"),
        ListItem(@"6", @"空灵"),
        ListItem(@"7", @"绿巨人"),
        ListItem(@"8", @"怪兽"),
        ListItem(@"9", @"机器人"),
        ListItem(@"10", @"外星人")
    ];

    if (self.voiceChangerListView) {
        [self.voiceChangerListView initWithDataSource:changer];
        self.voiceChangerListView.selectedIndex = 0;
        [self.voiceChangerListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
        [self.voiceChangerListView setDropdownListViewSelectedBlock:^(CSDropdownListView *dropdownListView) {
            [[CStoreMediaEngineCore sharedSingleton] setLocalVoiceChanger:(AestronAudioVoiceChanger)dropdownListView.selectedIndex];
        }];
    }
    
    NSArray<CSDropdownListItem *> *reverb = @[
        ListItem(@"1", @"原效果"),
        ListItem(@"2", @"音乐会"),
        ListItem(@"3", @"录音棚"),
        ListItem(@"4", @"KTV"),
        ListItem(@"5", @"教堂"),
        ListItem(@"6", @"酒吧"),
        ListItem(@"7", @"浴室")
    ];
    
    
    if (self.voiceReverbPresetListView) {
        [self.voiceReverbPresetListView initWithDataSource:reverb];
        self.voiceReverbPresetListView.selectedIndex = 0;
        [self.voiceReverbPresetListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
        [self.voiceReverbPresetListView setDropdownListViewSelectedBlock:^(CSDropdownListView *dropdownListView) {
            [[CStoreMediaEngineCore sharedSingleton] setLocalVoiceReverbPreset:(AestronAudioReverbPreset)dropdownListView.selectedIndex];
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
