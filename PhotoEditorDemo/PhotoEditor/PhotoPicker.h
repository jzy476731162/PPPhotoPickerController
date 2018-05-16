//
//  PhotoPicker.h
//  photoAndCameraTest
//
//  Created by Carl Ji on 16/12/18.
//  Copyright © 2016年 Carl Ji. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoPickerHeader.h"

typedef void(^pickMultiPhotoCompletion)(NSMutableArray<UIImage *> *items, UINavigationController *navigation);


@interface PhotoPicker : UIViewController

@property (nonatomic, assign) PPPickerSourceType sourceType;

@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) NSInteger maxSelectCount;

@property (nonatomic, copy) pickMultiPhotoCompletion multiCompletion;

+ (void)presentPickerFromViewController:(UIViewController *)vc PhotoSource:(PPPickerSourceType)sourceType StartIndex:(NSInteger)startIndex MaxCount:(NSInteger)maxCount Completion:(pickMultiPhotoCompletion)completion;

@end
