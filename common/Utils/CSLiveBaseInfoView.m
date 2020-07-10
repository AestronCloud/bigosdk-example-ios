//
//  CSLiveBaseInfoView.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/7/27.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSLiveBaseInfoView.h"

@interface CSLiveBaseInfoView ()

@property (strong, nonatomic) UILabel *textLabel;

@end

@implementation CSLiveBaseInfoView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.numberOfLines = 0;
        [self addSubview:self.textLabel];
        
        self.backgroundColor = [UIColor darkGrayColor];
        self.layer.cornerRadius = 20;
        self.layer.masksToBounds = YES;
        
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:16].active = YES;
        [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-16].active = YES;

        self.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40].active = YES;
    }
    return self;
}

- (void)setMyUid:(uint64_t)myUid channelName:(NSString *)channelName {
    self.textLabel.text = [NSString stringWithFormat:@"Livename=%@\nMyUid=%llu", channelName, myUid];
}

@end
