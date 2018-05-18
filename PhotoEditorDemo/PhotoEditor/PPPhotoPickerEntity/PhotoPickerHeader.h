//
//  PhotoPickerHeader.h
//  Wooforbes
//
//  Created by Carl Ji on 2017/11/13.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#ifndef PhotoPickerHeader_h
#define PhotoPickerHeader_h

@class PPAlbumFetchEntity;
@class PPPhotoEntity;
/**
 return the album you want to fetch, see PPAlbumEntity line:61s

 @return [PHFetchResult]
 */
typedef NSMutableArray *(^albumFilter)(void);

typedef void(^alertContinueBlock)(void);
/**
 Custom Message Show Type by your project
 
 @param info :Error Info
 @param showView :Show Message View
 @param block :notice that if block exists, it means PhotoPicker should continue after you invoke block(),it should shown as an alertView. Block == nil means that message should only show in hud
 */
typedef void(^messageBlock)(NSString *info, UIViewController *showView, alertContinueBlock block);




@protocol PhotoPickDelegate <NSObject>

/**
 Invoke by Camera, One Image
 Triggered automaticlly after pick Image
 */
- (void)userPickedPhoto:(UIImage *)image;

/**
 Invoke by Album, multi images
 Triggered manully by click next step
 */
- (void)userPickedPhotos:(NSMutableArray <UIImage *>*)photos;

@end

@protocol PPAlbumFetchDelegate <NSObject>

//Image Level
- (void)fetchImageComplete:(BOOL)success Index:(NSIndexPath *)index isUserInterrupt:(BOOL)isUserInterrupted;
- (void)startFetchImage:(NSIndexPath *)indexPath;
- (void)cancelFetchImage:(NSIndexPath *)indexPath;

//Album Level
- (void)refetchAlbum;
- (void)albumFetchEntity:(PPAlbumFetchEntity *)entity LoadingAlbumCompleted:(NSString *)albumTitle;
- (void)albumFetchEntity:(PPAlbumFetchEntity *)entity SelectedPhotosChanged:(NSIndexPath *)indexPath;
- (void)albumFetchEntity:(PPAlbumFetchEntity *)entity DeselectBadgeNumberChanged:(NSIndexPath *)indexPath;
@end


typedef NS_ENUM(NSUInteger, PPPickerSourceType) {
    PPPickerSourceTypeCamera = 1,
    PPPickerSourceTypeAlbum,
};

//typedef NS_ENUM(NSUInteger, PhotoDestination) {
//    PhotoDestinationNoDestination = 0,
//    PhotoDestinationPostFeed,
//    PhotoDestinationAvatar,
//};




#endif /* PhotoPickerHeader_h */
