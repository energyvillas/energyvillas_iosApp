//
//  DPPaidRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPPaidRootViewController.h"
#import "DPConstants.h"

#import "Article.h"
#import "DPAppHelper.h"

#import "DPAdsViewController.h"
#import "DPNewNextViewController.h"
#import "DPMenuViewController.h"
#import "UIApplication+ScreenDimensions.h"



@interface DPPaidRootViewController ()

@property (strong, nonatomic) DPAdsViewController *adsViewController;
@property (strong, nonatomic) DPNewNextViewController *nnViewController;
@property (strong, nonatomic) DPMenuViewController *mmViewController;
@property (strong, nonatomic) NSString *displayLang;
@end

@implementation DPPaidRootViewController 

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
    [self doLocalize];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                           forKey:@"menuCategory"]];

    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
//    double delayInSeconds = 0.2;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self doLocalize];
//    });
    
    if (![self.displayLang isEqualToString:CURRENT_LANG])
        [self doLocalize];
}

- (void) doLocalize {
    [super doLocalize];
    
    //if (self.adsView.subviews.count > 0)
        [self loadAdsView:YES];
 
    //if (self.nnView.subviews.count > 0)
        [self loadNewNextView:YES];
    
    //if (self.mmView.subviews.count > 0)
        [self loadMenuView:YES];
    
    self.displayLang = CURRENT_LANG;
}

- (void) doLayoutSubViews:(BOOL)fixtop {    
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    
//    CGSize sz = [UIApplication sizeInOrientation:INTERFACE_ORIENTATION];
//    sz.height = sz.height - 44 - 49;
//    if (h != sz.height) {
//        h = sz.height;
//    }

    // iphone sizes
    int PHONE_H_ADS = 60;
    int PHONE_H_NEW_NEXT = 92;
    
    int PHONE_HL_ADS = 60; 
    int PHONE_WL_NEW_NEXT = 181;
    
    // iphone5 sizes
    int PHONE5_H_ADS = 60; 
    int PHONE5_H_NEW_NEXT = 92;
    
    int PHONE5_HL_ADS = 60; 
    int PHONE5_WL_NEW_NEXT = 210; //181
    
    // ipad sizes
    int PAD_H_ADS = 120;
    int PAD_H_NEW_NEXT = 221;
    
    int PAD_HL_ADS = 120;
    int PAD_WL_NEW_NEXT = 465;
    
    
    if (IS_IPHONE) {
        if (IS_PORTRAIT) {
            self.adsView.frame = CGRectMake(0, top, w, PHONE_H_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PHONE_H_ADS, w, PHONE_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, top + PHONE_H_ADS + PHONE_H_NEW_NEXT,
                                           w, h - PHONE_H_ADS - PHONE_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(PHONE_WL_NEW_NEXT, top,
                                            w - PHONE_WL_NEW_NEXT, PHONE_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, top, PHONE_WL_NEW_NEXT, h);
            
            self.mmView.frame = CGRectMake(PHONE_WL_NEW_NEXT, top + PHONE_HL_ADS,
                                           w - PHONE_WL_NEW_NEXT, h - PHONE_HL_ADS);
        }
    } else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            self.adsView.frame = CGRectMake(0, top, w, PHONE5_H_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PHONE5_H_ADS, w, PHONE5_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, top + PHONE5_H_ADS + PHONE5_H_NEW_NEXT,
                                           w, h - PHONE5_H_ADS - PHONE5_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(PHONE5_WL_NEW_NEXT, top,
                                            w - PHONE5_WL_NEW_NEXT, PHONE5_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, top,
                                           PHONE5_WL_NEW_NEXT, h);
            
            self.mmView.frame = CGRectMake(PHONE5_WL_NEW_NEXT, top + PHONE5_HL_ADS,
                                           w - PHONE5_WL_NEW_NEXT, h - PHONE5_HL_ADS);
        }
    } else /* if (IS_IPAD) */ {
        if (IS_PORTRAIT) {
            self.adsView.frame = CGRectMake(0, top, w, PAD_H_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PAD_H_ADS,
                                           w, PAD_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, top + PAD_H_ADS + PAD_H_NEW_NEXT,
                                           w, h - PAD_H_ADS - PAD_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(0, top, w, PAD_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PAD_HL_ADS,
                                           PAD_WL_NEW_NEXT, h - PAD_HL_ADS);
            
            self.mmView.frame = CGRectMake(PAD_WL_NEW_NEXT, top + PAD_H_ADS,
                                           w - PAD_WL_NEW_NEXT, h - PAD_HL_ADS);
        }
    }

    // this is a fix for when returning from vimeo player in landscape
    CGRect nbf = self.navigationController.navigationBar.frame;
    nbf.size.height = 44;
    nbf.origin = CGPointZero;
    self.navigationController.navigationBar.frame = nbf;
    //
    
    [self loadAdsView:NO];
    [self loadNewNextView:NO];
    [self loadMenuView:NO];
}

- (void) loadAdsView:(BOOL)reload {
    int currPage = GET_ADS_COMMON_CURR_PAGE();
    if (/**/reload && /**/self.adsViewController != nil) {
        currPage = self.adsViewController.currentAdPage;
        SET_ADS_COMMON_CURR_PAGE(currPage);
        [self.adsViewController.view removeFromSuperview];
        [self.adsViewController removeFromParentViewController];
        self.adsViewController = nil;
    }
    
    if (self.adsViewController == nil) {
        self.adsViewController = [[DPAdsViewController alloc] initWithGroup:BANNER_GROUP_COMMON_MAIN initialPage:currPage];
        self.adsViewController.view.frame = self.adsView.bounds;
        [self addChildViewController:self.adsViewController];
        [self.adsView addSubview:self.adsViewController.view];
    } else {
        self.adsViewController.view.frame = self.adsView.bounds;
        [self.adsViewController.view setNeedsDisplay];
//        [self.adsViewController changeRows:1 columns:1];
    }
}

- (void) loadNewNextView:(BOOL)reload {
    if (/*reload &&*/ self.nnViewController != nil) {
        [self.nnViewController.view removeFromSuperview];
        [self.nnViewController removeFromParentViewController];
        self.nnViewController = nil;
    }

    if (self.nnViewController == nil) {
        self.nnViewController = [[DPNewNextViewController alloc] init];
        self.nnViewController.view.frame =self.nnView.bounds;
        [self addChildViewController: self.nnViewController];
        [self.nnView addSubview: self.nnViewController.view];
    } else {
        self.nnViewController.view.frame =self.nnView.bounds;
        [self.nnViewController.view setNeedsDisplay];
    }
}

- (void) loadMenuView:(BOOL)reload {
    if (/*reload && */self.mmViewController != nil) {
        [self.mmViewController.view removeFromSuperview];
        [self.mmViewController removeFromParentViewController];
        self.mmViewController = nil;
    }
    
    if (self.mmViewController == nil) {
        self.mmViewController = [[DPMenuViewController alloc] initWithRows:3
                                                                   columns:3
                                                                autoScroll:NO
                                                                 showPages:NO
                                                           scrollDirection:DPScrollDirectionHorizontal
                                                                 menulevel:0
                                                               initialPage:0
                                                                activeMenu:-1];
        self.mmViewController.view.frame = self.mmView.bounds;
        [self addChildViewController:self.mmViewController];
        [self.mmView addSubview:self.mmViewController.view];
    } else {
        self.mmViewController.view.frame = self.mmView.bounds;
       [self.mmViewController.view setNeedsDisplay];
    }
}

//==============================================================================
#pragma mark - nav bar button selection
//- (BOOL) showNavBar {
//    return self.navigationController != nil;
//}
//- (BOOL) showNavBarLanguages {
//    return YES;
//}
//- (BOOL) showNavBarAddToFav {
//    return NO;
//}
//- (BOOL) showNavBarSocial {
//    return NO;
//}
//- (BOOL) showNavBarInfo {
//    return YES;
//}
//==============================================================================


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.adsView = nil;
    self.adsViewController = nil;
    self.nnView = nil;
    self.nnViewController = nil;
    self.mmView = nil;
    self.mmViewController = nil;
    [super viewDidUnload];
}

- (void) dealloc {
    self.adsView = nil;
    self.adsViewController = nil;
    self.nnView = nil;
    self.nnViewController = nil;
    self.mmView = nil;
    self.mmViewController = nil;
}
@end
