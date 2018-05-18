//
//  PhotoPickerConfig.h
//  PhotoPickerDemo
//
//  Created by Carl Ji on 2017/11/14.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PhotoPickerHeader.h"
#import <Photos/Photos.h>

@interface PhotoPickerConfig: NSObject

+ (instancetype)defaultConfig;


@property (nonatomic, strong) UIColor *textTintColor;
@property (nonatomic, strong) UIColor *disableTextTintColor;

@property (nonatomic, strong) UIColor *backgroundTintColor;
@property (nonatomic, strong) UIColor *disableBackgroundColor;

@property (nonatomic, strong) UIColor *albumPopViewBackgroundColor;

@property (nonatomic, assign) CGFloat albumPopViewWidth;
@property (nonatomic, assign) CGFloat albumPopViewHeight;
@property (nonatomic, assign) NSInteger albumPopViewMaxShowCount;

@property (nonatomic, strong) NSString *albumNextStepButtonName;


@property (nonatomic, copy) messageBlock messageBlock;
@property (nonatomic, copy) albumFilter albumFilter;

@property (nonatomic, copy) NSString *albumAuthTextNotDetermind;
@property (nonatomic, copy) NSString *albumAuthTextDenied;
@property (nonatomic, copy) NSString *albumAuthTextRestrict;
@property (nonatomic, copy) NSString *albumAuthTextEmpty;
@property (nonatomic, copy) NSString *cameraAuthTextRestrict;
@property (nonatomic, copy) NSString *cameraAuthTextDenied;

@property (nonatomic, strong) PHFetchOptions *fetchOptions;



@end
