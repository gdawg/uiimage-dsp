# UIImageDSP

Category on UIImage provides processing extensions using the Accelerate framework. Original implemenation can be found [here](https://github.com/gdawg/uiimage-dsp).

## Installation

Add a dependency on `UIImageDSP` in your pod spec or Podfile

## Use

```objc
#import <UIImageDSP/UIImage+DSP.h>

image = [originalImage imageByApplyingGaussianBlur3x3];
```

Look in UIImage+DSP for all available methods.
