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
#import "../Controllers/DPCtgScrollViewController.h"
#import "../Classes/DPImageInfo.h"
#import "../External/OpenFlow/UIImageExtras.h"


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

@property (strong, nonatomic) DPCtgScrollViewController *nnViewController;
@property (strong, nonatomic) DPCtgScrollViewController *mmViewController;

@end

@implementation DPPaidRootViewController {
    //int currentIndex;
    bool isPortrait;
}

@synthesize whoViewController, buyViewController, callViewController, moreViewController;
@synthesize nnViewController, mmViewController;


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
            
            self.mmView.frame = CGRectMake(0, H_ADS + H_NEW_NEXT,
                                           w, h - H_ADS - H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(0, 0, w, HL_ADS);
            
            self.nnView.frame = CGRectMake(0, HL_ADS, WL_NEW_NEXT, h - HL_ADS);
            
            self.mmView.frame = CGRectMake(WL_NEW_NEXT, HL_ADS,
                                           w - WL_NEW_NEXT, h - HL_ADS);
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
    
    [self loadNewNextView];
    [self loadMenuView];
}

- (void) loadNewNextView {
    UIView *bcv = self.nnView;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)",
          bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);
    
    if (bcv.subviews.count == 0) {
        NSMutableArray *content = [[NSMutableArray alloc] init];
        for (int i = 0; i < 2; i++)
            [content addObject:[[DPImageInfo alloc]
                                initWithName:[NSString stringWithFormat:@"%d.jpg", i+20]
                                image:[self imageForIndex:i+20 withFrame:nil]]];
        
        if (isPortrait)
            nnViewController = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:1 columns:2];
        else
            nnViewController = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:2 columns:1];
        
        content = nil;
        
        [self addChildViewController: nnViewController];
        [bcv addSubview: nnViewController.view];
    } else {
        if (isPortrait) {
            [nnViewController changeRows:1 columns:2];
        } else {
            [nnViewController changeRows:2 columns:1];
        }
        
    }
}

- (void) loadMenuView {
    UIView *bcv = self.mmView;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)",
          bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);

    if (bcv.subviews.count == 0) {
        NSMutableArray *content = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++)
            [content addObject:[[DPImageInfo alloc]
                                initWithName:[NSString stringWithFormat:@"%d.jpg", i+11]
                                image:[self imageForIndex:i+11 withFrame:nil]]];
        
        //        if (isPortrait)
        mmViewController = [[DPCtgScrollViewController alloc]
                 initWithContent:content rows:3 columns:3];
        //        else
        //            detvc = [[DPCtgScrollViewController alloc]
        //                     initWithContent:content rows:3 columns:3];
        
        content = nil;
        
        [self addChildViewController: mmViewController];
        [bcv addSubview: mmViewController.view];
    } else {
        //        if (isPortrait) {
        [mmViewController changeRows:3 columns:3];
        //        } else {
        //            [detvc changeRows:1 columns:3];
        //        }
        
    }
}

- (UIImage *) imageForIndex:(int) indx withFrame:(CGRect *) targetFrame {
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indx]];
    
    if (targetFrame == nil) return img;
    
    float coeff = 1.0;
    float vh = (*targetFrame).size.height;
    float vw = (*targetFrame).size.width;
    float ih = img.size.height;
    float iw = img.size.width;
    if (iw/vw > ih/vh)
        coeff = (vw / iw);
    else
        coeff = (vh / ih);
    
    if (coeff > 1.5) coeff = 1.5;
    
    ih = ih * coeff;
    iw = iw * coeff;
    
    NSLog(@"scaling image %d.jpg from (%f, %f) => (%f, %f)", indx, img.size.width, img.size.height, iw, ih);
    return [img rescaleImageToSize:CGSizeMake(iw, ih)];
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
