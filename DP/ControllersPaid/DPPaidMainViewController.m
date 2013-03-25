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

#define TAG_TBI_MAIN ((int)1001)
#define TAG_TBI_WHO ((int)1002)
#define TAG_TBI_BUY ((int)1003)
#define TAG_TBI_CALL ((int)1004)
#define TAG_TBI_MORE ((int)1005)

@interface DPPaidMainViewController ()

@end

@implementation DPPaidMainViewController {
    bool framesDone;
}

@synthesize navController, tabBar;

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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    id tvc = navController.topViewController;
    if (tvc && [tvc isKindOfClass:[UINavContentViewController class]])
        [(UINavContentViewController *)tvc layoutForOrientation:toInterfaceOrientation];
}

// called when a new view is selected by the user (but not programatically)
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"tapped on tbi => %d", item.tag);
    
    UIViewController *vc;
    switch (item.tag) {
        case TAG_TBI_MAIN:
            [self.navController popToRootViewControllerAnimated:YES];
            break;
            
        case TAG_TBI_WHO:
            vc = [[DPHtmlContentViewController alloc] initWithHTML:@"hello world"];
            [self.navController pushViewController:vc animated:YES];
            
            break;
            
        case TAG_TBI_BUY:
            vc = [[DPImageContentViewController alloc]
                  initWithImageName:[NSString stringWithFormat:@"%d.jpg", 22]];
            [self.navController pushViewController:vc animated:YES];
            
            break;
            
        case TAG_TBI_CALL:
            
            break;
            
        case TAG_TBI_MORE:
            
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
    [super viewDidUnload];
}
@end
