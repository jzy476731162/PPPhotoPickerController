//
//  PhotoPickerHeader.h
//  Wooforbes
//
//  Created by Carl Ji on 2017/11/13.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#ifndef PhotoPickerHeader_h
#define PhotoPickerHeader_h


/**
 return the album you want to show, see PPAlbumEntity line:61s

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

@protocol AlbumEntityDelegate <NSObject>

- (void)albumLoadImagesComplete:(NSString *)albumTitle;
- (void)fetchImageComplete:(BOOL)success Index:(NSIndexPath *)index isUserInterrupt:(BOOL)isUserInterrupted;
- (void)startFetchImage:(NSIndexPath *)indexPath;
- (void)cancelFetchImage:(NSIndexPath *)indexPath;
- (void)selectImageComplete;

- (void)reloadNumberCount:(NSIndexPath *)indexPath;
- (void)reloadAll;


@end

typedef NS_ENUM(NSUInteger, PhotoSource) {
    PhotoSourceCamera = 1,
    PhotoSourceAlbum,
};

typedef NS_ENUM(NSUInteger, PhotoDestination) {
    PhotoDestinationNoDestination = 0,
    PhotoDestinationPostFeed,
    PhotoDestinationAvatar,
};

static NSString const *kAlbumAuthNotDetermindText = @"快开启照片权限吧~";
static NSString const *kAlbumAuthDeniedText = @"您禁止了\"XX\"使用相册\n请前往系统设置->汪布斯->允许\"XX\"访问照片开启";
static NSString const *kAlbumAuthRestrictText = @"您禁用了访问相册\n请前往系统设置->XX->允许\"XX\"访问照片开启";
static NSString const *kAlbumAuthEmptyText = @"这个相册没有皂片哦~";

static NSString const *kCameraAuthRestrictText = @"您的相机无法使用,暂不能使用拍照上传功能";
static NSString const *kCameraAuthDeniedText = @"您关闭了相机使用权限,如需使用请前往设置->XX->相机打开相机权限";


#endif /* PhotoPickerHeader_h */
