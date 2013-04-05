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
#import "DPAppHelper.h"
#import "DPAnimatedCategoriesView.h"
#import "DPAdsViewController.h"


@interface DPCategoryViewController ()

@property (strong, nonatomic) DPAdsViewController *adsViewController;
@property (strong, nonatomic) DPCtgScrollViewController *mmViewController;
@property (strong, nonatomic) NSArray *categories;

@end

@implementation DPCategoryViewController {
    bool isPortrait;
    int category;
}

//@synthesize ctgView, adsView, mmView, lblTitle;

//@synthesize mmViewController;


- (id) initWithCategory:(int)ctgID {
    if (self = [super init]) {
        category = ctgID;
        self.categories = [[DPAppHelper sharedInstance] getSubCategoriesOf:ctgID];
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
    self.adsView.backgroundColor = [UIColor clearColor];
    self.ctgView.backgroundColor = [UIColor clearColor];
    self.mmView.backgroundColor = [UIColor clearColor];
    NSString *ctgTitleKey = [NSString stringWithFormat:kMENU_TITLE_Fmt, category];
    self.lblTitle.text = DPLocalizedString(ctgTitleKey);
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
//    CGRect svf = self.view.superview.frame;
    
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
    
    [self loadAdsView];
    [self loadCategoryView];
    [self loadMenuView];
}

- (void) loadAdsView {
    self.adsView.backgroundColor = [UIColor orangeColor];
    if (self.adsView.subviews.count == 0)
    {
        self.adsViewController = [[DPAdsViewController alloc] initWithGroup:1];
        [self addChildViewController:self.adsViewController];
        [self.adsView addSubview:self.adsViewController.view];
    }
    // else pending ???
}


- (void) loadCategoryView {
    DPAnimatedCategoriesView *acv;
    CGRect frm = self.ctgView.bounds;
    if (CGRectIsEmpty(frm)) return;
    
    frm = CGRectInset(frm, 0, 0);
    if (self.ctgView.subviews.count == 0) {
        acv = [[DPAnimatedCategoriesView alloc] initWithFrame:frm
                                                   categories:self.categories];
        [self.ctgView addSubview: acv];
    } else {
        for (id v in self.ctgView.subviews) {
            if ([v isKindOfClass:[DPAnimatedCategoriesView class]])
                 acv = v;
            if (acv) break;
        }
        
        if (acv) {
            acv.frame = self.ctgView.bounds;
            //[acv layoutForOrientation:INTERFACE_ORIENTATION fixtop:NO];
        }
    }
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
        DPAppHelper *apphelper = [DPAppHelper sharedInstance];
        NSArray *content = [apphelper paidMenuOfCategory:-1 lang:apphelper.currentLang];
        
        if (isPortrait)
            self.mmViewController = [[DPCtgScrollViewController alloc]
                                initWithContent:content rows:1 columns:3
                                autoScroll:NO];
        else
            self.mmViewController = [[DPCtgScrollViewController alloc]
                                initWithContent:content rows:3 columns:1
                                autoScroll:NO];
        
        [self addChildViewController: self.mmViewController];
        [bcv addSubview: self.mmViewController.view];
    } else {
        if (isPortrait)
            [self.mmViewController changeRows:1 columns:3];
        else
            [self.mmViewController changeRows:3 columns:1];
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
