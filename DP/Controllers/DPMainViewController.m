//
//  DPMainViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMainViewController.h"

@interface DPMainViewController ()

@end

@implementation DPMainViewController

@synthesize navController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview: navController.view];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    id tvc = navController.topViewController;
    if (tvc && [tvc isKindOfClass:[UINavContentViewController class]])
        //[(UINavContentViewController *)tvc doLayoutForOrientation:toInterfaceOrientation];
        [(UINavContentViewController *)tvc layoutForOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNavController:nil];
    [super viewDidUnload];
}
@end
