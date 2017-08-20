//
//  DlibWrapper.m
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import "DlibWrapper.h"
#import <UIKit/UIKit.h>

#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include <dlib/data_io.h>

@interface DlibWrapper ()

@property (assign) BOOL prepared;

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects;

@end
@implementation DlibWrapper {
    dlib::shape_predictor sp;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}

- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
    
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
    
    if (!self.prepared) {
        [self prepare];
    }
    NSLog(@"sampleBuffer in .mm :********************* %@",sampleBuffer);
    /*CMSampleBuffer 0x1c83be70 retainCount: 1 allocator: 0x3826a710
     invalid = NO
     dataReady = YES
     makeDataReadyCallback = 0x0
     makeDataReadyRefcon = 0x0
     buffer-level attachments:
     Orientation(P) = 1
     {MakerApple}(P) = <CFBasicHash 0x1c83ab20 [0x3826a710]>{type = mutable dict, count = 7,
     entries =>
     0 : <CFString 0x38321d20 [0x3826a710]>{contents = "7"} = <CFNumber 0x176707a0 [0x3826a710]>{value = +1, type = kCFNumberSInt32Type}
     1 : <CFString 0x38321ce0 [0x3826a710]>{contents = "3"} = <CFBasicHash 0x1c8384a0 [0x3826a710]>{type = mutable dict, count = 4,
     entries =>
     0 : <CFString 0x383203f0 [0x3826a710]>{contents = "timescale"} = <CFNumber 0x1c8384d0 [0x3826a710]>{value = +1000000000, type = kCFNumberSInt32Type}
     1 : <CFString 0x38320400 [0x3826a710]>{contents = "epoch"} = <CFNumber 0x1758b450 [0x3826a710]>{value = +0, type = kCFNumberSInt32Type}
     2 : <CFString 0x383203e0 [0x3826a710]>{contents = "value"} = <CFNumber 0x1c836740 [0x3826a710]>{value = +224557028654458, type = kCFNumberSInt64Type}
     5 : <CFString 0x38320410 [0x3826a710]>{contents = "flags"} = <CFNumber 0x176707a0 [0x3826a710]>{value = +1, type = kCFNumberSInt32Type}
     }
     
     3 : <CFString 0x38321d30 [0x3826a710]>{contents = "8"} = <CFArray 0x1c838bb0 [0x3826a710]>{type = mutable-small, count = 3, values = (
     0 : <CFNumber 0x1c837ee0 [0x3826a710]>{value = +0.0219294913, type = kCFNumberFloat32Type}
     1 : <CFNumber 0x1c839700 [0x3826a710]>{value = -0.9258547425, type = kCFNumberFloat32Type}
     2 : <CFNumber 0x1c839ed0 [0x3826a710]>{value = -0.2602266669, type = kCFNumberFloat32Type}
     )}
     4 : <CFString 0x38321cf0 [0x3826a710]>{contents = "4"} = <CFNumber 0x1758b450 [0x3826a710]>{value = +0, type = kCFNumberSInt32Type}
     7 : <CFString 0x38321d00 [0x3826a710]>{contents = "5"} = <CFNumber 0x1c837690 [0x3826a710]>{value = +203, type = kCFNumberSInt32Type}
     8 : <CFString 0x38321cc0 [0x3826a710]>{contents = "1"} = <CFNumber 0x17672660 [0x3826a710]>{value = +2, type = kCFNumberSInt32Type}
     10 : <CFString 0x38321d10 [0x3826a710]>{contents = "6"} = <CFNumber 0x1c839c10 [0x3826a710]>{value = +235, type = kCFNumberSInt32Type}
     }
     
     {Exif}    (P) = <CFBasicHash 0x1c83a5b0 [0x3826a710]>{type = mutable dict, count = 19,
     entries =>
     0 : <CFString 0x3845d77c [0x3826a710]>{contents = "FocalLength"} = <CFNumber 0x1c83c0d0 [0x3826a710]>{value = +1.85000000000000008882, type = kCFNumberFloat64Type}
     1 : <CFString 0x3845d74c [0x3826a710]>{contents = "MeteringMode"} = <CFNumber 0x17678e00 [0x3826a710]>{value = +5, type = kCFNumberSInt32Type}
     2 : <CFString 0x3845d6ec [0x3826a710]>{contents = "ShutterSpeedValue"} = <CFNumber 0x1c8389b0 [0x3826a710]>{value = +5.05889368905356828776, type = kCFNumberFloat64Type}
     3 : <CFString 0x3845d5ec [0x3826a710]>{contents = "FNumber"} = <CFNumber 0x1c83b9f0 [0x3826a710]>{value = +2.39999999999999991118, type = kCFNumberFloat64Type}
     4 : <CFString 0x3845d91c [0x3826a710]>{contents = "FocalLenIn35mmFilm"} = <CFNumber 0x1c83d600 [0x3826a710]>{value = +35, type = kCFNumberSInt32Type}
     5 : <CFString 0x3845d8bc [0x3826a710]>{contents = "SceneType"} = <CFNumber 0x176707a0 [0x3826a710]>{value = +1, type = kCFNumberSInt32Type}
     6 : <CFString 0x3845d9ec [0x3826a710]>{contents = "LensModel"} = <CFString 0x1c838eb0 [0x3826a710]>{contents = "iPhone 4S front camera 1.85mm f/2.4"}
     7 : <CFString 0x3845d80c [0x3826a710]>{contents = "PixelXDimension"} = <CFNumber 0x1c83cdd0 [0x3826a710]>{value = +480, type = kCFNumberSInt32Type}
     8 : <CFString 0x38323890 [0x3826a710]>{contents = "ExposureTime"} = <CFNumber 0x1c836420 [0x3826a710]>{value = +0.03030303030303030387, type = kCFNumberFloat64Type}
     9 : <CFString 0x3845d71c [0x3826a710]>{contents = "ExposureBiasValue"} = <CFNumber 0x1c837120 [0x3826a710]>{value = +0.0, type = kCFNumberFloat64Type}
     11 : <CFString 0x38324650 [0x3826a710]>{contents = "BrightnessValue"} = <CFNumber 0x1c8368e0 [0x3826a710]>{value = +2.02885914569881942171, type = kCFNumberFloat64Type}
     12 : <CFString 0x3845d6fc [0x3826a710]>{contents = "ApertureValue"} = <CFNumber 0x1c836a00 [0x3826a710]>{value = +2.52606881166758778789, type = kCFNumberFloat64Type}
     13 : <CFString 0x3845d9dc [0x3826a710]>{contents = "LensMake"} = <CFString 0x1c836b70 [0x3826a710]>{contents = "Apple"}
     14 : <CFString 0x3845d9cc [0x3826a710]>{contents = "LensSpecification"} = <CFArray 0x1c83cbf0 [0x3826a710]>{type = mutable-small, count = 4, values = (
     0 : <CFNumber 0x1c83cc90 [0x3826a710]>{value = +1.85000000000000008882, type = kCFNumberFloat64Type}
     1 : <CFNumber 0x1c83cca0 [0x3826a710]>{value = +1.85000000000000008882, type = kCFNumberFloat64Type}
     2 : <CFNumber 0x17677a20 [0x3826a710]>{value = +2.39999999999999991118, type = kCFNumberFloat64Type}
     3 : <CFNumber 0x17677a30 [0x3826a710]>{value = +2.39999999999999991118, type = kCFNumberFloat64Type}
     )}
     15 : <CFString 0x3845d76c [0x3826a710]>{contents = "Flash"} = <CFNumber 0x1c83d370 [0x3826a710]>{value = +32, type = kCFNumberSInt32Type}
     19 : <CFString 0x3845d81c [0x3826a710]>{contents = "PixelYDimension"} = <CFNumber 0x1c83d380 [0x3826a710]>{value = +360, type = kCFNumberSInt32Type}
     20 : <CFString 0x3845d89c [0x3826a710]>{contents = "SensingMethod"} = <CFNumber 0x17672660 [0x3826a710]>{value = +2, type = kCFNumberSInt32Type}
     21 : <CFString 0x3845d61c [0x3826a710]>{contents = "ISOSpeedRatings"} = <CFArray 0x1c83c890 [0x3826a710]>{type = mutable-small, count = 1, values = (
     0 : <CFNumber 0x1c83b9e0 [0x3826a710]>{value = +250, type = kCFNumberSInt16Type}
     )}
     22 : <CFString 0x3845d8fc [0x3826a710]>{contents = "WhiteBalance"} = <CFNumber 0x1758b450 [0x3826a710]>{value = +0, type = kCFNumberSInt32Type}
     }
     
     formatDescription = <CMVideoFormatDescription 0x1c837e30 [0x3826a710]> {
     mediaType:'vide'
     mediaSubType:'BGRA'
     mediaSpecific: {
     codecType: 'BGRA'		dimensions: 480 x 360
     }
     extensions: {<CFBasicHash 0x1c837830 [0x3826a710]>{type = immutable dict, count = 5,
     entries =>
     2 : <CFString 0x3831f720 [0x3826a710]>{contents = "Version"} = <CFNumber 0x17672660 [0x3826a710]>{value = +2, type = kCFNumberSInt32Type}
     3 : <CFString 0x3831f6e0 [0x3826a710]>{contents = "CVBytesPerRow"} = <CFNumber 0x1c837b20 [0x3826a710]>{value = +1920, type = kCFNumberSInt32Type}
     4 : <CFString 0x3835a4d4 [0x3826a710]>{contents = "CVImageBufferYCbCrMatrix"} = <CFString 0x3835a4f4 [0x3826a710]>{contents = "ITU_R_601_4"}
     5 : <CFString 0x3835a514 [0x3826a710]>{contents = "CVImageBufferColorPrimaries"} = <CFString 0x3835a4e4 [0x3826a710]>{contents = "ITU_R_709_2"}
     6 : <CFString 0x3835a554 [0x3826a710]>{contents = "CVImageBufferTransferFunction"} = <CFString 0x3835a4e4 [0x3826a710]>{contents = "ITU_R_709_2"}
     }
     }
     }
     sbufToTrackReadiness = 0x0
     numSamples = 1
     sampleTimingArray[1] = {
     {PTS = {224557028654458/1000000000 = 224557.029}, DTS = {INVALID}, duration = {INVALID}},
     }
     imageBuffer = 0x1c837d70*/
    NSLog(@"******rects**************%@",rects);
    /*(
     "NSRect: {{176.44, 118.44}, {141.11998, 141.12}}"
     )*/
    NSLog(@"******rects done**************");
    
    dlib::array2d<dlib::bgr_pixel> img;
    
    // MARK: magic
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    // set_size expects rows, cols format
    img.set_size(height, width);
    
    // copy samplebuffer image data into dlib image format
    img.reset();
    long position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();

        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        char b = baseBuffer[bufferLocation];
        char g = baseBuffer[bufferLocation + 1];
        char r = baseBuffer[bufferLocation + 2];
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        dlib::bgr_pixel newpixel(b, g, r);
        pixel = newpixel;
        
        position++;
    }
    
    // unlock buffer again until we need it again
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    // convert the face bounds list to dlib format
    std::vector<dlib::rectangle> convertedRectangles = [DlibWrapper convertCGRectValueArray:rects];
    NSLog(@"********convertedRectangles************: %lu",convertedRectangles.size()); // output : 1

    // for every detected face
    for (unsigned long j = 0; j < convertedRectangles.size(); ++j)
    {
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        
        // detect all landmarks
        dlib::full_object_detection shape = sp(img, oneFaceRect);
        
        NSLog(@"********shape************: %lu",shape.num_parts());//output : 68
        NSLog(@"start drawing");
        // and draw them into the image (samplebuffer)
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            dlib::point p = shape.part(k);
            draw_solid_circle(img, p, 3, dlib::rgb_pixel(0, 255, 255));
            std::cout << p;
            if (k >5 && k<50) {
                draw_solid_circle(img, p, 3, dlib::rgb_pixel(255, 0, 255));

            }
            NSLog(@"points x : %lu y :%lu",p.x(),p.y());
            
        }
        NSLog(@"end drawing");

    }
    
//     lets put everything back where it belongs
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // copy dlib image data back into samplebuffer
    img.reset();
    position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();
        
        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        baseBuffer[bufferLocation] = pixel.blue;
        baseBuffer[bufferLocation + 1] = pixel.green;
        baseBuffer[bufferLocation + 2] = pixel.red;
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        position++;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
//    return imageBuffer;
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        long left = rect.origin.x;
        long top = rect.origin.y;
        long right = left + rect.size.width;
        long bottom = top + rect.size.height;
        dlib::rectangle dlibRect(left, top, right, bottom);

        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}

@end
