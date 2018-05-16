//
//  AlbumCell.h
//  photoAndCameraTest
//
//  Created by Carl Ji on 16/12/18.
//  Copyright © 2016年 Carl Ji. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>
@class PPPhotoEntity;


@interface PPAlbumCollectionCell : UICollectionViewCell

- (void)configWithPHAsset:(PHAsset *)asset;


/// @param selected : 选中cell.带遮罩带选中标识
/// @param loading  : 显示加载框.只在选中状态下显示
//- (void)selectCell:(BOOL)selected showLoading:(BOOL)loading;
- (void)selectCell:(BOOL)selected showLoading:(BOOL)show Index:(NSNumber *)index;


- (void)setFetchingCellState:(NSNumber *)index;
- (void)setFetchedSelectedCellState:(NSNumber *)index;
- (void)setUnselectedCellState;


@end
