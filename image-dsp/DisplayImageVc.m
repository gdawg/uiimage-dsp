//
//  DisplayImageVc.m
//  image-dsp
//
//  Created by andrew on 18/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DisplayImageVc.h"


@implementation DisplayImageVc

@synthesize imageView=__imageView;
@synthesize src=__src;
@synthesize dest=__dest;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = self.dest;
}

-(IBAction) changeImage:(UISegmentedControl*)imageControl {
    switch (imageControl.selectedSegmentIndex) {
        case 0:
            self.imageView.image = self.src;
            break;
            
        case 1:
            self.imageView.image = self.dest;
            break;
            
        default:
            break;
    }
}

@end
