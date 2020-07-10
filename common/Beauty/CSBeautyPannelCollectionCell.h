//
//  CSBeautyPannelCollectionCell.h
//  video-live
//
//  Created by 林小程 on 2020/8/7.
//  Copyright © 2020 bigo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CSBeautyPannelCollectionCellSelectedStyle) {
    CSBeautyPannelCollectionCellSelectedStyleAlphaMask, //半透明遮罩
    CSBeautyPannelCollectionCellSelectedStyleBlueRoundMask, //蓝色圆形遮罩
};

@interface CSBeautyPannelCollectionCell : UICollectionViewCell

- (void)reloadWithIcon:(UIImage *)icon title:(NSString *)title selectedStyle:(CSBeautyPannelCollectionCellSelectedStyle)selectedStyle;

@end

NS_ASSUME_NONNULL_END
