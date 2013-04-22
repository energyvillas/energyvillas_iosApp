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


@interface DPPaidRootViewController ()


@property (strong, nonatomic) DPAdsViewController *adsViewController;
@property (strong, nonatomic) DPNewNextViewController *nnViewController;
@property (strong, nonatomic) DPMenuViewController *mmViewController;

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

- (void) doLocalize {
    [super doLocalize];
//    self.bbiMore.title = DPLocalizedString(kbbiMore_Title);
//    self.bbiBuy.title = DPLocalizedString(kbbiBuy_Title);
    
    if (self.adsView.subviews.count > 0)
        [self loadAdsView];
 
    if (self.nnView.subviews.count > 0)
        [self loadNewNextView];
    
    if (self.mmView.subviews.count > 0)
        [self loadMenuView];
}


- (void) doLayoutSubViews:(BOOL)fixtop {    
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

//    int h = vf.size.height - vf.origin.y;
//    int w = vf.size.width;
//    int top = fixtop ? vf.origin.y : 0;
    
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
    
    [self loadAdsView];
    [self loadNewNextView];
    [self loadMenuView];
}

- (void) loadAdsView {
    if (self.adsView.subviews.count == 0)
    {
        self.adsViewController = [[DPAdsViewController alloc] initWithGroup:1];
        //self.adsViewController.view.frame = self.adsView.bounds;
        [self addChildViewController:self.adsViewController];
        [self.adsView addSubview:self.adsViewController.view];
    }
    NSLogFrame(@"adsView.frame", self.adsView.frame);
    NSLogFrame(@"adsView.bounds", self.adsView.bounds);
    self.adsViewController.view.frame = self.adsView.bounds;
}

- (void) loadNewNextView {
//    NSLog(@"enter loadNewNextView");
//    if (self.nnViewController != nil) {
//        [self.nnViewController.view removeFromSuperview];
//        [self.nnViewController removeFromParentViewController];
//        self.nnViewController = nil;
//        NSLog(@"cleaned new-next");
//    }
//    
//    NSLog(@"creating new-next");
//    self.nnViewController = [[DPNewNextViewController alloc] init];
//    self.nnViewController.view.frame =self.nnView.bounds;
//    [self addChildViewController: self.nnViewController];
//    [self.nnView addSubview: self.nnViewController.view];
//    NSLog(@"exit loadNewNextView");

    if (self.nnViewController == nil) {
        NSLog(@"creating new-next");
        self.nnViewController = [[DPNewNextViewController alloc] init];
        self.nnViewController.view.frame =self.nnView.bounds;
        [self addChildViewController: self.nnViewController];
        [self.nnView addSubview: self.nnViewController.view];
    } else {
        self.nnViewController.view.frame =self.nnView.bounds;
        [self.nnViewController refresh];
    }
}

- (void) loadMenuView {
    NSLogFrame(@"mmView.frame", self.mmView.frame);
    NSLogFrame(@"mmView.bounds", self.mmView.bounds);
    
    if (self.mmViewController != nil) {
        [self.mmViewController.view removeFromSuperview];
        [self.mmViewController removeFromParentViewController];
        self.mmViewController = nil;
    }
    
    self.mmViewController = [[DPMenuViewController alloc] initWithRows:3 columns:3 autoScroll:NO];
    self.mmViewController.view.frame = self.mmView.bounds;
    [self addChildViewController:self.mmViewController];
    [self.mmView addSubview:self.mmViewController.view];
}

//- (UIImage *) imageForIndex:(int) indx withFrame:(CGRect *) targetFrame {
//    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indx]];
//    
//    if (targetFrame == nil) return img;
//    
//    float coeff = 1.0;
//    float vh = (*targetFrame).size.height;
//    float vw = (*targetFrame).size.width;
//    float ih = img.size.height;
//    float iw = img.size.width;
//    if (iw/vw > ih/vh)
//        coeff = (vw / iw);
//    else
//        coeff = (vh / ih);
//    
//    if (coeff > 1.5) coeff = 1.5;
//    
//    ih = ih * coeff;
//    iw = iw * coeff;
//    
//    NSLog(@"scaling image %d.jpg from (%f, %f) => (%f, %f)", indx, img.size.width, img.size.height, iw, ih);
//    return [img rescaleImageToSize:CGSizeMake(iw, ih)];
//}


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
- (BOOL) showNavBarSocial {
    return YES;
}
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
    [self setAdsView:nil];
    [self setNnView:nil];
    [self setMmView:nil];
    [super viewDidUnload];
}
@end
