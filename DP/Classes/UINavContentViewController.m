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

//@synthesize rotationDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupNavBar];
}

- (void) viewWillAppear:(BOOL)animated {
    //[self doLayoutForOrientation:[UINavContentViewController interfaceFromDeviceOrientation:[[UIDevice currentDevice] orientation]]];
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
/*
- (void) doLayoutForOrientation:(UIInterfaceOrientation) toOrientation {
    if ([self.rotationDelegate respondsToSelector:@selector(layoutForOrientation:)])
        [self.rotationDelegate layoutForOrientation:toOrientation];
}
*/

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation {
}
/*
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //[self doLayoutForOrientation:toInterfaceOrientation];
}
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation
								   duration:duration];
    
    //[self doLayoutForOrientation:toInterfaceOrientation];
}
*/
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
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logosmall.png"]];
    /*
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
     initWithImage: [UIImage imageNamed: @"menu.png"]
     style: UIBarButtonItemStylePlain
     target: self
     action: @selector(closeView:)];
     */
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem: UIBarButtonSystemItemAction
                                                 target: self action: @selector(showView:)],
                                                /*
                                                [[UIBarButtonItem alloc]
                                                 initWithTitle: @"xx"
                                                 style:UIBarButtonItemStylePlain
                                                 target: self
                                                 action: @selector(showView:)],
                                                */
                                                [[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                                 target: self action: @selector(showView:)]];
    
    for (int i=0; i < self.navigationItem.rightBarButtonItems.count; i++) {
        id bbi = [self.navigationItem.rightBarButtonItems objectAtIndex:i];
        if (bbi)
            [bbi setTag:101 + i];
    }
}


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
