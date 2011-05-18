//
//  DisplayImageVc.h
//  image-dsp
//
//  Created by andrew on 18/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DisplayImageVc : UIViewController {
}

@property (nonatomic,retain) IBOutlet UIImageView* imageView;

@property (nonatomic,retain) UIImage* src;
@property (nonatomic,retain) UIImage* dest;

-(IBAction) changeImage:(UISegmentedControl*)imageControl;

@end
