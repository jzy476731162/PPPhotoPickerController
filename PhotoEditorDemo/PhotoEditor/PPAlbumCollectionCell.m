//
//  AlbumCell.m
//  photoAndCameraTest
//
//  Created by Carl Ji on 16/12/18.
//  Copyright © 2016年 Carl Ji. All rights reserved.
//

#import "PPAlbumCollectionCell.h"
#import "PPAlbumEntity.h"

#import "PhotoPickerConfig.h"


@interface PPAlbumCollectionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *checkmarkView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;


@property (nonatomic, strong) PHImageRequestOptions *options;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;


@end

@implementation PPAlbumCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.checkmarkView.layer.masksToBounds = YES;
    self.checkmarkView.layer.cornerRadius = 9;
    self.checkmarkView.backgroundColor = [PhotoPickerConfig defaultConfig].backgroundTintColor;
    
    self.indexLabel.textColor = [PhotoPickerConfig defaultConfig].textTintColor;
}

- (void)setBadgeIndex:(NSNumber *)index {
    self.indexLabel.text = [NSString stringWithFormat:@"%ld",(long) index.integerValue];
}

- (void)configWithPHAsset:(PHAsset *)asset {
    if (!self.options) {
        self.options = [[PHImageRequestOptions alloc]init];
        
        self.options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        self.options.synchronous = NO;
        self.options.networkAccessAllowed = YES;

    }
    

    self.imageView.image = nil;

    
    [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:CGSizeMake(self.imageView.bounds.size.width  * 2, self.imageView.bounds.size.height * 2) contentMode:PHImageContentModeAspectFit options:self.options resultHandler:^(UIImage*result,NSDictionary*info) {
            [self.imageView setImage:result];
        
    }];
}

- (void)selectCell:(BOOL)selected showLoading:(BOOL)show Index:(NSNumber *)index {
    [self selectCell:selected showLoading:show];
    [self setBadgeIndex:index];
}

- (void)selectCell:(BOOL)selected showLoading:(BOOL)show {
    [self selectCell:selected];
    if (show) {
        [self.indicator setHidden:!show];
        [self.indicator startAnimating];
    }else {
        [self.indicator stopAnimating];
    }
}

- (void)selectCell:(BOOL)selected {
    [self setSelected:selected];
    self.checkmarkView.hidden = !selected;
    self.maskView.hidden = !selected;
    [self.indicator setHidden:!selected];
}

- (void)stopAnimating {
    [self.indicator stopAnimating];
}

- (void)setFetchingCellState:(NSNumber *)index {
    if (index) {
        [self selectCell:YES showLoading:YES Index:index];
    }else {
        [self selectCell:YES showLoading:YES];
    }
    
}

- (void)setFetchedSelectedCellState:(NSNumber *)index {
    if (index) {
        [self selectCell:YES showLoading:NO Index:index];
    }else {
        [self selectCell:YES showLoading:NO];
    }
}

- (void)setUnselectedCellState {
    [self selectCell:NO showLoading:NO];
}



@end
