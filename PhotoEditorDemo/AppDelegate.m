//
//  AppDelegate.m
//  PhotoPickerDemo
//
//  Created by Carl Ji on 2017/11/13.
//  Copyright © 2017年 Carl Ji. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoPickerConfig.h"

#import <Photos/Photos.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[PhotoPickerConfig defaultConfig] setBackgroundTintColor:[UIColor blueColor]];
    [[PhotoPickerConfig defaultConfig] setTextTintColor:[UIColor whiteColor]];
    
    [[PhotoPickerConfig defaultConfig] setAlbumFilter:^NSMutableArray *{
        return [NSMutableArray arrayWithArray:@[[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil]]];
    }];
    [[PhotoPickerConfig defaultConfig] setMessageBlock:^(NSString *info, UIViewController *showView, alertContinueBlock block) {
        if (block) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"test" message:info preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                block();
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [alert addAction:sure];
            
            [showView presentViewController:alert animated:YES completion:Nil];
            
        }else {
            //HUD
            NSLog(@"Info:%@", info);
        }
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
