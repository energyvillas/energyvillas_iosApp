//
//  DPMainViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPMainViewController.h"
#import "DPConstants.h"



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
    [self.view addSubview: self.navController.view];
    self.navController.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [self fixBackgroundImage];
    [super viewWillAppear:animated];
}

-(void) doLayoutSubViews {
    int cnt = self.view.subviews.count;
    if (cnt == 1) {
        UIView *v = self.view.subviews[0];
        if (v == self.navController.view) {
            CGRect frm = v.frame;
            frm = self.view.bounds;
            v.frame = frm;
        }
    }
}

- (void) fixBackgroundImage {
    NSString *imgName;
    if (IS_PORTRAIT)
        imgName = @"Background/bg_v.jpg";
    else
        imgName = @"Background/bg_h.jpg";
    
    
    self.view.layer.contents = (id)[[UIImage imageNamed:imgName] CGImage];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self fixBackgroundImage];
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
