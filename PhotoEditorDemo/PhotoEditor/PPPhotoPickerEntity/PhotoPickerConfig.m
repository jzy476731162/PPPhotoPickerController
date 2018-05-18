//
//  PhotoPickerConfig.m
//  PhotoPickerDemo
//
//  Created by Carl Ji on 2017/11/14.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#import "PhotoPickerConfig.h"



@implementation PhotoPickerConfig
static PhotoPickerConfig * _instance = nil;

+ (instancetype)defaultConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.textTintColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _instance.disableTextTintColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        
        _instance.backgroundTintColor = [UIColor colorWithRed:1 green:229/255.0 blue:0 alpha:1];
        _instance.disableBackgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        
        _instance.albumPopViewBackgroundColor = [UIColor colorWithRed:171/255.0 green:171/255.0 blue:171/255.0 alpha:1];
        
        _instance.albumPopViewWidth = 100;
        _instance.albumPopViewHeight = 35;
        _instance.albumPopViewMaxShowCount = 10;
        
        _instance.albumNextStepButtonName = @"下一步";
        
        _instance.albumAuthTextNotDetermind = @"快开启照片权限吧~";
        _instance.albumAuthTextDenied = @"您禁止了\"XX\"使用相册\n请前往系统设置->AppName->允许\"XX\"访问照片开启";
        _instance.albumAuthTextRestrict = @"您禁用了访问相册\n请前往系统设置->XX->允许\"XX\"访问照片开启";
        _instance.albumAuthTextEmpty = @"这个相册没有皂片哦~";
        
        _instance.cameraAuthTextRestrict = @"您的相机无法使用,暂不能使用拍照上传功能";
        _instance.cameraAuthTextDenied = @"您关闭了相机使用权限,如需使用请前往设置->XX->相机打开相机权限";
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        _instance.fetchOptions = options;
    });
    return _instance;
}

@end
