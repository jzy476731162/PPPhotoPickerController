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

@interface PPPhotoEntity : NSObject

@property (nonatomic, assign) PHImageRequestID currentRequestID;

@property (nonatomic, strong) NSIndexPath *currentSelectedIndexpath;            /**< 用户当前选中Index*/

@property (nonatomic, strong) UIImage *selectedImage;                           /**< 用户当前选中图片*/
@property (nonatomic, assign) BOOL isLoading;                                   /**< FetchImage From iCloud*/

@property (nonatomic, weak) id <PPAlbumFetchDelegate> delegate;

- (void)fetchImage:(PHFetchResult *)albumResult;
- (BOOL)validImage;
@end

@interface PPAlbumFetchEntity : NSObject
@property (nonatomic, strong) NSMutableArray <PPPhotoEntity*> *photos;
@property (nonatomic, strong) NSMutableDictionary *numberHash;                  /**< Badge Number*/
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, strong) PHFetchResult *result;                            /**< album photos*/

- (instancetype)initWithDelegate:(id<PPAlbumFetchDelegate>)delegate DataSource:(PHAssetCollection *)collection StartIndex:(NSInteger)startIndex;
- (void)destructPhotoEntityWithIndexPath:(NSIndexPath *)indexPath;

- (void)tapIndex:(NSIndexPath *)indexpath;
- (void)reloadWithDataSource:(PHAssetCollection *)collection;

- (PPPhotoEntity *)entityIsExisted:(NSIndexPath *)indexPath;
- (NSNumber *)getEntityIndex:(NSIndexPath *)indexPath;
- (NSArray *)checkFetchUncompletedImage;
@end

@interface PPAlbumEntity : NSObject

@property (nonatomic, strong) NSMutableArray <PHAssetCollection *>*albumsResult;                      /**< 存储所有Album的结果*/
@property (nonatomic, assign) NSInteger startIndex;

+ (instancetype)initializeWithStartIndex:(NSInteger)startIndex;
- (NSMutableArray *)albumsList;

@end

