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
bool framesDone = NO;

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
    [self.view addSubview: self.navController.view];
}

- (void) viewWillAppear:(BOOL)animated {
    if (!framesDone) {
        CGRect sf = [UIScreen mainScreen].applicationFrame;
        NSLog(@"appframe : (x, y, w, h) = (%f, %f, %f, %f)", sf.origin.x, sf.origin.y, sf .size.width, sf.size.height);
        self.view.frame = sf;
        self.navController.view.frame = CGRectMake(0, 0, sf.size.width, sf.size.height);
        framesDone = YES;
    }
    [super viewWillAppear:animated];
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
