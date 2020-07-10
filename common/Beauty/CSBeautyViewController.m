//
//  CSBeautyViewController.m
//  video-live
//
//  Created by 林小程 on 2020/8/7.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSBeautyViewController.h"
#import "CSBeautyPannelCollectionCell.h"
#import "CSUtils.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import "CSBeautyBaseDataSource.h"
#import "CSBeautySkinDataSource.h"
#import "CSBeautyManager.h"

#define kContainerTopSafeEreaBottomSpace 220

typedef NS_ENUM(NSUInteger, CSBeautyViewControllerTab) {
    CSBeautyViewControllerTabFilter = 1,
    CSBeautyViewControllerTabSkin = 2,
    CSBeautyViewControllerTabBody = 3,
};

@interface CSBeautyViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopSafeEreaBottomConst;

@property (weak, nonatomic) IBOutlet UIView *containerBg;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIView *sliderDefaultValueIndicator;
@property (weak, nonatomic) IBOutlet UILabel *sliderValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *previewOriginBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderLabelCenterX2SilderLeadingSpaceConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *silderDefaultValueIndicatorCenterX2SliderLeadingSpaceConstr;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabs;

@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, strong)NSMutableDictionary<NSNumber *, CSBeautyBaseDataSource *> *dataSourceDic;
@property(nonatomic, strong)CSBeautyBaseDataSource *currentDatasource;

@property(nonatomic, strong)CSBeautyViewControllerDismissBlock dismissBlock;

@property(nonatomic, assign)CSBeautyViewControllerTab curTab;

@property(nonatomic, assign)BOOL isPreviewingOrigin;

@property (weak, nonatomic) IBOutlet UIButton *bodyBeautyBtn;

@end

@implementation CSBeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if AdvancedBeauty
    self.bodyBeautyBtn.hidden = NO;
#else
    self.bodyBeautyBtn.hidden = YES;
#endif
    
    
    [self.slider setThumbImage:[UIImage imageNamed:@"img_beauty_header_slider_indicator"] forState:UIControlStateNormal];
    
    self.collection.allowsSelection = YES;
    
    self.dataSourceDic = [NSMutableDictionary dictionary];
    [self loadDataAtTab:1];    
}

+ (void)showInVC:(UIViewController *)vc dismissBlock:(nonnull CSBeautyViewControllerDismissBlock)dismissBlock {
    CSBeautyViewController *pannelVC = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    pannelVC.dismissBlock = dismissBlock;
    if ([pannelVC isKindOfClass:[CSBeautyViewController class]]) {
        [vc addChildViewController:pannelVC];
        [vc.view addSubview:pannelVC.view];
        pannelVC.view.frame = vc.view.bounds;
        pannelVC.containerTopSafeEreaBottomConst.constant = 0;
        [pannelVC.view setNeedsLayout];
        [pannelVC.view layoutIfNeeded];
        
        pannelVC.containerTopSafeEreaBottomConst.constant = -kContainerTopSafeEreaBottomSpace;
        [UIView animateWithDuration:0.3 animations:^{
            [pannelVC.view setNeedsLayout];
            [pannelVC.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [pannelVC didMoveToParentViewController:vc];
        }];
    }
}

- (void)loadDataAtTab:(NSUInteger)tab {
    if (self.curTab == tab) {
        return;
    }
    
    //刷新tab的UI
    for (UIButton *btn in self.tabs) {
        btn.selected = btn.tag == tab;
    }
    
    //创建DataSource
    if (!self.dataSourceDic[@(tab)]) {
        if (tab == CSBeautyViewControllerTabFilter) {
            self.dataSourceDic[@(tab)] = [CSBeautyManager sharedInstance].filterDS;
        } else if (tab == CSBeautyViewControllerTabSkin) {
            self.dataSourceDic[@(tab)] = [CSBeautyManager sharedInstance].skinDS;
        } else if (tab == CSBeautyViewControllerTabBody) {
            self.dataSourceDic[@(tab)] = [CSBeautyManager sharedInstance].bodyDS;
        }
        
        self.currentDatasource = self.dataSourceDic[@(tab)];
        [self.collection reloadData]; //清除上个datasource的数据
        [self.loadingIndicator startAnimating];
        __weak typeof(self) weakSelf = self;
        [self.currentDatasource prepareDataWithCompletion:^{
            MainThreadBegin
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            
            [strongSelf.loadingIndicator stopAnimating];
            [strongSelf.collection reloadData];
            //选中默认值时刷新一下slider相关控件UI
            [strongSelf cs_updateSliderUIIgnoreSliderValue:NO];
            MainThreadCommit
        }];
    } else {
        self.currentDatasource = self.dataSourceDic[@(tab)];
        [self.collection reloadData];
    }
}

#pragma mark - Action
- (IBAction)actionDidTapClose:(UIButton *)sender {
    [self cs_dismissSelf];
}

- (IBAction)actionDidTapHeaderTab:(UIButton *)sender {
    [self loadDataAtTab:sender.tag];
}

- (IBAction)actionDidTapBg:(id)sender {
    [self cs_dismissSelf];
}

- (IBAction)actionDidSliderValueChange:(UISlider *)sender {
    [self.currentDatasource changeSelectedItemLevelTo:sender.value];

    [self cs_updateSliderUIIgnoreSliderValue:YES];
}

- (IBAction)actionDidTouchDownPreviewOriginBtn:(id)sender {
    self.isPreviewingOrigin = YES;
    [[CSBeautyManager sharedInstance] pauseOrResumeAllBeauty:YES];
    [self cs_updateSliderUIIgnoreSliderValue:YES];
}

- (IBAction)actionDidTouchUpOutsideOriginSwitchBtn:(id)sender {
    [self cs_actionDidTouchUpOriginSwitchBtn];
}

- (IBAction)actionDidTouchUpInsideOriginSwitchBtn:(UIButton *)sender {
    [self cs_actionDidTouchUpOriginSwitchBtn];
}

- (void)cs_actionDidTouchUpOriginSwitchBtn {
    self.isPreviewingOrigin = NO;
    [[CSBeautyManager sharedInstance] pauseOrResumeAllBeauty:NO];
    [self cs_updateSliderUIIgnoreSliderValue:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.currentDatasource count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSBeautyPannelCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CSBeautyPannelCollectionCell class]) forIndexPath:indexPath];
    if ([cell isKindOfClass:[CSBeautyPannelCollectionCell class]]) {
        CSBeautyDataSourceItem *item = [self.currentDatasource itemAtIndex:indexPath.row];
        CSBeautyPannelCollectionCellSelectedStyle selectedType = [self.currentDatasource isKindOfClass:[CSBeautySkinDataSource class]] ? CSBeautyPannelCollectionCellSelectedStyleBlueRoundMask : CSBeautyPannelCollectionCellSelectedStyleAlphaMask;
        [cell reloadWithIcon:item.icon title:item.name selectedStyle:selectedType];
        cell.selected = (self.currentDatasource.selectedItem == item);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.currentDatasource selectItemAtIndex:indexPath.row];
    
    //修复选中，退房再重新进入时，出现两个选中的cell
    for (UICollectionViewCell *visibleCell in collectionView.visibleCells) {
        if ([collectionView indexPathForCell:visibleCell].item != indexPath.item) {
            visibleCell.selected = NO;
        }
    }
    
    [self cs_updateSliderUIIgnoreSliderValue:NO];
}

#pragma mark - Private
- (void)cs_updateSliderUIIgnoreSliderValue:(BOOL)ignoreSliderValue {
    CSBeautyDataSourceItem *selectedItem = [self.currentDatasource selectedItem];
    CSBeautyDataSourceItem *disableItem = [self.currentDatasource disabelItem];
    BOOL noSelectedItem = (selectedItem == nil);
    BOOL selectedDisabelItem = (selectedItem && disableItem && selectedItem == disableItem);
    
    self.slider.hidden = self.sliderDefaultValueIndicator.hidden = self.sliderValueLabel.hidden = (noSelectedItem || selectedDisabelItem || self.isPreviewingOrigin);
    
    if (!noSelectedItem && !selectedDisabelItem) { //选中了非Disable项，才需要更新slider
        if (!ignoreSliderValue) {
            self.slider.value = selectedItem.level;
        }
        self.sliderValueLabel.text = [NSString stringWithFormat:@"%d", selectedItem.level];
        if (CGRectGetWidth(self.slider.frame) == 0) {
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }
        CGFloat sliderW = CGRectGetWidth(self.slider.frame);
        self.sliderLabelCenterX2SilderLeadingSpaceConstr.constant = (sliderW - 20) * ((CGFloat)self.slider.value / self.slider.maximumValue) + 8;
        self.silderDefaultValueIndicatorCenterX2SliderLeadingSpaceConstr.constant = selectedItem.defaultLevel / 100.0 * sliderW;
    }
}

- (void)cs_dismissSelf {
    [self willMoveToParentViewController:nil];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    self.containerTopSafeEreaBottomConst.constant = 0;
    
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
