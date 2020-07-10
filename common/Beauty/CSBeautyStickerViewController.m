//
//  CSBeautyStickerViewController.m
//  video-live
//
//  Created by 林小程 on 2020/8/10.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyStickerViewController.h"
#import "CSUtils.h"
#import "CSBeautyStickerCell.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSBeautyBaseDataSource.h"
#import "CSBeautyManager.h"

#define kContainerTopSafeEreaBottomSpace 296

@interface CSBeautyStickerViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorWConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopToSuperviewBottomSpaceConst;

@property(nonatomic, strong)CSBeautyBaseDataSource *dataSource;

@property(nonatomic, strong)CSBeautyStickerViewControllerDismissBlock dismissBlock;

@end

@implementation CSBeautyStickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.seperatorWConst.constant = OnePixel;

    self.dataSource = [CSBeautyManager sharedInstance].stickerDS;
    __weak typeof(self) weakSelf = self;
    [self.loadingIndicator startAnimating];
    [self.dataSource prepareDataWithCompletion:^{
        MainThreadBegin
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf.loadingIndicator stopAnimating];
        [strongSelf.collection reloadData];
        MainThreadCommit
    }];
    [self.collection reloadData];
}

+ (void)showInVC:(UIViewController *)vc dismissBlock:(nonnull CSBeautyStickerViewControllerDismissBlock)dismissBlock {
    CSBeautyStickerViewController *pannelVC = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    pannelVC.dismissBlock = dismissBlock;
    if ([pannelVC isKindOfClass:[CSBeautyStickerViewController class]]) {
        [vc addChildViewController:pannelVC];
        [vc.view addSubview:pannelVC.view];
        pannelVC.view.frame = vc.view.bounds;
        pannelVC.containerTopToSuperviewBottomSpaceConst.constant = 0;
        [pannelVC.view setNeedsLayout];
        [pannelVC.view layoutIfNeeded];
        
        pannelVC.containerTopToSuperviewBottomSpaceConst.constant = -kContainerTopSafeEreaBottomSpace;
        [UIView animateWithDuration:0.3 animations:^{
            [pannelVC.view setNeedsLayout];
            [pannelVC.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [pannelVC didMoveToParentViewController:vc];
        }];
    }
}

#pragma mark - Action
- (IBAction)actionDidTapBg:(id)sender {
    [self cs_dismissSelf];
}

- (IBAction)actionDidTapDisableSticker:(id)sender {
}

#pragma mark - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSBeautyStickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CSBeautyStickerCell class]) forIndexPath:indexPath];
    if ([cell isKindOfClass:[CSBeautyStickerCell class]]) {
        CSBeautyDataSourceItem *item = [self.dataSource itemAtIndex:indexPath.item];
        if (item) {
            [cell reloadWithIcon:item.icon];
        }
        cell.selected = (self.dataSource.selectedItem == item);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.dataSource selectItemAtIndex:indexPath.item];
    
    //修复选中，退房再重新进入时，出现两个选中的cell
    for (UICollectionViewCell *visibleCell in collectionView.visibleCells) {
        if ([collectionView indexPathForCell:visibleCell].item != indexPath.item) {
            visibleCell.selected = NO;
        }
    }
}

#pragma mark - Private
- (void)cs_dismissSelf {
    [self willMoveToParentViewController:nil];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    self.containerTopToSuperviewBottomSpaceConst.constant = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

@end
