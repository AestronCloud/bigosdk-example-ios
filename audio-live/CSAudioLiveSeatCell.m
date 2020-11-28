//
//  CSAudioLiveSeatCell.m
//  audio-live
//
//  Created by 林小程 on 2020/7/23.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSAudioLiveSeatCell.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>

@interface CSAudioLiveSeatCell ()

@property (weak, nonatomic) IBOutlet UILabel *uidLabel;
@property (weak, nonatomic) IBOutlet UIButton *forbiddenMicBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakingBtn;

@property (nonatomic, assign) uint64_t myUid;

@end

@implementation CSAudioLiveSeatCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.forbiddenMicBtn.hidden = YES;
    }
    return self;
}

- (void)setOnMicUid:(uint64_t)onMicUid myUid:(uint64_t)myUid speaking:(BOOL)speaking mute:(BOOL)mute {
    _onMicUid = onMicUid;
    self.myUid = myUid;
    
    if (onMicUid > 0) {
        self.uidLabel.text = [NSString stringWithFormat:@"%@%@", myUid == onMicUid ? @"我 " : @"", @(onMicUid).stringValue];
        self.forbiddenMicBtn.hidden = NO;
        self.forbiddenMicBtn.selected = mute;
        self.speakingBtn.hidden = !speaking;
    } else {
        self.uidLabel.text = @"";
        self.forbiddenMicBtn.hidden = YES;
        self.speakingBtn.hidden = YES;
    }
}

#pragma mark - Action
- (IBAction)actionDidTapForbiddenMic:(id)sender {
    if ([self.delegate respondsToSelector:@selector(actionDidTapMuteOfAudioLiveSeatCell:)]) {
        [self.delegate actionDidTapMuteOfAudioLiveSeatCell:self];
    }
}

@end
