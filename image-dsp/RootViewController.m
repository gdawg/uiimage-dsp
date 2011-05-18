//
//  RootViewController.m
//  image-dsp
//
//  Created by andrew on 18/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "DisplayImageVc.h"

#import "UIImage+DSP.h"

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"vDSP";
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Gaussian Blur 3x3";
            break;
            
        case 1:
            cell.textLabel.text = @"Gaussian Blur 5x5";
            break;
            
        case 2:
            cell.textLabel.text = @"Box Blur 3x3";
            break;
            
        case 3:
            cell.textLabel.text = @"Sharpen 3x3";
            break;
            
        case 4:
            cell.textLabel.text = @"Emboss 3x3";
            break;
            
        default:
            break;
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setup for display
    DisplayImageVc* vc = [[DisplayImageVc alloc] initWithNibName:@"DisplayImageVc" bundle:nil];

    // load source image
    vc.src = [[UIImage imageNamed:@"image.png"] retain];

    // transform as selected
    switch (indexPath.row) {
        case 0:
            vc.dest = [[vc.src imageByApplyingGaussianBlur3x3] retain];
            break;
            
        case 1:
            vc.dest = [[vc.src imageByApplyingGaussianBlur5x5] retain];
            break;
            
        case 2:
            vc.dest = [[vc.src imageByApplyingBoxBlur3x3] retain];
            break;
            
        case 3:
            vc.dest = [[vc.src imageByApplyingSharpen3x3] retain];
            break;
            
        case 4:
            vc.dest = [[vc.src imageByApplyingEmboss3x3] retain];
            break;
            
        default:
            break;
    }
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.title = cell.textLabel.text;

    [self.navigationController pushViewController:vc animated:NO];
    [vc autorelease];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Examples:";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"UIImage category for vDSP processing.\n\nhttps://github.com/gdawg/uiimage-dsp";
            break;
            
        default:
            break;
    }
    return nil;
}

@end
