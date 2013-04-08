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
#import "DPMenuViewController.h"
#import "DPAnimatedScrollViewController.h"

#import "DPCategoryLoader.h"
#import "Category.h"


@interface DPCategoryViewController ()

@property (strong, nonatomic) DPAdsViewController *adsViewController;
@property (strong, nonatomic) DPAnimatedScrollViewController *ctgViewController;
@property (strong, nonatomic) DPMenuViewController *mmViewController;

@end

@implementation DPCategoryViewController {
    bool isPortrait;
    int category;
}

////////////////////////

//- (void) fixlabel {
//    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Hello. That is a test attributed string."];
//    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,5)];
//    [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10,7)];
//    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] range:NSMakeRange(20, 10)];
//    self.lblTitle.attributedText = str;
//}
//////////////////////////


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
    self.adsView.backgroundColor = [UIColor clearColor];
    self.ctgView.backgroundColor = [UIColor clearColor];
    self.mmView.backgroundColor = [UIColor clearColor];
    NSString *ctgTitleKey = [NSString stringWithFormat:kMENU_TITLE_Fmt, category];
    self.lblTitle.text = DPLocalizedString(ctgTitleKey);
    //[self fixlabel];
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
    [self setActualCtgView:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.ctgViewController)
        [self.ctgViewController changeRows:self.ctgViewController.rowCount
                                   columns:self.ctgViewController.colCount
                           scrollDirection:self.ctgViewController.scrollDirection];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    
    self.lblTitle.frame = CGRectMake(0, 0,
                                     self.ctgView.frame.size.width,
                                     self.lblTitle.frame.size.height);
    self.actualCtgView.frame = CGRectMake(0,
                                          self.lblTitle.frame.size.height,
                                          self.ctgView.frame.size.width,
                                          self.ctgView.frame.size.height - self.lblTitle.frame.size.height);
    
    [self loadAdsView];
    [self loadCategoryView];
    [self loadMenuView];
}

- (void) loadAdsView {
    if (self.adsView.subviews.count == 0)
    {
        self.adsViewController = [[DPAdsViewController alloc] initWithGroup:1];
        [self addChildViewController:self.adsViewController];
        [self.adsView addSubview:self.adsViewController.view];
    }
    else
        [self.adsViewController layoutForOrientation:INTERFACE_ORIENTATION fixtop:NO];
}

- (void) loadCategoryView {    
    if (category == 0)
        return;
    
    if (self.actualCtgView.subviews.count == 0)
    {
        self.ctgViewController = [[DPAnimatedScrollViewController alloc] initWithCategory:category isLeaf:NO];
        
        //[[DPtestanimViewController alloc] initWithCategory:category isLeaf:NO];
        
        [self addChildViewController:self.ctgViewController];
        [self.actualCtgView addSubview:self.ctgViewController.view];
    }
    else
        [self.ctgViewController changeRows:1 columns:1];
}

- (void) loadMenuView {
    int rows = isPortrait ? 1 : 3;
    int cols = isPortrait ? 3 : 1;
    DPScrollDirection scrolldir = isPortrait ? DPScrollDirectionHorizontal : DPScrollDirectionVertical;
    
    if (self.mmView.subviews.count == 0)
    {
        self.mmViewController = [[DPMenuViewController alloc] initWithRows:rows
                                                                   columns:cols
                                                                autoScroll:NO
                                                                 showPages:NO
                                                           scrollDirection:scrolldir];
        
        [self addChildViewController:self.mmViewController];
        [self.mmView addSubview:self.mmViewController.view];
    }
    else
        [self.mmViewController changeRows:rows
                                  columns:cols
                          scrollDirection:scrolldir];

////////
//    if (self.mmViewController) {
//        [self.mmView removeFromSuperview];
//        [self.mmViewController removeFromParentViewController];
//    }
//    
//    self.mmViewController = [[DPMenuViewController alloc] initWithRows:isPortrait ? 1 : 3
//                                                               columns:isPortrait ? 3 : 1
//                                                            autoScroll:NO
//                                                             showPages:NO
//                                                       scrollDirection:isPortrait ? DPScrollDirectionHorizontal : DPScrollDirectionVertical];
//    
//    [self addChildViewController:self.mmViewController];
//    [self.mmView addSubview:self.mmViewController.view];
}

@end
