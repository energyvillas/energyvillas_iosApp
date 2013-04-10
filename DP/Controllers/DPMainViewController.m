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

@implementation DPMainViewController {
    bool framesDone;
}

@synthesize navController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        framesDone = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIView *navView = self.navController.view;
//    CGRect frm = navView.frame;
    [self.view addSubview: navView];
    self.navController.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [self fixBackgroundImage];
    if (!framesDone) {
        [self fixFrames:YES];
        framesDone = YES;
    }
    [super viewWillAppear:animated];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    int cnt = self.view.subviews.count;
    if (cnt == 1) {
        UIView *v = self.view.subviews[0];
        CGRect frm = v.frame;
        frm = self.view.bounds;
        v.frame = frm;
    }
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    return;
    [self fixFrames:NO];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (viewController && [viewController isKindOfClass:[UINavContentViewController class]])
        [(UINavContentViewController *)viewController layoutForOrientation:orientation fixtop:YES];
}
/*
 -(void) navigationController:(UINavigationController *)navigationController
 didShowViewController:(UIViewController *)viewController
 animated:(BOOL)animated {
 }
 */

- (void) fixFrames:(BOOL)fixNavView {
    return;
    if (fixNavView) {
        CGRect sf = [UIScreen mainScreen].applicationFrame;
        self.view.frame = sf;
        
        self.navController.view.frame = CGRectMake(0, 0,
                                                   sf.size.width, sf.size.height);
        
    } else {
        UIViewController *tvc = navController.topViewController;
        BOOL wantsfullscreen = tvc.wantsFullScreenLayout;
        CGRect nc_nbf = self.navController.navigationBar.frame;
        CGRect tvc_svf = tvc.view.superview.frame;
        CGRect tvc_vf = tvc.view.frame;
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            if (wantsfullscreen) {
                CGRect sf = [UIScreen mainScreen].applicationFrame;
                tvc_vf = sf;
                tvc.view.frame = tvc_vf;
            }
        } else {
            if (!wantsfullscreen)
                tvc_vf = CGRectMake(0, nc_nbf.size.height - tvc_svf.origin.y,
                                    tvc_svf.size.width,
                                    tvc_svf.size.height);
            tvc.view.frame = tvc_vf;
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
    
    [self fixFrames:NO];

    return;
    id vc = self.presentedViewController;

    if (!vc)
        vc = navController.topViewController;
    
    if (vc && [vc isKindOfClass:[UINavContentViewController class]])
        [(UINavContentViewController *)vc layoutForOrientation:toInterfaceOrientation fixtop:NO];
    
    int cc = self.childViewControllers.count;
    if (cc > 0)
    if (self.childViewControllers[cc - 1] != self.navController)
    {
        vc = self.childViewControllers[cc - 1];
        if (vc && [vc isKindOfClass:[UINavContentViewController class]])
            [(UINavContentViewController *)vc layoutForOrientation:toInterfaceOrientation fixtop:NO];
    }
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
