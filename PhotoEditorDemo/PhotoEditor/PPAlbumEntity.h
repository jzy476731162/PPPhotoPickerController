//
//  AlbumEntity.h
//  Wooforbes
//
//  Created by Carl Ji on 2017/9/6.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "PhotoPickerHeader.h"

@interface PhotoEntity : NSObject

@property (nonatomic, assign) PHImageRequestID currentRequestID;

@property (nonatomic, strong) NSIndexPath *currentSelectedIndexpath;            /**< 用户当前选中Index*/

@property (nonatomic, strong) UIImage *selectedImage;                           /**< 用户当前选中图片*/
@property (nonatomic, assign) BOOL isLoading;                                   /**< FetchImage From iCloud*/

- (void)fetchImage:(PHFetchResult *)albumResult;

@property (nonatomic, weak) id <AlbumEntityDelegate> delegate;

- (BOOL)validImage;
@end


@interface PPAlbumEntity : NSObject

@property (nonatomic, strong) NSMutableArray <PHFetchResult *>*albumsResult;                      /**< 存储所有Album的结果*/
@property (nonatomic, strong) PHFetchResult *result;                            /**< 存储Album内的所有图片结果*/

@property (nonatomic, strong) NSMutableArray *albumsList;                       /**< 存储Albums名称(展示用)*/

@property (nonatomic, strong) NSMutableArray <PhotoEntity*> *photos;

@property (nonatomic, assign) NSUInteger currentAlbumIndex;                     /**< 第几个专辑*/

@property (nonatomic, strong) NSMutableDictionary *numberHash;                  /**< 右上角图标*/

@property (nonatomic, assign) NSInteger startIndex;

+ (instancetype)initializeWithDelegate:(id <AlbumEntityDelegate>)delegate StartIndex:(NSInteger)startIndex;

- (void)reloadAlbums;
- (void)reloadAlbum:(NSInteger)index;

- (void)userTapCell:(NSIndexPath *)indexpath;

- (void)destructPhotoEntityWithIndexPath:(NSIndexPath *)indexPath;

- (PhotoEntity *)checkExistEntity:(NSIndexPath *)indexPath;
- (NSNumber *)getEntityIndex:(NSIndexPath *)indexPath;

- (NSArray *)checkFetchUncompletedImage;

@end

