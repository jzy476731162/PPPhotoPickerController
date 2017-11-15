//
//  Album.m
//  photoAndCameraTest
//
//  Created by Carl Ji on 16/12/18.
//  Copyright © 2016年 Carl Ji. All rights reserved.
//

#import "PPAlbum.h"

#import <Photos/Photos.h>

#import "PPAlbumCollectionCell.h"

#import "CustomPopOverView.h"

#import "UIImage+Extension.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#import "PPAlbumEntity.h"

#import "PhotoPickerConfig.h"




#define kDefaultImageSizeWidth ((([UIScreen mainScreen].bounds.size.width - 2 - 1)/3) - 2)
@interface Album () <UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, CustomPopOverViewDelegate, AlbumEntityDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) PPAlbumEntity *albumEntity;

@property (nonatomic, weak)IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation Album
#pragma mark - LoadImageDelegate
- (void)albumLoadImagesComplete:(NSString *)albumTitle {
    [self.menuButton setTitle:albumTitle forState:UIControlStateNormal];
//    [self.collectionView reloadData];
}

- (void)fetchImageComplete:(BOOL)success Index:(NSIndexPath *)index isUserInterrupt:(BOOL)isUserInterrupted{
    PPAlbumCollectionCell * currentCell = (PPAlbumCollectionCell *)[self.collectionView cellForItemAtIndexPath:index];
    if (success) {
        [currentCell setFetchedSelectedCellState:nil];
    }else {
        [currentCell setUnselectedCellState];
    }
    
    if (!success && isUserInterrupted) {
        if ([PhotoPickerConfig defaultConfig].messageBlock) {
            [PhotoPickerConfig defaultConfig].messageBlock(@"iCloud同步失败,请检查您的网络", self, nil);
        }
    }
    
    if (!success) {
        [self.albumEntity destructPhotoEntityWithIndexPath:index];
    }
}

- (void)startFetchImage:(NSIndexPath *)indexPath {
    PPAlbumCollectionCell * currentCell = (PPAlbumCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [currentCell setFetchingCellState:[self.albumEntity getEntityIndex:indexPath]];
}

- (void)cancelFetchImage:(NSIndexPath *)indexPath {
    PPAlbumCollectionCell * currentCell = (PPAlbumCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [currentCell setUnselectedCellState];
}

- (void)selectImageComplete {
    [self.nextButton setEnabled:self.albumEntity.photos.count];
}

- (void)reloadNumberCount:(NSIndexPath *)indexPath {
    NSMutableArray *indexs = indexPath?[NSMutableArray arrayWithArray:@[indexPath]]:[NSMutableArray new];
    for (NSNumber *index in self.albumEntity.numberHash.allKeys) {
        [indexs addObject:[NSIndexPath indexPathForRow:[index integerValue] inSection:0]];
    }
    
    [self.collectionView reloadItemsAtIndexPaths:indexs];
}

- (void)reloadAll {
    [self.collectionView reloadData];
}

#pragma mark - Other
- (void)appBecomeActive {
    if (!self.albumEntity) {
        [self setupEntity];
    }
}

#pragma mark - UIKit
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButton];
    
    [self setupEntity];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setupEntity {
    self.albumEntity = [PPAlbumEntity initializeWithDelegate:self StartIndex:self.startIndex];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PHPhotoLibrary authorizationStatus]!=PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self setupEntity];
            }
        }];
    }
}


#pragma mark - Setup

- (void)setupButton {
    self.nextButton.layer.masksToBounds = true;
    self.nextButton.layer.cornerRadius = 5;
    
    [self.nextButton setTitle:[PhotoPickerConfig defaultConfig].albumNextStepButtonName forState:UIControlStateNormal];
    [self.nextButton setTitle:[PhotoPickerConfig defaultConfig].albumNextStepButtonName forState:UIControlStateDisabled];
    
    [self.nextButton setBackgroundImage:[UIImage imageWithColor:[PhotoPickerConfig defaultConfig].backgroundTintColor] forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIImage imageWithColor:[PhotoPickerConfig defaultConfig].disableBackgroundColor] forState:UIControlStateDisabled];
    [self.nextButton setTitleColor:[PhotoPickerConfig defaultConfig].textTintColor forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[PhotoPickerConfig defaultConfig].disableTextTintColor forState:UIControlStateDisabled];
    
    [self.closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
}

#pragma mark - Action

- (IBAction)closeAction:(UIButton *)sender {
    [self.parentViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleMenu:(UIButton *)sender{
    
    if (self.albumEntity.albumsResult.count > 0) {
        CGFloat height;
        if (self.albumEntity.albumsList.count > [PhotoPickerConfig defaultConfig].albumPopViewMaxShowCount) {
            height = [PhotoPickerConfig defaultConfig].albumPopViewMaxShowCount * [PhotoPickerConfig defaultConfig].albumPopViewHeight;
        }else {
            height = self.albumEntity.albumsList.count * [PhotoPickerConfig defaultConfig].albumPopViewHeight;
        }
        
        CustomPopOverView *pView = [[CustomPopOverView alloc]initWithBounds:CGRectMake(0, 0, [PhotoPickerConfig defaultConfig].albumPopViewWidth, height) titleMenus:self.albumEntity.albumsList];
        [pView setTableViewScrollEnable:YES];
        pView.delegate = self;
        pView.containerBackgroudColor = [PhotoPickerConfig defaultConfig].albumPopViewBackgroundColor;
        [pView showFrom:sender alignStyle:CPAlignStyleCenter];
    }
}

- (IBAction)nextStep:(UIButton *)sender {
    NSArray *uncompletedImages = [self.albumEntity checkFetchUncompletedImage];
    if (uncompletedImages) {
        NSMutableString *str = [NSMutableString stringWithFormat:@"您选择的图"];
        for (NSNumber *index in uncompletedImages) {
            [str appendString:[NSString stringWithFormat:@"%ld\,", (long)([index integerValue])]];
        }
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
        [str appendString:@"还没有缓存完毕,如果继续提交这些图将不会选中,是否继续?"];
        
        if ([PhotoPickerConfig defaultConfig].messageBlock) {
            __weak typeof(self)weakSelf = self;
            alertContinueBlock alertBlock = ^{
                [weakSelf submitPhotos];
            };
            [PhotoPickerConfig defaultConfig].messageBlock(str, self, alertBlock);
        }
        
    }else {
        [self submitPhotos];
    }
    
    
    
}

- (void)submitPhotos {
    if (self.albumEntity.photos.count > 1) {
        NSMutableArray *array = [NSMutableArray new];
        for (PhotoEntity *photo in self.albumEntity.photos) {
            if ([photo validImage]) {
                [array addObject:photo.selectedImage];
            }
        }
        if ([self.delegate respondsToSelector:@selector(userPickedPhotos:)]) {
            [self.delegate userPickedPhotos:array];
        }
    }else if (self.albumEntity.photos.count == 1) {
        if ([self.delegate respondsToSelector:@selector(userPickedPhoto:)]) {
            [self.delegate userPickedPhoto:[self.albumEntity.photos[0] selectedImage]];
        }
    }else {
        return;
    }
}

- (void)popOverView:(CustomPopOverView *)pView didClickMenuIndex:(NSInteger)index {
    self.albumEntity.currentAlbumIndex = index;

    [self.albumEntity reloadAlbum:index];

    [pView dismiss];
    
}


#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumEntity.result.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PPAlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PPAlbumCollectionCell" forIndexPath:indexPath];
    [cell configWithPHAsset:self.albumEntity.result[[indexPath row]]];
    
    if (self.albumEntity.numberHash[@(indexPath.row)]) {
        for (PhotoEntity * entity in self.albumEntity.photos) {
            if (entity.currentSelectedIndexpath.row == indexPath.row & entity.currentSelectedIndexpath.section == indexPath.section) {
                BOOL selected = false;
                if (entity.selectedImage) {
                    selected = true;
                }else {
                    if (entity.isLoading) {
                        selected = true;
                    }
                }
                [cell selectCell:selected showLoading:entity.isLoading Index:self.albumEntity.numberHash[@(indexPath.row)] ];
                break;
            }
        }
    }else {
        [cell setUnselectedCellState];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.maxSelectCount == 1) {
        if (self.albumEntity.photos.count == 1) {
            [self.albumEntity destructPhotoEntityWithIndexPath:[self.albumEntity.photos[0] currentSelectedIndexpath]];
        }
        
    }else if (![self.albumEntity checkExistEntity:indexPath] && self.albumEntity.photos.count >= self.maxSelectCount) {
        return;
    }
    
    [self.albumEntity userTapCell:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kDefaultImageSizeWidth, kDefaultImageSizeWidth);
}

#pragma mark - EmptyDataSet
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *title;
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusRestricted:
            title = [NSString stringWithFormat:@"%@", kAlbumAuthRestrictText];
            break;
            
        case PHAuthorizationStatusDenied:
            title = [NSString stringWithFormat:@"%@", kAlbumAuthDeniedText];
            break;
        case PHAuthorizationStatusNotDetermined:
            title = [NSString stringWithFormat:@"%@", kAlbumAuthNotDetermindText];
            break;
        default:
            title = [NSString stringWithFormat:@"%@", kAlbumAuthEmptyText];
            break;
    }
    NSString *text = title;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"shutter"];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized && [[self.collectionView.emptyDataSetSource titleForEmptyDataSet:scrollView].string isEqualToString:[NSString stringWithFormat:@"%@", kAlbumAuthNotDetermindText]]) {
        [self setupEntity];
    }
}

@end
