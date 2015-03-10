//
//  MasterViewController.m
//  UIImageDSPExample
//
//  Created by Sean Soper on 3/10/15.
//
//

#import <UIImageDSP/UIImage+DSP.h>

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()
@property (nonatomic, strong) NSArray *blurs;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.blurs = @[@"Gaussian Blur 3x3",
                   @"Gaussian Blur 5x5",
                   @"Box Blur 3x3",
                   @"Sharpen 3x3",
                   @"Emboss 3x3",
                   @"Gaussian Blur 9x9",
                   @"Gaussian Blur 10x10",
                   @"Gaussian Blur 11x11",
                   @"Gaussian Blur 12x12"];

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        controller.image = [self imageForIndexPath: indexPath];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

- (UIImage *) imageForIndexPath:(NSIndexPath *) indexPath {
    UIImage *originalImage = [UIImage imageNamed:@"Image"];
    UIImage *image;

    switch (indexPath.row) {
    case 0:
        image = [originalImage imageByApplyingGaussianBlur3x3];
        break;

    case 1:
        image = [originalImage imageByApplyingGaussianBlur5x5];
        break;
        
    case 2:
        image = [originalImage imageByApplyingBoxBlur3x3];
        break;
        
    case 3:
        image = [originalImage imageByApplyingSharpen3x3];
        break;
        
    case 4:
        image = [originalImage imageByApplyingEmboss3x3];
        break;

    case 5:
        image = [originalImage imageByApplyingGaussianBlurOfSize:9 withSigmaSquared:90.0];
        break;

    case 6:
        image = [originalImage imageByApplyingGaussianBlurOfSize:10 withSigmaSquared:90.0];
        break;

    case 7:
        image = [originalImage imageByApplyingGaussianBlurOfSize:11 withSigmaSquared:90.0];
        break;

    case 8:
        image = [originalImage imageByApplyingGaussianBlurOfSize:13 withSigmaSquared:90.0];
        break;
    }

    return image;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.blurs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = self.blurs[indexPath.row];
    return cell;
}

@end
