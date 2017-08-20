//
//  ViewController.m
//  Mirror
//
//  Created by Shailesh on 17/04/17.
//  Copyright © 2017 Shailesh. All rights reserved.
//

#import "ViewController.h"
#import "DlibWrapper.h"

@interface ViewController (){
    CGFloat widthOfScreen;
    CGFloat heightOfScreen ;
    DlibWrapper *wrapper;
    dispatch_queue_t captureSessionQueue;
    dispatch_queue_t captureMetadataQueue;
    NSArray * currentMetadata;
    AVSampleBufferDisplayLayer *demoLayer;
    AVCaptureSession *session;
    CVImageBufferRef imageBufferFromDlibb;
}

@end

@implementation ViewController
@synthesize videoOutput, vImagePreview;

- (void)viewDidLoad {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    widthOfScreen  = screenSize.width;
    heightOfScreen = screenSize.height;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.captureButton.frame =CGRectMake(0, heightOfScreen - 50, widthOfScreen, 50);
    self.captureButton.backgroundColor = [ UIColor redColor];
    [self.captureButton setHidden:YES];
    self.vImage.frame = CGRectMake(0, 0, widthOfScreen, heightOfScreen -50);
    vImagePreview.frame = CGRectMake(0, 0, widthOfScreen, heightOfScreen -50);

    wrapper = [[DlibWrapper alloc]init];

}
-(void)createLayer{
    demoLayer = [[AVSampleBufferDisplayLayer alloc]init];
    demoLayer.frame = self.vImagePreview.bounds;
    demoLayer.backgroundColor = [[UIColor greenColor] CGColor];
    [self.vImagePreview.layer addSublayer:demoLayer];
    [self.view layoutIfNeeded];
}

-(void)viewDidAppear:(BOOL)animated{
   session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer *viewLayer = self.vImagePreview.layer;
    NSLog(@"viewLayer = %@", viewLayer);
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    captureVideoPreviewLayer.frame = self.vImagePreview.bounds;
     [self.vImagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [self frontCamera];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    // create the dispatch queue for handling capture session delegate method calls
    captureSessionQueue = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:captureSessionQueue];
    
    AVCaptureMetadataOutput* metaOutput = [[AVCaptureMetadataOutput alloc] init];
    // create the dispatch queue for handling capture session delegate method calls
    captureMetadataQueue = dispatch_queue_create("capture_metadata_session_queue", DISPATCH_QUEUE_SERIAL);
    [metaOutput setMetadataObjectsDelegate:self queue:captureMetadataQueue];

    [session beginConfiguration];
    
    [session addInput:input];
    
    [session addOutput:videoOutput];
    
    if ([session canAddOutput:metaOutput]) {
        [session addOutput:metaOutput];
    }
    
    [session commitConfiguration];
    
    // CoreImage wants BGRA pixel format
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    // create and configure video data output
    [videoOutput setVideoSettings:outputSettings];
    
    // NOW try adding metadata types
    metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    
    [wrapper prepare];
    
    [session startRunning];
    
    [self createLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)captureNow:(id)sender {
        [session stopRunning];

        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBufferFromDlibb];
        CIContext *temporaryContext = [CIContext contextWithOptions:nil];
        CGImageRef videoImage = [temporaryContext
                                 createCGImage:ciImage
                                 fromRect:CGRectMake(0, 0,
                                                     CVPixelBufferGetWidth(imageBufferFromDlibb),
                                                     CVPixelBufferGetHeight(imageBufferFromDlibb))];
        UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    
        self.vImage.image = image;
        NSLog(@"done clicking live pic.");
    
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    [[UIColor redColor] setFill];
    [[UIColor greenColor] setStroke];
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(path);
}
- (AVCaptureDevice *)frontCamera { //to select front camera
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

#pragma AVCaptureMetadataOutputObjectsDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)c
{
    NSLog(@"metadataObjects array %@",metadataObjects);
   
    currentMetadata = metadataObjects;
    
}


#pragma AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CGRect newFaceBounds;
    NSMutableArray *boundsArray = [[NSMutableArray alloc]init];
    if (currentMetadata.count >0) {
        for ( AVMetadataObject *object in currentMetadata ) {
            if ( [[object type] isEqual:AVMetadataObjectTypeFace] ) {
                AVMetadataFaceObject* face = (AVMetadataFaceObject*)object;
                AVMetadataObject *convertedObject = [captureOutput transformedMetadataObjectForMetadataObject:face connection:connection];
                NSLog(@"*********convertedObject******%@",convertedObject);
                newFaceBounds =convertedObject.bounds;
                [boundsArray addObject:[NSValue valueWithCGRect:newFaceBounds]];
                NSLog(@"**********boundsArray****** %@",boundsArray);
               
            }
        }
        [wrapper doWorkOnSampleBuffer:sampleBuffer inRects:boundsArray];

    }
    if ([demoLayer isReadyForMoreMediaData]) {
            [demoLayer enqueueSampleBuffer:sampleBuffer];
        
        }else{
            NSLog(@"enqueueSampleBuffer failed");
        }
    
     imageBufferFromDlibb = CMSampleBufferGetImageBuffer(sampleBuffer);

}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"DidDropSampleBuffer");
    
}
@end
