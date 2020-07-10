//
//  CSBeautyPannelCollectionCell.m
//  video-live
//
//  Created by 林小程 on 2020/8/7.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyPannelCollectionCell.h"
#import "CSUtils.h"
@interface CSBeautyPannelCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *alphaMask;
@property (weak, nonatomic) IBOutlet UIImageView *blueRoundMask;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property(nonatomic, assign)CSBeautyPannelCollectionCellSelectedStyle selectedStyle;

@end

@implementation CSBeautyPannelCollectionCell

- (void)reloadWithIcon:(UIImage *)icon title:(NSString *)title selectedStyle:(CSBeautyPannelCollectionCellSelectedStyle)selectedStyle {
    self.imgView.image = icon;
    self.label.text = title;
    self.selectedStyle = selectedStyle;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    switch (self.selectedStyle) {
        case CSBeautyPannelCollectionCellSelectedStyleAlphaMask: {
            self.alphaMask.hidden = !selected;
            self.blueRoundMask.hidden = YES;
            break;
        }
        case CSBeautyPannelCollectionCellSelectedStyleBlueRoundMask: {
            self.alphaMask.hidden = YES;
            self.blueRoundMask.hidden = !selected;
            break;
        }
    }

    self.label.textColor = selected ? Color(51, 153, 255) : [UIColor whiteColor];
}

@end
