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


@interface DPPaidRootViewController ()

@end

@implementation DPPaidRootViewController {
    //int currentIndex;
    bool isPortrait;
}


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
        
            
    
    //self.view.frame = CGRectMake(0, 0, w, h);
/*
    int toolbarHeight = self.toolbar.frame.size.height;
    int topHeight = h - toolbarHeight - BOTTOM_HEIGHT;
    self.topView.frame = CGRectMake(0, 0, w, topHeight);
    self.toolbar.frame = CGRectMake(0, topHeight, w, toolbarHeight);
    self.bottomView.frame = CGRectMake(0, topHeight + toolbarHeight, w, BOTTOM_HEIGHT);
*/
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
