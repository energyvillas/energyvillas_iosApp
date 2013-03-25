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

#define TAG_TBI_MAIN ((int)1001)
#define TAG_TBI_WHO ((int)1002)
#define TAG_TBI_BUY ((int)1003)
#define TAG_TBI_CALL ((int)1004)
#define TAG_TBI_MORE ((int)1005)

@interface DPPaidMainViewController ()
@property (strong, nonatomic) UIViewController *whoViewController;
@property (strong, nonatomic) UIViewController *buyViewController;
@property (strong, nonatomic) UIViewController *callViewController;
@property (strong, nonatomic) UIViewController *moreViewController;
@end

@implementation DPPaidMainViewController {
    bool framesDone;
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

    self.tbiMain.title = NSLocalizedString(@"tbiMain_Title", nil);
    self.tbiWho.title = NSLocalizedString(@"tbiWho_Title", nil);
    self.tbiBuy.title = NSLocalizedString(@"tbiBuy_Title", nil);
    self.tbiCall.title = NSLocalizedString(@"tbiCall_Title", nil);
    self.tbiMore.title = NSLocalizedString(@"tbiMore_Title", nil);
    
    self.tabBar.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    if (!framesDone) {
        CGRect sf = [UIScreen mainScreen].applicationFrame;
        NSLog(@"appframe : (x, y, w, h) = (%f, %f, %f, %f)", sf.origin.x, sf.origin.y, sf .size.width, sf.size.height);
        self.view.frame = sf;
        int tabbarHeight = self.tabBar.frame.size.height;
        self.navController.view.frame = CGRectMake(0, 0, sf.size.width, sf.size.height - tabbarHeight);
        self.tabBar.frame = CGRectMake(0, sf.size.height - tabbarHeight,
                                       sf.size.width, tabbarHeight);
        framesDone = YES;
    }
    [super viewWillAppear:animated];
}

- (CGRect) calcViewFrame {
    CGRect sf = [UIScreen mainScreen].applicationFrame;
    self.view.frame = sf;
    int tabbarHeight = self.tabBar.frame.size.height;
    return CGRectMake(0, 0, sf.size.width, sf.size.height - tabbarHeight);
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    id tvc = navController.topViewController;
    if (tvc && [tvc isKindOfClass:[UINavContentViewController class]])
        [(UINavContentViewController *)tvc layoutForOrientation:toInterfaceOrientation];
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
