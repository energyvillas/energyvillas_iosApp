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

-(void) doLayoutSubViews:(BOOL)fixtop {
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

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [self doFixFrames:viewController fixTop:YES];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self fixBackgroundImage];
    
    [self doFixFrames:navController.topViewController fixTop:NO];
}

-(void) doFixFrames:(UIViewController *)viewController fixTop:(BOOL)fixtop {
    [self fixFrames];
    if (viewController && [viewController isKindOfClass:[UINavContentViewController class]]) {
        //dispatch_async(dispatch_get_main_queue(), ^{
//        [(UINavContentViewController *)viewController doLayoutSubViews:fixtop];
        [viewController.view setNeedsDisplay];
//        [viewController.view setNeedsLayout];
        //});
    }
}

- (void) fixFrames {
    UIViewController *tvc = navController.topViewController;
    
    CGRect nc_nbf = self.navController.navigationBar.frame;
    CGRect tvc_svf = tvc.view.superview.frame;
    CGRect tvc_vf = tvc.view.frame;
    
    if (IS_LANDSCAPE) {
        tvc_vf = CGRectMake(0, nc_nbf.size.height - tvc_svf.origin.y,
                            tvc_svf.size.width,
                            tvc_svf.size.height);
        //    tvc.view.frame = tvc_vf;
//        [tvc.view setNeedsDisplay];
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
