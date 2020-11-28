//
//  CSSettingsViewController.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/9/24.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSSettingsViewController.h"
#import "CSUtils.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSDataStore.h"

#define kInteritemSpacingForSection0_1 16
#define kLineSpacingForSection0_1 16
#define kResolutionItemWidth 100

#define kResolutionTitles @[ @"480x270", @"640x360", @"854x480", @"960x540", @"1280x720" ]
#define kResolutionTypes @[ @(CSMResolutionType480x270), @(CSMResolutionType640x360), @(CSMResolutionType854x480), @(CSMResolutionType960x540), @(CSMResolutionType1280x720) ]

#define kFrameRateTitles @[ @"1pfs", @"7fps", @"10fps", @"15fps", @"24fps", @"30fps" ]
#define kFrameRateTypes @[ @(CSMFrameRate1), @(CSMFrameRate7), @(CSMFrameRate10), @(CSMFrameRate15), @(CSMFrameRate24), @(CSMFrameRate30) ]

@interface CSSettingsSectionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CSSettingsSectionHeaderView

@end

@interface CSSettingsSectionFooterView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperateHeight;

@end

@implementation CSSettingsSectionFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.seperateHeight.constant = OnePixel;
}

@end

@interface CSSettingsResolutionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *labelContainer;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation CSSettingsResolutionCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.labelContainer.layer.cornerRadius = 24;
    self.labelContainer.layer.borderWidth = OnePixel;
    self.labelContainer.layer.masksToBounds = YES;
    
    [self refreshUIWithSelected:NO];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self refreshUIWithSelected:selected];
}

- (void)refreshUIWithSelected:(BOOL)selected {
    if (selected) {
        self.label.textColor = [UIColor whiteColor];
        self.labelContainer.backgroundColor = Color(0, 122, 255);
        self.labelContainer.layer.borderColor = Color(0, 122, 255).CGColor;
    } else {
        self.label.textColor = Color(152, 152, 152);
        self.labelContainer.backgroundColor = [UIColor clearColor];
        self.labelContainer.layer.borderColor = Color(222, 222, 222).CGColor;
    }
}

@end

@interface CSSettingsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CSSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        CSMResolutionType maxResolutionType = [CSDataStore sharedInstance].maxResolutionType;
        if (maxResolutionType > 0) {
            NSUInteger index = [kResolutionTypes indexOfObject:@(maxResolutionType)];
            if (index != NSNotFound && self.collectionView.numberOfSections >= 1 && [self.collectionView numberOfItemsInSection:0] >= kResolutionTypes.count) {
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
        CSMFrameRate maxFrameRate = [CSDataStore sharedInstance].maxFrameRate;
        if (maxFrameRate > 0) {
            NSUInteger index = [kFrameRateTypes indexOfObject:@(maxFrameRate)];
            if (index != NSNotFound && self.collectionView.numberOfSections >= 2 && [self.collectionView numberOfItemsInSection:1] >= kFrameRateTypes.count) {
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:1] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return kResolutionTitles.count;
    } else if (section == 1) {
        return kFrameRateTitles.count;
    } else {
        return 0;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CSSettingsSectionHeaderView *header = (CSSettingsSectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([CSSettingsSectionHeaderView class]) forIndexPath:indexPath];
        if (indexPath.section == 0) {
            header.titleLabel.text = @"分辨率";
        } else if (indexPath.section == 1) {
            header.titleLabel.text = @"帧率";
        }
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        CSSettingsSectionFooterView *footer = (CSSettingsSectionFooterView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([CSSettingsSectionFooterView class]) forIndexPath:indexPath];
        return footer;
    }
    return nil;;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(ScreenWidth, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(ScreenWidth, 20);
    } else {
        return CGSizeZero;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CSSettingsResolutionCell *cell = (CSSettingsResolutionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CSSettingsResolutionCell class]) forIndexPath:indexPath];
        if (indexPath.item < kResolutionTitles.count) {
            cell.label.text = kResolutionTitles[indexPath.item];
        }
        return cell;
    } else if (indexPath.section == 1) {
        CSSettingsResolutionCell *cell = (CSSettingsResolutionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CSSettingsResolutionCell class]) forIndexPath:indexPath];
        if (indexPath.item < kFrameRateTitles.count) {
            cell.label.text = kFrameRateTitles[indexPath.item];
        }
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.item < kResolutionTypes.count) {
            [CSDataStore sharedInstance].maxResolutionType = [kResolutionTypes[indexPath.item] integerValue];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.item < kFrameRateTypes.count) {
            [CSDataStore sharedInstance].maxFrameRate = [kFrameRateTypes[indexPath.item] integerValue];
        }
    }
    
    //每个section只能选中一个
    for (NSIndexPath *selectedIndexPath in collectionView.indexPathsForSelectedItems) {
        if (selectedIndexPath.section == indexPath.section && selectedIndexPath.item != indexPath.item) {
            [collectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        return CGSizeMake(kResolutionItemWidth , 48);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0 || section == 1) {
        return UIEdgeInsetsMake(0, 16, 0, 16);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0 || section == 1) {
        return kInteritemSpacingForSection0_1;
    } else {
        return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0 || section == 1) {
        return kLineSpacingForSection0_1;
    } else {
        return 0;
    }
}

@end
