//
//  DPPaidMainViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPPaidMainViewController.h"
#import "../Classes/DPHtmlContentViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "../Models/DPDataLoader.h"
#import "DPConstants.h"



@interface DPPaidMainViewController ()
@property (strong, nonatomic) UIViewController *whoViewController;
@property (strong, nonatomic) UIViewController *buyViewController;
@property (strong, nonatomic) UIViewController *callViewController;
@property (strong, nonatomic) UIViewController *moreViewController;
@end

@implementation DPPaidMainViewController {
    bool framesDone;
    bool isPortrait;
}

@synthesize navController, tabBar;
@synthesize whoViewController, buyViewController, callViewController, moreViewController;

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
    [self.view addSubview: self.navController.view];
    self.navController.delegate = self;

    self.tbiMain.title = NSLocalizedString(ktbiMain_Title, nil);
    self.tbiWho.title = NSLocalizedString(ktbiWho_Title, nil);
    self.tbiBuy.title = NSLocalizedString(ktbiBuy_Title, nil);
    self.tbiCall.title = NSLocalizedString(ktbiCall_Title, nil);
    self.tbiMore.title = NSLocalizedString(ktbiMore_Title, nil);
    
    self.tabBar.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
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

- (void) viewWillAppear:(BOOL)animated {
    if (!framesDone) {
        [self fixFrames:YES];
        self.tabBar.selectedItem = self.tbiMain;
        framesDone = YES;
    }
    [super viewWillAppear:animated];
}

- (void) fixFrames:(BOOL)fixNavView {
    if (fixNavView) {
        CGRect sf = [UIScreen mainScreen].applicationFrame;
        self.view.frame = sf;
        CGRect tbf = self.tabBar.frame;

        self.navController.view.frame = CGRectMake(0, 0,
                                                   sf.size.width,
                                                   sf.size.height - tbf.size.height);
    
    } else {
        UIViewController *tvc = navController.topViewController;
        
        CGRect nc_nbf = self.navController.navigationBar.frame;
        CGRect tvc_svf = tvc.view.superview.frame;
        CGRect tvc_vf = tvc.view.frame;

        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(orientation))
            ;
        else {
            tvc_vf = CGRectMake(0, nc_nbf.size.height - tvc_svf.origin.y,
                                tvc_svf.size.width,
                                tvc_svf.size.height);
            tvc.view.frame = tvc_vf;
        }
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {    
    [self fixFrames:NO];

    id tvc = navController.topViewController;
    if (tvc && [tvc isKindOfClass:[UINavContentViewController class]])
        [(UINavContentViewController *)tvc layoutForOrientation:toInterfaceOrientation fixtop:NO];
}

- (void) cleanControllers:(UIViewController *)tvc {
    if (tvc == self.whoViewController) self.whoViewController = nil;
    if (tvc == self.buyViewController) self.buyViewController = nil;
    if (tvc == self.callViewController) self.callViewController = nil;
    if (tvc == self.moreViewController) self.moreViewController = nil;
}

- (void) checkRootAndPop:(UIViewController *)tvc {
    UIViewController *rvc = self.navController.viewControllers[0];
    if (tvc != rvc) {
        [self.navController popViewControllerAnimated:NO];
        [self cleanControllers:tvc];
    }
}

- (BOOL) checkTop:(UIViewController *)vc {
    UIViewController *tvc = [self.navController topViewController];
    if (tvc == vc) return YES;
    
    [self checkRootAndPop:tvc];
    return NO;
}

- (void) showViewController:(UIViewController *) vc {
    if (!self.navController.navigationBarHidden)
        [self.navController setNavigationBarHidden:YES animated:YES];
    [self.navController pushViewController:vc animated:YES];
}

- (void) showMain {
    UIViewController *tvc = [self.navController topViewController];
    [self.navController setNavigationBarHidden:NO animated:YES];
    [self.navController popToRootViewControllerAnimated:YES];
    
    [self cleanControllers:tvc];
}

- (void) showWho {
    if ([self checkTop:self.whoViewController]) return;
    
    self.whoViewController = [[DPHtmlContentViewController alloc]
                              initWithContentUrl:[NSURL URLWithString:ARTICLES_URL]];
                              //initWithHTML:@"hello world, hi george!!!"];
    
    [self showViewController:self.whoViewController];
}

- (void) showBuy {
    if ([self checkTop:self.buyViewController]) return;
    
    self.buyViewController = [[DPImageContentViewController alloc]
                              initWithImageName:[NSString stringWithFormat:@"%d.jpg", 22]];
    
    [self showViewController:self.buyViewController];
}

- (void) showCall {
}
- (void) showMore {
}

// called when a new view is selected by the user (but not programatically)
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"tapped on tbi => %d", item.tag);
    
    switch (item.tag) {
        case TAG_TBI_MAIN: [self showMain];
            break;
            
        case TAG_TBI_WHO: [self showWho];
            break;
            
        case TAG_TBI_BUY: [self showBuy];
             break;
            
        case TAG_TBI_CALL: [self showCall];
            break;
            
        case TAG_TBI_MORE: [self showMore];
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

// PENDING
- (void)viewDidUnload {
    [self setNavController:nil];
    [self setTabBar:nil];
    [self setTbiMain:nil];
    [self setTbiWho:nil];
    [self setTbiBuy:nil];
    [self setTbiCall:nil];
    [self setTbiMore:nil];

    if (self.whoViewController) {
        self.whoViewController=nil;
    }

    if (self.buyViewController) {
        [self.buyViewController.view removeFromSuperview];
        [self.buyViewController removeFromParentViewController];
        self.buyViewController=nil;
    }

    if (self.callViewController) {
        [self.callViewController.view removeFromSuperview];
        [self.callViewController removeFromParentViewController];
        self.callViewController=nil;
    }

    if (self.moreViewController) {
        [self.moreViewController.view removeFromSuperview];
        [self.moreViewController removeFromParentViewController];
        self.moreViewController=nil;
    }
    
    [super viewDidUnload];
}
@end
