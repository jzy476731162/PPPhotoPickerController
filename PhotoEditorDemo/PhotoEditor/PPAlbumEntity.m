//
//  AlbumEntity.m
//  Wooforbes
//
//  Created by Carl Ji on 2017/9/6.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#import "PPAlbumEntity.h"
#import "PhotoPickerConfig.h"

@interface PPAlbumEntity()

@property (nonatomic, weak) id <AlbumEntityDelegate> delegate;

@end

@implementation PPAlbumEntity

+ (instancetype)initializeWithDelegate:(id <AlbumEntityDelegate>)delegate StartIndex:(NSInteger)startIndex{
    PPAlbumEntity *entity = [[PPAlbumEntity alloc] init];
    [entity reloadAlbums];
    
    entity.startIndex = startIndex;
    entity.delegate = delegate;
    entity.photos = [NSMutableArray new];
    entity.numberHash = [NSMutableDictionary new];
    [entity addObserver:entity forKeyPath:@"photos" options:NSKeyValueObservingOptionNew context:nil];
    return entity;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"photos"]) {
        if ([self.delegate respondsToSelector:@selector(selectImageComplete)]) {
            [self.delegate selectImageComplete];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"photos"];
}


- (void)reloadAlbums {
    [self fetchAlbums];
    if (self.albumsResult.count > 0) {
        [self fetchDataWithAlbums:(PHAssetCollection *)self.albumsResult[0]];
    }
}

- (void)fetchAlbums {
    PHFetchOptions *albumsOption = [PHFetchOptions new];
    albumsOption.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    NSArray *list;
    if ([PhotoPickerConfig defaultConfig].albumFilter) {
        list = [PhotoPickerConfig defaultConfig].albumFilter();
    }

    if (!list) {
        PHFetchResult *album0 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        PHFetchResult *album1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
        PHFetchResult *album2 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumGeneric options:nil];
        PHFetchResult *album3 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil];
        PHFetchResult *album4 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
        PHFetchResult *album5 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        list = @[album0, album1, album2, album3, album4, album5];
    }
    
    
    self.albumsResult = [NSMutableArray new];
    for (PHFetchResult *album in list) {
        for ( int i = 0; i < album.count; i++) {
            [self.albumsResult addObject:album[i]];
        }
    }
    
    self.albumsList = [self getShownNameOfAlbumName];
}

- (void)fetchDataWithAlbums:(PHAssetCollection *)album {
    PHFetchOptions *optionss = [[PHFetchOptions alloc] init];
    optionss.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    optionss.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:album options:optionss];
    
    self.result = result;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(albumLoadImagesComplete:)]) {
            [self.delegate albumLoadImagesComplete:self.albumsList[_currentAlbumIndex]];
        }
    });
}

- (NSMutableArray *)getShownNameOfAlbumName {
    NSMutableArray *ItemList = [NSMutableArray new];

    for (int i = 0; i < self.albumsResult.count; i++) {
        PHAssetCollection *asset = (PHAssetCollection *)self.albumsResult[i];
        NSString *title = [NSString stringWithFormat:@"%@",asset.localizedTitle]; //,(unsigned long)asset.estimatedAssetCount
        [ItemList addObject:title];
    }
    
    return ItemList;
}

- (void)reloadAlbum:(NSInteger)index {
    [self fetchDataWithAlbums:(PHAssetCollection *)self.albumsResult[index]];

    [self resetSelectState];
}

- (void)resetSelectState {
//    self.photos = [NSMutableArray new];
    for (PhotoEntity *photo in self.photos) {
        if (photo.isLoading && photo.currentRequestID > -1) {
            [[PHAssetResourceManager defaultManager] cancelDataRequest:photo.currentRequestID];
        }
    }
    [self.numberHash removeAllObjects];
    
    [self.photos removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(reloadAll)]) {
        [self.delegate reloadAll];
    }
}

- (void)userTapCell:(NSIndexPath *)indexpath {
    PhotoEntity *existPhoto;
    for (PhotoEntity *photo in self.photos) {
        if (photo.currentSelectedIndexpath.section == indexpath.section & photo.currentSelectedIndexpath.row == indexpath.row) {
            existPhoto = photo;
            break;
        }
    }
    if (existPhoto) {
        [self destructPhotoEntity:existPhoto];
    }else {
        [self initializePhotoEntityWithIndexPath:indexpath];
    }
}

- (void)initializePhotoEntityWithIndexPath:(NSIndexPath *)indexpath {
    PhotoEntity *photo = [PhotoEntity new];
    photo.currentSelectedIndexpath = indexpath;
    photo.delegate = self.delegate;
    [photo fetchImage:self.result];
    
    [[self mutableArrayValueForKey:@"photos"] addObject:photo];
    [self.numberHash setObject:@(self.startIndex + self.photos.count) forKey:@(indexpath.row)];
    
    if ([self.delegate respondsToSelector:@selector(startFetchImage:)]) {
        [self.delegate startFetchImage:indexpath];
    }
}

- (void)destructPhotoEntity:(PhotoEntity *)entity {
    NSIndexPath *path = entity.currentSelectedIndexpath;
    [[self mutableArrayValueForKey:@"photos"] removeObject:entity];
    if ([self.delegate respondsToSelector:@selector(cancelFetchImage:)]) {
        [self.delegate cancelFetchImage:path];
    }
    
    NSUInteger index = [[self.numberHash objectForKey:@(entity.currentSelectedIndexpath.row)] unsignedIntegerValue];
    for (NSNumber *key in self.numberHash.allKeys) {
        if ([self.numberHash[key] integerValue] > index) {
            self.numberHash[key] = @([self.numberHash[key] integerValue] - 1);
        }
    }
    
    [self.numberHash removeObjectForKey:@(entity.currentSelectedIndexpath.row)];
    
    if ([self.delegate respondsToSelector:@selector(reloadNumberCount:)]) {
        [self.delegate reloadNumberCount:nil];
    }
}

- (void)destructPhotoEntityWithIndexPath:(NSIndexPath *)indexPath {
    PhotoEntity *entity = [self checkExistEntity:indexPath];
    if (entity) {
        [self destructPhotoEntity:entity];
    }
}

- (PhotoEntity *)checkExistEntity:(NSIndexPath *)indexPath {
    for (PhotoEntity *photo in self.photos) {
        if (photo.currentSelectedIndexpath.row == indexPath.row && photo.currentSelectedIndexpath.section == indexPath.section) {
            return photo;
            break;
        }
    }
    return nil;
}

- (NSNumber *)getEntityIndex:(NSIndexPath *)indexPath {
    if (self.numberHash[@(indexPath.row)]) {
        return self.numberHash[@(indexPath.row)];
    }
    return nil;
}

- (NSArray *)checkFetchUncompletedImage {
    NSMutableArray *uncompletedImages = [NSMutableArray new];
    for (PhotoEntity *photo in self.photos) {
        if ([photo validImage]) {
            continue;
        }else {
            [uncompletedImages addObject:[self getEntityIndex:photo.currentSelectedIndexpath]];
        }
    }
    if (uncompletedImages.count) {
        return uncompletedImages;
    }else {
        return nil;
    }
}



@end

@implementation PhotoEntity

- (BOOL)validImage {
    if (self.isLoading == false && self.selectedImage) {
        return true;
    }
    return false;
}

- (void)fetchImage:(PHFetchResult *)albumResult {
    if (self.currentRequestID > -1) {
        [[PHImageManager defaultManager] cancelImageRequest:self.currentRequestID];
        self.currentRequestID = -1;
    }
    self.selectedImage = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    
    PHAsset *asset = [albumResult objectAtIndex:self.currentSelectedIndexpath.row];
    
    CGFloat borderLength = MIN(asset.pixelWidth, asset.pixelWidth);
    CGFloat ratio = 1;
    if (borderLength > [UIScreen mainScreen].bounds.size.width * 2) {
        ratio = borderLength/2/[UIScreen mainScreen].bounds.size.width;
    }
    
    self.isLoading = true;
    self.currentRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth/ratio , asset.pixelHeight/ratio) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage*result,NSDictionary*info) {
        self.isLoading = false;
        
        if (result) {
            
            self.currentRequestID = -1;
            self.selectedImage = result;
            
            if (self.currentSelectedIndexpath && [self.delegate respondsToSelector:@selector(fetchImageComplete:Index:isUserInterrupt:)]) {
                [self.delegate fetchImageComplete:true Index:self.currentSelectedIndexpath isUserInterrupt:NO];
            }
        }else {
            //非用户取消,并且下载失败
            if (!info[PHImageCancelledKey]) {
                if (self.currentSelectedIndexpath && [self.delegate respondsToSelector:@selector(fetchImageComplete:Index:isUserInterrupt:)]) {
                    [self.delegate fetchImageComplete:false Index:self.currentSelectedIndexpath isUserInterrupt:YES];
                }
            }
        }
        
    }];
}



@end
