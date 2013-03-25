//
//  DPPaidRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPPaidRootViewController.h"
#import "../Classes/DPHtmlContentViewController.h"
#import "../Classes/DPImageContentViewController.h"


#define TAG_TBI_MAIN ((int)1001)
#define TAG_TBI_WHO ((int)1002)
#define TAG_TBI_BUY ((int)1003)
#define TAG_TBI_CALL ((int)1004)
#define TAG_TBI_MORE ((int)1005)


@interface DPPaidRootViewController ()

@property (strong, nonatomic) UIViewController *whoViewController;
@property (strong, nonatomic) UIViewController *buyViewController;
@property (strong, nonatomic) UIViewController *callViewController;
@property (strong, nonatomic) UIViewController *moreViewController;

@end

@implementation DPPaidRootViewController {
    //int currentIndex;
    bool isPortrait;
}

@synthesize whoViewController, buyViewController, callViewController, moreViewController;



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
}

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation {
    switch (toOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = NO;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            isPortrait = YES;
            break;
    }
    
    UIView *sv;
    sv = self.view.superview;
    
    int h = sv.bounds.size.height;
    int w = sv.bounds.size.width;
    
    // iphone sizes
    int H_ADS = 44;
    int H_NEW_NEXT = 100;
    int HL_ADS = 44;
    int WL_NEW_NEXT = 160;
    
    // ipad sizes
    int PAD_H_ADS = 44;
    int PAD_H_NEW_NEXT = 100;
    int PAD_HL_ADS = 44;
    int PAD_WL_NEW_NEXT = 160;
    
    
    // ph : 44, 100, 267
    // lh : 44, 207 (x2),
    // lw : , 160, 320,
    
    bool isPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;

    if (isPhone) {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, 0, w, H_ADS);
            self.nnView.frame = CGRectMake(0, H_ADS, w, H_NEW_NEXT);
            self.mmView.frame = CGRectMake(0, H_ADS + H_NEW_NEXT, w, h - H_ADS - H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(0, 0, w, HL_ADS);
            self.nnView.frame = CGRectMake(0, H_ADS, WL_NEW_NEXT, h - HL_ADS);
            self.mmView.frame = CGRectMake(WL_NEW_NEXT, H_ADS, w - WL_NEW_NEXT, h - HL_ADS);
        }
    } else {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, 0, w, PAD_H_ADS);
            self.nnView.frame = CGRectMake(0, PAD_H_ADS,
                                           w, PAD_H_NEW_NEXT);
            self.mmView.frame = CGRectMake(0, PAD_H_ADS + PAD_H_NEW_NEXT,
                                           w, h - PAD_H_ADS - PAD_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(0, 0, w, PAD_HL_ADS);
            self.nnView.frame = CGRectMake(0, PAD_H_ADS,
                                           PAD_WL_NEW_NEXT, h - PAD_HL_ADS);
            self.mmView.frame = CGRectMake(PAD_WL_NEW_NEXT, PAD_H_ADS,
                                           w - PAD_WL_NEW_NEXT, h - PAD_HL_ADS);
        }
    }        
}

// called when a new view is selected by the user (but not programatically)
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"tapped on tbi => %d", item.tag);
    
    UIViewController *vc;
    switch (item.tag) {
        case TAG_TBI_MAIN:
            [self.navigationController popToRootViewControllerAnimated:YES];
/*            self.navController.view.hidden = NO;
            if (self.whoViewController) self.whoViewController.view.hidden = YES;
            if (self.buyViewController) self.buyViewController.view.hidden = YES;
            if (self.callViewController) self.callViewController.view.hidden = YES;
            if (self.moreViewController) self.moreViewController.view.hidden = YES;
*/            break;
            
        case TAG_TBI_WHO:
            vc = [[DPHtmlContentViewController alloc] initWithHTML:@"hello world"];
            [self.navigationController pushViewController:vc animated:YES];
/*            if (!self.whoViewController) {
                self.whoViewController = [[DPHtmlContentViewController alloc] initWithHTML:@"hello world"];
                
                //CGRect r = CGRectMake(0, 0, 200, 200);
                //UIView *v = self.whoViewController.view;
                //self.whoViewController.view.frame = CGRectMake(0, 0, 200, 200);
                [self addChildViewController:self.whoViewController];
                [self.view addSubview:self.whoViewController.view];
            }
            
            self.navController.view.hidden = YES;
            if (self.whoViewController) self.whoViewController.view.hidden = NO;
            if (self.buyViewController) self.buyViewController.view.hidden = YES;
            if (self.callViewController) self.callViewController.view.hidden = YES;
            if (self.moreViewController) self.moreViewController.view.hidden = YES;
*/            break;
            
        case TAG_TBI_BUY:
            //vc = [[DPImageContentViewController alloc]
            //      initWithImageName:[NSString stringWithFormat:@"%d.jpg", 22]];
            //[self.navController pushViewController:vc animated:YES];
/*            if (!self.buyViewController) {
                self.buyViewController = [[DPImageContentViewController alloc]
                                          initWithImageName:[NSString stringWithFormat:@"%d.jpg", 22]];
                [self addChildViewController:self.buyViewController];
                [self.view addSubview:self.buyViewController.view];
            }
            
            self.navController.view.hidden = YES;
            if (self.whoViewController) self.whoViewController.view.hidden = YES;
            if (self.buyViewController) self.buyViewController.view.hidden = NO;
            if (self.callViewController) self.callViewController.view.hidden = YES;
            if (self.moreViewController) self.moreViewController.view.hidden = YES;
*/            
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
    [self setAdsView:nil];
    [self setNnView:nil];
    [self setMmView:nil];
    [super viewDidUnload];
}
@end
