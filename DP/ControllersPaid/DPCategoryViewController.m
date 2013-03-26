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
    NSString *ctgTitleKey = [NSString stringWithFormat:@"MENU_TITLE_%i", category];
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
    int H_MENU = 80;
    int HL_ADS = 44;
    int WL_MENU= 120;
    
    // ipad sizes
    int PAD_H_ADS = 44;
    int PAD_H_MENU = 80;
    int PAD_HL_ADS = 44;
    int PAD_WL_MENU= 120;
    
    
    // ph : 44, 100, 267
    // lh : 44, 207 (x2),
    // lw : , 160, 320,
    
    bool isPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    
    if (isPhone) {
        if (isPortrait) {
            self.ctgView.frame = CGRectMake(0, 0, w, h - H_ADS - H_MENU);
            
            self.adsView.frame = CGRectMake(0, h - H_ADS - H_MENU, w, H_ADS);
            
            self.mmView.frame = CGRectMake(0, h - H_MENU, w, H_MENU);
        } else {
            self.ctgView.frame = CGRectMake(0, 0, w - WL_MENU, h - HL_ADS);
            
            self.adsView.frame = CGRectMake(0, h - HL_ADS, w - WL_MENU, HL_ADS);
            
            self.mmView.frame = CGRectMake(w - WL_MENU, 0, WL_MENU, h);
        }
    } else {
        if (isPortrait) {
            self.ctgView.frame = CGRectMake(0, 0, w, h - PAD_H_ADS - PAD_H_MENU);
            
            self.adsView.frame = CGRectMake(0, h - PAD_H_ADS - PAD_H_MENU, w, PAD_H_ADS);
            
            self.mmView.frame = CGRectMake(0, h - PAD_H_MENU, w, PAD_H_MENU);
        } else {
            self.ctgView.frame = CGRectMake(0, 0, w - PAD_WL_MENU, h - PAD_HL_ADS);
            
            self.adsView.frame = CGRectMake(0, h - PAD_HL_ADS, w - PAD_WL_MENU, PAD_HL_ADS);
            
            self.mmView.frame = CGRectMake(w - PAD_WL_MENU, 0, PAD_WL_MENU, h);
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
