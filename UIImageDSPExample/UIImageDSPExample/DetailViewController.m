//
//  DetailViewController.m
//  UIImageDSPExample
//
//  Created by Sean Soper on 3/10/15.
//
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configureView {
    if (self.image) {
        self.imageView.image = self.image;
    }
}

@end
