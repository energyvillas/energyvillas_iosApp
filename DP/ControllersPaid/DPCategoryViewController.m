//
//  DPCategoryViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCategoryViewController.h"
#import "../Controllers/DPCtgScrollViewController.h"
#import "../Classes/DPImageInfo.h"
#import "../External/OpenFlow/UIImageExtras.h"
#import "DPConstants.h"

@interface DPCategoryViewController ()

@property (strong, nonatomic) DPCtgScrollViewController *mmViewController;

@end

@implementation DPCategoryViewController {
    bool isPortrait;
    int category;
}

@synthesize ctgView, adsView, mmView, lblTitle;

@synthesize mmViewController;


- (id) initWithCategory:(int)ctgID {
    if (self = [super init]) {
        category = ctgID;
    }
    
    return self;
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
    NSString *ctgTitleKey = [NSString stringWithFormat:MENU_TITLE_Fmt, category];
    lblTitle.text = NSLocalizedString(ctgTitleKey, nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCtgView:nil];
    [self setAdsView:nil];
    [self setMmView:nil];
    [self setLblTitle:nil];
    [super viewDidUnload];
}

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation fixtop:(BOOL)fixtop {
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
    
    CGRect vf = self.view.frame;
    CGRect svf = self.view.superview.frame;
    
    int h = isPortrait ? vf.size.height : vf.size.height - vf.origin.y;
    int w = vf.size.width;
    int top = fixtop ? vf.origin.y : 0;
    
    // iphone sizes
    int H_ADS = 60;
    int H_MENU = 62;//80;
    int HL_ADS = 60;
    int WL_MENU= 120;
    
    // ipad sizes
    int PAD_H_ADS = 120;
    int PAD_H_MENU = 223;
    int PAD_HL_ADS = 120;
    int PAD_WL_MENU= 250;
    
    if (IS_IPHONE || IS_IPHONE_5) {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, top, w, H_ADS);
            
            self.ctgView.frame = CGRectMake(0, top + H_ADS, w, h - H_ADS - H_MENU);
            
            self.mmView.frame = CGRectMake(0, top + h - H_MENU, w, H_MENU);
        } else {
            self.adsView.frame = CGRectMake(0, top, w - WL_MENU, HL_ADS);
            
            self.ctgView.frame = CGRectMake(0, top + HL_ADS, w - WL_MENU, h - HL_ADS);
            
            self.mmView.frame = CGRectMake(w - WL_MENU, top, WL_MENU, h);
        }
    } else /* IF (IS_IPAD) */{
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, top, w, PAD_H_ADS);
            
            self.ctgView.frame = CGRectMake(0, top + PAD_H_ADS, w, h - PAD_H_ADS - PAD_H_MENU);
            
            self.mmView.frame = CGRectMake(0, top + h - PAD_H_MENU, w, PAD_H_MENU);
        } else {
            self.adsView.frame = CGRectMake(0, top, w - PAD_WL_MENU, PAD_HL_ADS);
            
            self.ctgView.frame = CGRectMake(0, top + PAD_HL_ADS, w - PAD_WL_MENU, h - PAD_HL_ADS);
            
            self.mmView.frame = CGRectMake(w - PAD_WL_MENU, top, PAD_WL_MENU, h);
        }
    }
    
    [self loadCategoryView];
    [self loadMenuView];
}

- (void) loadCategoryView {
/*
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
*/
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
        
        if (isPortrait)
            mmViewController = [[DPCtgScrollViewController alloc]
                                initWithContent:content rows:1 columns:3];
        else
            mmViewController = [[DPCtgScrollViewController alloc]
                                initWithContent:content rows:3 columns:1];
        
        content = nil;
        
        [self addChildViewController: mmViewController];
        [bcv addSubview: mmViewController.view];
    } else {
        if (isPortrait)
            [mmViewController changeRows:1 columns:3];
        else
            [mmViewController changeRows:3 columns:1];
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


@end
