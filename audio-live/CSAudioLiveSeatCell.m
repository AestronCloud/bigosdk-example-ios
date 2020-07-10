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

@property (nonatomic, assign) BOOL isForbiddedAudio;

@end

@implementation CSAudioLiveSeatCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self cs_loadFromNib];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self cs_loadFromNib];
    }
    return self;
}

- (void)cs_loadFromNib {
    UIView *v = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:self options:nil].firstObject;
    if (v) {
        [self addSubview:v];
        v.frame = self.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.forbiddenMicBtn.hidden = YES;
}

- (void)setOnMicUid:(uint64_t)onMicUid myUid:(uint64_t)myUid {
    _onMicUid = onMicUid;
    self.myUid = myUid;
    
    if (onMicUid > 0) {
        self.uidLabel.text = [NSString stringWithFormat:@"%@%@", myUid == onMicUid ? @"我 " : @"", @(onMicUid).stringValue];
        self.forbiddenMicBtn.hidden = NO;
        self.forbiddenMicBtn.selected = NO;
    } else {
        self.uidLabel.text = @"";
        self.forbiddenMicBtn.hidden = YES;
    }
}

- (void)setUid:(uint64_t)uid speaking:(BOOL)speaking {
    if (uid != self.onMicUid) {
        return;
    }
    
    self.speakingBtn.hidden = !speaking;
}

#pragma mark - Action
- (IBAction)actionDidTapForbiddenMic:(id)sender {
    if (self.onMicUid) {
        self.isForbiddedAudio = !self.isForbiddedAudio;
        if (self.myUid == self.onMicUid) {
            [[CStoreMediaEngineCore sharedSingleton] muteLocalAudioStream:self.isForbiddedAudio];
        }
        [[CStoreMediaEngineCore sharedSingleton] muteRemoteAudioStream:self.onMicUid mute:self.isForbiddedAudio];
    }
}

#pragma mark - Getter
- (void)setIsForbiddedAudio:(BOOL)isForbiddedAudio {
    _isForbiddedAudio = isForbiddedAudio;
    self.forbiddenMicBtn.selected = _isForbiddedAudio;
}

@end
