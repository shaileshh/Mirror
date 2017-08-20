//
//  ViewController.h
//  Mirror
//
//  Created by Shailesh on 17/04/17.
//  Copyright © 2017 Shailesh. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>


@interface ViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic, retain) AVCaptureVideoDataOutput *videoOutput;
@property (strong, nonatomic) IBOutlet UIView *vImagePreview;
@property (strong, nonatomic) IBOutlet UIImageView *vImage;
@property (strong, nonatomic) IBOutlet UIButton *captureButton;
- (IBAction)captureNow:(id)sender;

@end

