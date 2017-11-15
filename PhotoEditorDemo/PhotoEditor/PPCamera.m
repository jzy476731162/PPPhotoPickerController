//
//  Camera.m
//  photoAndCameraTest
//
//  Created by Carl Ji on 16/12/18.
//  Copyright © 2016年 Carl Ji. All rights reserved.
//

#import "PPCamera.h"

#import <AVFoundation/AVFoundation.h>

#import "PhotoPickerConfig.h"


#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface Camera () <AVCapturePhotoCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *outputView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *swapButton;

@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureOutput *output;

@property (nonatomic, strong) UIImageView *focusView;

@property (weak, nonatomic) IBOutlet UIView *animationMaskView0;
@property (weak, nonatomic) IBOutlet UIView *animationMaskView1;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskHeightConstraint;

@end

@implementation Camera
#pragma mark - Getter
- (UIImageView *)focusView {
    if (!_focusView) {
        
        _focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focusCamera"]];
        [_focusView setFrame:CGRectMake(0, 0, 70, 70)];
        [self.outputView addSubview:_focusView];
        _focusView.hidden = YES;
    }
    return _focusView;
}

#pragma mark - UIKit
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animationMaskView0.backgroundColor = [PhotoPickerConfig defaultConfig].backgroundTintColor;
    self.animationMaskView1.backgroundColor = [PhotoPickerConfig defaultConfig].backgroundTintColor;
    
    self.maskHeightConstraint.constant = self.outputView.frame.size.height / 2;
    [self.view layoutIfNeeded];
    
    self.title = @"拍照";
   
    [self setupCaptureSession];
    [self setupOutputLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIntoBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)appBecomeActive {
    [self checkCameraIsUse];
}

- (void)appIntoBackground {
    if (self.session && [self.session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkCameraIsUse];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.session && [self.session isRunning]) {
        [self.session stopRunning];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Action
- (IBAction)closeAction:(UIButton *)sender {
    [self hideLayerWithCompletion:^{
        [self.parentViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)swapCamera:(UIButton *)sender {
    if (self.session.inputs.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotate.duration = 0.5;
            rotate.repeatCount = 1;
            rotate.fromValue = [NSNumber numberWithFloat:M_PI];
            rotate.toValue = [NSNumber numberWithFloat:0];
            
            [sender.layer addAnimation:rotate forKey:@"swapAnimation"];
        });
        [self swapFrontAndBackCameras];

    }
    
}

- (void)focusAction:(UIGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.outputView];
    [self focusAtPoint:point];
}

#pragma mark - Capture Photo
- (IBAction)cameraAction:(UIButton *)sender {

    if ([self.session isRunning] && [sender isEnabled] == YES && self.session.inputs.count > 0) {
        
        [sender setEnabled:NO];
        
        if (SYSTEM_VERSION_LESS_THAN(@"10")) {
            [self capturePhotoLoweriOSTen];
        }else {
            [(AVCapturePhotoOutput *)self.output capturePhotoWithSettings:[AVCapturePhotoSettings photoSettings] delegate:self];
        }
    }
}

- (void)capturePhotoLoweriOSTen {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.output.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    __weak typeof(self) weakSelf = self;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    [(AVCaptureStillImageOutput *)self.output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
    
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    
    [weakSelf getImageSuccess:image];
    }];
#pragma clang diagnostic pop

}

- (void)getImageSuccess:(UIImage *)image{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userPickedPhoto:)]) {
        [self.delegate userPickedPhoto:image];
    }
}

#pragma mark - Camera Settings

#pragma mark === Mask Layer Animation ===
- (void)showLayer {
    self.maskHeightConstraint.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)hideLayerWithCompletion:(void(^)(void))completion {
    self.maskHeightConstraint.constant = self.outputView.frame.size.height/2;
    [self.view setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}


#pragma mark === Setup ===
- (void)setupCameraSettings {
    if (self.session && self.session.inputs.count) {
        if (![self.session isRunning]) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                [self.session startRunning];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showLayer];
                });
            });
            
            
        }
    }else {
        for (CALayer *layer in self.outputView.subviews) {
            if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
        [self setupCaptureSession];
        [self setupOutputLayer];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            [self.session startRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLayer];
            });
        });
    }
    
}

- (void)setupOutputLayer {
    AVCaptureSession *captureSession = self.session;
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    UIView *aView = self.outputView;
    //This Line has a bug: In system lower than iOS10,the layer will offset
    //    previewLayer.frame = aView.bounds; // Assume you want the preview layer to fill
    // use behind instead
    CGRect bounds= aView.layer.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.bounds=bounds;
    previewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [aView.layer addSublayer:previewLayer];
    
    if (self.session.inputs.count) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAction:)];
        [self.outputView addGestureRecognizer:tap];
        
    }
}

- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.device = device;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input && !error) {
        // Handling the error appropriately.
        [session addInput:input];
        
    }
    
    self.session = session;
    
    
    if (SYSTEM_VERSION_LESS_THAN(@"10")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
        AVCaptureStillImageOutput *output7 = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [output7 setOutputSettings:outputSettings];
        self.output = output7;
        
        [session addOutput:self.output];
#pragma clang diagnostic pop
        
    }else {
        AVCapturePhotoOutput *output = [[AVCapturePhotoOutput alloc] init];
        //    output.
        self.output = output;
        [session addOutput:output];
        
    }
}

//iOS10
-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
    if (photoSampleBuffer) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
#pragma clang diagnostic pop
        
        
        [self getImageSuccess:image];
    }
}

#pragma mark === Focus ===
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.outputView.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光模式和曝光点
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        //设置对焦动画
        self.focusView.center = point;
        self.focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
    
}

#pragma mark === Swap Camera ===
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
    
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)swapFrontAndBackCameras {
    // Assume the session is already running
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *inputs = self.session.inputs;
        for ( AVCaptureDeviceInput *input in inputs ) {
            AVCaptureDevice *device = input.device;
            if ( [device hasMediaType:AVMediaTypeVideo] ) {
                AVCaptureDevicePosition position = device.position;
                AVCaptureDevice *newCamera = nil;
                AVCaptureDeviceInput *newInput = nil;
                
                if (position == AVCaptureDevicePositionFront)
                    newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                else
                    newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
                newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
                self.device = newCamera;
                
                // beginConfiguration ensures that pending changes are not applied immediately
                [self.session beginConfiguration];
                
                [self.session removeInput:input];
                [self.session addInput:newInput];
                
                // Changes take effect once the outermost commitConfiguration is invoked.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.session commitConfiguration];
                });
                break;
            }
        }
    });
    
    
}

#pragma mark === Camera Auth ===
- (void)listenAppAwake {
    [self checkCameraIsUse];
}

- (void)checkCameraIsUse{
    
    NSString *type = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:type];
    if (authStatus != AVAuthorizationStatusAuthorized) {
        [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.cameraButton setEnabled:YES];
            
                });
                
                [self setupCameraSettings];
            }
        }];
    }
    
    
    NSString *errorInfo;
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
            errorInfo = [NSString stringWithFormat:@"%@", kCameraAuthRestrictText];
            [self.cameraButton setEnabled:NO];
            break;
        case AVAuthorizationStatusDenied:
            errorInfo = [NSString stringWithFormat:@"%@", kCameraAuthDeniedText];
            [self.cameraButton setEnabled:NO];
            break;
        case AVAuthorizationStatusAuthorized: {
            
            [self.cameraButton setEnabled:YES];
            
            [self setupCameraSettings];
        }
            return;
            break;
        default:
            [self.cameraButton setEnabled:NO];
            break;
    }
    
    if (errorInfo.length) {
        NSLog(@"%@", errorInfo);
    }
}


@end
