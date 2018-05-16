//
//  ViewController.m
//  PhotoPickerDemo
//
//  Created by Carl Ji on 2017/11/13.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#import "ViewController.h"
#import "PhotoPicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"click" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(100, 100, 100, 100)];
    [button addTarget:self action:@selector(presentPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)presentPicker {
    [PhotoPicker presentPickerFromViewController:self PhotoSource:PPPickerSourceTypeAlbum StartIndex:3 MaxCount:5 Completion:^(NSMutableArray<UIImage *> *items, UINavigationController *navigation) {
        
    }];
//    [PhotoPicker presentPickerFromViewController:self PhotoSource:PhotoSourceAlbum StartIndex:3 MaxCount:5 Completion:^(NSMutableArray<UIImage *> *items, UINavigationController *controller) {
////        if (controller) {
////            [controller dismissViewControllerAnimated:YES completion:nil];
////        }
//        UIViewController *test = [UIViewController new];
//        [test.view setBackgroundColor:[UIColor whiteColor]];
//        if (controller) {
//            [controller pushViewController:test animated:YES];
//        }
//    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
