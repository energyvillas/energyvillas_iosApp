//
//  UINavContentViewController.m
//  testSV
//
//  Created by george on 16/3/13.
//  Copyright (c) 2013 george. All rights reserved.
//

#import "UINavContentViewController.h"

@interface UINavContentViewController ()
@end

@implementation UINavContentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupNavBar];
}

- (void) viewWillAppear:(BOOL)animated {
    [self layoutForOrientation:[UINavContentViewController interfaceFromDeviceOrientation:[[UIDevice currentDevice] orientation]]];
}

+ (UIInterfaceOrientation) interfaceFromDeviceOrientation: (UIDeviceOrientation) deviceOrientation {
    switch (deviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            return UIInterfaceOrientationPortraitUpsideDown;
            
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            return UIInterfaceOrientationLandscapeRight;
            
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            return UIInterfaceOrientationLandscapeLeft;
            
        default:
            return UIInterfaceOrientationPortrait;
    }
}

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation {
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) setupNavBar {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage: [UIImage imageNamed: @"back.png"]
                                             style: UIBarButtonItemStylePlain
                                             target: self
                                             action: @selector(closeView:)];    
    
/*
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage: [UIImage imageNamed: @"logosmall.png"]
                                             style: UIBarButtonItemStylePlain
                                             target: self
                                             action: @selector(closeView:)];

    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.hidesBackButton = NO;
*/


	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logosmall.png"]];

    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem: UIBarButtonSystemItemAction
                                                 target: self action: @selector(showView:)],
                                                
                                                [[UIBarButtonItem alloc]
                                                 initWithImage:[UIImage imageNamed:@"back.png"]
                                                 style:UIBarButtonItemStylePlain
                                                 target: self
                                                 action: @selector(showView:)],
                                                
                                                [[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                                 target: self action: @selector(showView:)]];
    
    for (int i=0; i < self.navigationItem.rightBarButtonItems.count; i++) {
        id bbi = [self.navigationItem.rightBarButtonItems objectAtIndex:i];
        if (bbi)
            [bbi setTag:101 + i];
    }
}

- (void) closeView: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// PENDING use a delegate protocol form handling clicks
- (void) showView: (id) sender {
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    if (bbi == nil) return;
    
    switch (bbi.tag) {
        case 101:
            // do 101 stuff
            break;
        case 102:
            // do 102 stuff
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
