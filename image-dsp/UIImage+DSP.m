//
//  UIImage+Dsp.m
//
//  Created by Andrew from Mad Dog Software (http://www.mad-dog-software.com) on 18/05/11.
//  
//  Use this however you want for whatever you want but no warranty is implied or provided!
//
//  Check here for updates: https://github.com/gdawg/uiimage-dsp

#import "UIImage+Dsp.h"
#import <Accelerate/Accelerate.h>

#import <math.h>

// utility to find position for x/y values in a matrix
#define DSP_KERNEL_POSITION(x,y,size) (x * size + y)

typedef struct {
    CGContextRef ref;
    void* data;
} CGContextAndDataRef;


@implementation UIImage (UIImage_DSP)

// forward definitions of our utility methods so the important stuff's at the top
CGContextAndDataRef _dsp_utils_CreateARGBBitmapContext (CGImageRef inImage);
void _releaseDspData(void *info,const void *data,size_t size);


// the real "workhorse" matrix dsp method
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize matrixRows:(int)matrixRows matrixCols:(int)matrixCols clipValues:(bool)shouldClip {
    UIImage* destImg = nil;

    CGImageRef inImage = self.CGImage;
     
    CGContextAndDataRef dataRef = _dsp_utils_CreateARGBBitmapContext(inImage);
    CGContextRef context = dataRef.ref;
    if (context == NULL) {
        return destImg; // nil
    }
    
    size_t width = CGBitmapContextGetWidth(context);
    size_t height = CGBitmapContextGetHeight(context);
    size_t bpr = CGBitmapContextGetBytesPerRow(context);
    
    CGRect rect = {{0,0},{width,height}}; 
    CGContextDrawImage(context, rect, inImage); 

    // get image data (as char array)
    unsigned char *srcData, *finalData;
    srcData = (unsigned char *)CGBitmapContextGetData (context);
    
    finalData = malloc(bpr * height * sizeof(unsigned char));

    if (srcData != NULL && finalData != NULL)
    {
        size_t dataSize = bpr * height;

        // copy src to destination: technically this is a bit wasteful as we'll overwrite
        // all but the "alpha" portion of finalData during processing but I'm unaware of 
        // a memcpy with stride function
        memcpy(finalData, srcData, dataSize);
    
        // alloc space for our dsp arrays
        float * srcAsFloat = malloc(width*height*sizeof(float));
        float* resultAsFloat = malloc(width*height*sizeof(float));

        // loop through each colour (color) chanel (skip the first chanel, it's alpha and is left alone)
        for (int i=1; i<4; i++) {
            // convert src pixels into float data type
            vDSP_vfltu8(srcData+i,4,srcAsFloat,1,width * height);
            
            // apply matrix using dsp
            switch (matrixSize) {
                case DSPMatrixSize3x3:
                    vDSP_f3x3(srcAsFloat, height, width, matrix, resultAsFloat);
                    break;
                    
                case DSPMatrixSize5x5:
                    vDSP_f5x5(srcAsFloat, height, width, matrix, resultAsFloat);
                    break;
                    
                case DSPMatrixSizeCustom:
                    NSAssert(matrixCols > 0 && matrixRows > 0, 
                             @"invalid usage: please use full method definition and pass rows/cols for matrix");
                    vDSP_imgfir(srcAsFloat, height, width, matrix, resultAsFloat, matrixRows, matrixCols);
                    break;
                    
                default:
                    break;
            }
            
            // certain operations may result in values to large or too small in our output float array
            // so if necessary we clip the results here. This param is optional so that we don't need to take
            // the speed hit on blur operations or others which can't result in invalid float values.
            if (shouldClip) {
                float min = 0;
                float max = 255;
                vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, width * height);
            }
            
            // convert back into bytes and copy into finalData
            vDSP_vfixu8(resultAsFloat, 1, finalData+i, 4, width * height);
        }

        // clean up dsp space
        free(srcAsFloat);
        free(resultAsFloat);
    
        // create new image from out output data
        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, finalData, dataSize, &_releaseDspData);
        CGImageRef cgImage = CGImageCreate(width, height, CGBitmapContextGetBitsPerComponent(context),
                                           CGBitmapContextGetBitsPerPixel(context), CGBitmapContextGetBytesPerRow(context), CGBitmapContextGetColorSpace(context), CGBitmapContextGetBitmapInfo(context), 
                                           dataProvider, NULL, true, kCGRenderingIntentDefault);
        destImg = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
        
        CGImageRelease(cgImage);
        
        // clear all our cg stuff
        CGDataProviderRelease(dataProvider);
        CGContextRelease(context); 
        free(dataRef.data);
    }
    
    return destImg;
}

// convenience methods to make calling conventions easier with defaults
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize {
    return [self imageByApplyingMatrix:matrix ofSize:matrixSize matrixRows:-1 matrixCols:-1 clipValues:NO];
}
-(UIImage*) imageByApplyingMatrix:(float*)matrix ofSize:(DSPMatrixSize)matrixSize clipValues:(bool)shouldClip {
    return [self imageByApplyingMatrix:matrix ofSize:matrixSize matrixRows:-1 matrixCols:-1 clipValues:shouldClip];
}

// uses a pre-calculated kernel
-(UIImage*) imageByApplyingGaussianBlur3x3 {
    static const float kernel[] = { 1/16.0f, 2/16.0f, 1/16.0f, 2/16.0f, 4/16.0f, 2/16.0f, 1/16.0f, 2/16.0f, 1/16.0f };

    return [self imageByApplyingMatrix:(float*)kernel ofSize:DSPMatrixSize3x3];
}

// uses a pre-calculated kernel
-(UIImage*) imageByApplyingGaussianBlur5x5 {
    static float kernel[] = 
    { 1/256.0f,  4/256.0f,  6/256.0f,  4/256.0f, 1/256.0f,
        4/256.0f, 16/256.0f, 24/256.0f, 16/256.0f, 4/256.0f,
        6/256.0f, 24/256.0f, 36/256.0f, 24/256.0f, 6/256.0f,
        4/256.0f, 16/256.0f, 24/256.0f, 16/256.0f, 4/256.0f,
        1/256.0f,  4/256.0f,  6/256.0f,  4/256.0f, 1/256.0f };

    return [self imageByApplyingMatrix:(float*)kernel ofSize:DSPMatrixSize5x5];
}

// utility for calculating 2d gaussian distribution values for generating arrays
-(float) gausValueAt:(float)x andY:(float)y andSigmaSq:(float)sigmaSq {
    float powerResult =  pow(M_E, -( (x*x+y*y) / (2*sigmaSq) ));
    float result = ( 1/(sqrt(2*M_PI*sigmaSq)) ) * powerResult; 
    return result;
}

// arbitrary sized gaussian blur
-(UIImage*) imageByApplyingOnePassGaussianBlurOfSize:(int)kernelSize withSigmaSquared:(float)sigmaSq {
    float kernel[kernelSize * kernelSize];
    int halfSize = (int)(0.5 * kernelSize);
    float sum = 0.0;
    
    // generate the gaussian distribution
    for (int i=0; i<kernelSize; i++) {
        for (int j=0; j<kernelSize; j++) {
            float xDistance = 1.0 * i - halfSize;
            float yDistance = 1.0 * j - halfSize;
            float gausValue = [self gausValueAt:xDistance andY:yDistance andSigmaSq:sigmaSq];
     
            kernel[DSP_KERNEL_POSITION(i, j, kernelSize)] = gausValue;
            
            sum += gausValue;
        }
    }
    
    // normalise to avoid distorting brightness
    for (int i=0; i<kernelSize; i++) {
        for (int j=0; j<kernelSize; j++) {
            float gausValue = kernel[DSP_KERNEL_POSITION(i, j, kernelSize)];
            float normal = gausValue / sum;
            
            kernel[DSP_KERNEL_POSITION(i, j, kernelSize)] = normal;
        }
    }

    // apply the generated kernel
    return [self imageByApplyingMatrix:kernel ofSize:DSPMatrixSizeCustom matrixRows:kernelSize matrixCols:kernelSize clipValues:NO];
}

// ----------- Fast 2 pass Gaussian blur 
-(float) gaussianValueFor:(float)i withSigmaSq:(float)sigmaSq {
    float powerResult =  pow(M_E, -( (i*i) / (2*sigmaSq) ));
    float result = ( 1/(sqrt(2*M_PI*sigmaSq)) ) * powerResult; 
    return result;
}
-(UIImage*) imageByApplyingGaussianBlurOfSize:(int)kernelSize withSigmaSquared:(float)sigmaSq {
    float kernel[kernelSize];
    int halfSize = (int)(0.5 * kernelSize);

    for (int i=0; i<kernelSize; i++) {
        float distance = 1.0 * i - halfSize;
        float gausValue = [self gaussianValueFor:distance withSigmaSq:sigmaSq];
        
        kernel[i] = gausValue;
    }

    [self normaliseMatrix:kernel ofSize:kernelSize];
    
    UIImage* result = self;
    
    // apply this kernel horizontally
    result = [result imageByApplyingMatrix:kernel ofSize:DSPMatrixSizeCustom matrixRows:1 matrixCols:kernelSize clipValues:NO];
    
    // then vertically
    result = [result imageByApplyingMatrix:kernel ofSize:DSPMatrixSizeCustom matrixRows:kernelSize matrixCols:1 clipValues:NO];
    
    return result;
}


-(UIImage*) imageByApplyingBoxBlur3x3 {
    static const float kernel[] = { 1/9.0f, 1/9.0f, 1/9.0f, 1/9.0f, 1/9.0f, 1/9.0f, 1/9.0f, 1/9.0f, 1/9.0f };
    
    return [self imageByApplyingMatrix:(float*)kernel ofSize:DSPMatrixSize3x3];
}


-(UIImage*) imageByApplyingSharpen3x3 {
    static const float kernel[] = { 0.0f, -1/4.0f, 0.0f, -1/4.0f, 8/4.0f, -1/4.0f, 0.0f, -1/4.0f, 0.0f };
    
    return [self imageByApplyingMatrix:(float*)kernel ofSize:DSPMatrixSize3x3 clipValues:YES];
}

-(UIImage*) imageByApplyingEmboss3x3 {
    static const float kernel[] = { -2.0f, -1.0f, 0.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 2.0f };
    
    return [self imageByApplyingMatrix:(float*)kernel ofSize:DSPMatrixSize3x3 clipValues:YES];
}

-(UIImage*) imageByApplyingDiagonalMotionBlur5x5 {
    float kernel[] = { 
        0.22222, 0.27778, 0.22222, 0.05556, 0.00000, 
        0.27778, 0.44444, 0.44444, 0.22222, 0.05556,
        0.22222, 0.44444, 0.55556, 0.44444, 0.22222, 
        0.05556, 0.22222, 0.44444, 0.44444, 0.27778,
        0.00000, 0.05556, 0.22222, 0.27778, 0.22222
    };
    
    [self normaliseMatrix:kernel ofSize:5*5];
    
    return [self imageByApplyingMatrix:(float*)kernel ofSize:DSPMatrixSize5x5 clipValues:YES];
}

-(void) normaliseMatrix:(float*)kernel ofSize:(int)size {
    int entries = size;
    
    // calculate the sum
    float sum = 0.0;
    for (int i=0; i<entries; i++) {
        sum += kernel[i];
    }
    
    // normalise values and store back in array
    for (int i=0; i<entries; i++) {
        float value = kernel[i];
        float normal = value / sum;
        
        kernel[i] = normal;
    }
}


// -------------------------------------------------------------------
// utility methods
// taken from http://iphonedevelopment.blogspot.com/2010/03/irregularly-shaped-uibuttons.html
// and renamed to avoid conflicts for anyone who also includes the original source
CGContextAndDataRef _dsp_utils_CreateARGBBitmapContext (CGImageRef inImage)
{
    CGContextAndDataRef dataRef;
    dataRef.data = NULL;
    dataRef.ref = nil;

    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        return dataRef;
    
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        CGColorSpaceRelease( colorSpace );
        return dataRef;
    }
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    CGColorSpaceRelease( colorSpace );
    
    dataRef.ref = context;
    dataRef.data = bitmapData;
    
    return dataRef;
}

// utility method to free any blocks of char data we sent to any data 
// providers
void _releaseDspData(void *info,const void *data,size_t size) {
    free((unsigned char*)data);
}


@end
