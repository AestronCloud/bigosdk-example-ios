//
//  CSBeautyStickerCell.m
//  video-live
//
//  Created by 林小程 on 2020/8/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyStickerCell.h"
#import "CSUtils.h"

@interface CSBeautyStickerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *alphaMask;

@end

@implementation CSBeautyStickerCell
    
- (void)awakeFromNib {
    [super awakeFromNib];
    self.alphaMask.layer.borderWidth = OnePixel;
    self.alphaMask.layer.borderColor = Color(72, 209, 204).CGColor;
}

- (void)reloadWithIcon:(UIImage *)icon {
    self.imgView.image = icon;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.alphaMask.hidden = !selected;
}

@end
