//
//  PhotoPicker.m
//  photoAndCameraTest
//
//  Created by Carl Ji on 16/12/18.
//  Copyright © 2016年 Carl Ji. All rights reserved.
//

#import "PhotoPicker.h"

#import "PPCamera.h"
#import "PPAlbum.h"

#import <Photos/Photos.h>

#import "UIImage+Extension.h"

#import "PhotoPickerHeader.h"
#import "PhotoPickerConfig.h"



@interface PhotoPicker () <PhotoPickDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *segmentColorBar;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@property (nonatomic, strong) Camera *camera;
@property (nonatomic, strong) Album *album;

@property (nonatomic, strong) NSMutableArray<UIImage *> *pickedImages; //最终图片


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraint;

@end

@implementation PhotoPicker

#pragma mark - Public

+ (void)presentPickerFromViewController:(UIViewController *)vc PhotoSource:(PPPickerSourceType)sourceType StartIndex:(NSInteger)startIndex MaxCount:(NSInteger)maxCount Completion:(pickMultiPhotoCompletion)completion {
        UINavigationController *editorNavigation = [[UIStoryboard storyboardWithName:@"PhotoPicker" bundle:nil] instantiateInitialViewController];
        PhotoPicker *editor = (PhotoPicker *)[editorNavigation topViewController];
        editor.sourceType = sourceType;
        editor.multiCompletion = completion;
        editor.startIndex = startIndex;
        editor.maxSelectCount = maxCount;
        [editor.navigationController.navigationBar setHidden:YES];
    
        [vc presentViewController:editorNavigation animated:YES completion:nil];
}

#pragma mark - Lazy loading
- (Camera *)camera {
    if (!_camera) {
        _camera = [[UIStoryboard storyboardWithName:@"PhotoPicker" bundle:nil] instantiateViewControllerWithIdentifier:@"Camera"];
        _camera.delegate = self;
    }
    return _camera;
}

- (Album *)album {
    if (!_album) {
        _album = [[UIStoryboard storyboardWithName:@"PhotoPicker" bundle:nil] instantiateViewControllerWithIdentifier:@"Album"];
        if (self.multiCompletion) {
            _album.maxSelectCount = self.maxSelectCount;
            _album.startIndex = self.startIndex;
        }
        _album.delegate = self;
    }
    return _album;
}

#pragma mark - UIKit

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    for (UIViewController *vc in self.childViewControllers) {
        [vc removeFromParentViewController];
    }
    self.containerView = nil;
    self.camera = nil;
    self.album = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar setHidden:YES];
//    [self.nextButton setEnabled:NO];

    UIViewController *needDisplayController = self.sourceType == PPPickerSourceTypeCamera? self.camera: self.album;
    [self addChildViewController:needDisplayController];//self.containerView.frame
    needDisplayController.view.frame = self.containerView.frame;
    [self.containerView addSubview:needDisplayController.view];
    [needDisplayController didMoveToParentViewController:self];
    
    
    [self setupUI];
}

- (void)setupUI {
    [self.segmentColorBar setImage:[[UIImage imageNamed:@"segmentBar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.segmentColorBar.tintColor = [PhotoPickerConfig defaultConfig].backgroundTintColor;
    
    if (self.sourceType == PPPickerSourceTypeCamera) {
        [self.cameraButton setSelected:YES];
    }else if (self.sourceType == PPPickerSourceTypeAlbum) {
        [self.photoButton setSelected:YES];
    }
    
    self.bottomLineConstraint.constant = [UIScreen mainScreen].bounds.size.width/4 * (self.sourceType == PPPickerSourceTypeCamera? -1:1);
    [self.view layoutIfNeeded];
}

- (void)changePickerSourceType:(PPPickerSourceType)sourceType {
    self.sourceType = sourceType;
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    self.bottomLineConstraint.constant = [UIScreen mainScreen].bounds.size.width/4 * (sourceType == PPPickerSourceTypeCamera? -1:1);
    
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    
    
    UIViewController *needDisplayController = self.sourceType == PPPickerSourceTypeCamera? self.camera: self.album;
    
    if (![self.childViewControllers containsObject:needDisplayController]) {
        [self addChildViewController:needDisplayController];
    }
    
    needDisplayController.view.frame = self.containerView.frame;
    [self.containerView addSubview:needDisplayController.view];
    [needDisplayController didMoveToParentViewController:self];
}


#pragma mark - action

- (IBAction)photoButtonAction:(UIButton *)sender {
    if (sender.isSelected == NO) {
        [sender setSelected:YES];
        [self.cameraButton setSelected:NO];
        
        [self changePickerSourceType:PPPickerSourceTypeAlbum];
    }
}

- (IBAction)cameraButtonAction:(UIButton *)sender {
    if (sender.isSelected == NO) {
        [sender setSelected:YES];
        [self.photoButton setSelected:NO];
        
        [self changePickerSourceType:PPPickerSourceTypeCamera];
    }
}


#pragma mark - Delegate
- (void)userPickedPhotos:(NSArray<UIImage *> *)photos {
    self.pickedImages = [NSMutableArray arrayWithArray:photos];
    
    if (self.multiCompletion) {
        self.multiCompletion(self.pickedImages, self.navigationController);
    }
}

- (void)userPickedPhoto:(UIImage *)image {
    self.pickedImages = [NSMutableArray arrayWithObject:image];
    
    if (self.multiCompletion) {
        self.multiCompletion(self.pickedImages, self.navigationController);
    }
}

@end
