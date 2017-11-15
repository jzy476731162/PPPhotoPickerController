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
    });
    return _instance;
}

@end
