//
//  Camera.h
//  photoAndCameraTest
//
//  Created by Carl Ji on 16/12/18.
//  Copyright © 2016年 Carl Ji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerHeader.h"

@interface Camera : UIViewController

@property (nonatomic, weak) id <PhotoPickDelegate> delegate;

@end
