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

// gaussian blur with arbitrary kernel size and sigma (controlling the std deviation => spread => blur amount)
// higher sigmaSq values result in more blur... experiment to find something appropriate for your application,
// for kernel size of 8 you might try 30 to start
-(UIImage*) imageByApplyingGaussianBlurOfSize:(int)kernelSize withSigmaSquared:(float)sigmaSq;

// methods are provided for both a two pass (default) and one pass gaussian blur but the two pass is STRONGLY
// recomended due to mathematical equivallence and greatly increased speed for large kernels
// as such I've left this commented out by default
// -(UIImage*) imageByApplyingOnePassGaussianBlurOfSize:(int)kernelSize withSigmaSquared:(float)sigmaSq;

// sharpening
-(UIImage*) imageByApplyingSharpen3x3;

// others
-(UIImage*) imageByApplyingBoxBlur3x3; // not generally as good as gaussian

-(UIImage*) imageByApplyingEmboss3x3;

-(UIImage*) imageByApplyingDiagonalMotionBlur5x5;

// utility for normalizing matrices
-(void) normaliseMatrix:(float*)kernel ofSize:(int)size;


// if you call these methods directly and do something interesting with them please consider
// sending me details on github so that I may incorporate your awesomeness into the library
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize;
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize;
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize clipValues:(bool)shouldClip;

@end

