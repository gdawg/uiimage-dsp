//
//  UIImage+Dsp.m
//
//  Created by Andrew from Mad Dog Software (http://www.mad-dog-software.com) on 18/05/11.
//  
//  Use this however you want for whatever you want but no warranty is implied or provided!
//
//  Check here for updates: https://github.com/gdawg/uiimage-dsp


//  Most users will just want to call one of the imageByApplying... functions.
//  For more advanced use see the DSPMatrixSize typdef and imageByApplyingMatrix methods. 

#import <Foundation/Foundation.h>

// all the different matrix sizes we support
typedef enum {
    DSPMatrixSize3x3,
    DSPMatrixSize5x5,
    DSPMatrixSizeCustom,
} DSPMatrixSize;


@interface UIImage (UIImage_DSP)

// return auto-released gaussian blurred image
-(UIImage*) imageByApplyingGaussianBlur3x3;
-(UIImage*) imageByApplyingGaussianBlur5x5;

// sharpening
-(UIImage*) imageByApplyingSharpen3x3;

// others
-(UIImage*) imageByApplyingBoxBlur3x3; // not generally as good as gaussian

-(UIImage*) imageByApplyingEmboss3x3;


// if you call these methods directly and do something interesting with them please consider
// sending me details on github so that I may incorporate your awesomeness into the library
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize;
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize;
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize clipValues:(bool)shouldClip;

@end

