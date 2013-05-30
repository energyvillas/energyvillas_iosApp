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
#import "DPAnimatedCardsView.h"
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

@implementation DPCategoryViewController

@synthesize category = _category;
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
        _category = ctgID;
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
    
    CGRect lblframe = self.lblTitle.frame;
    lblframe.size.height = IS_IPAD ? 32 : 20;
    self.lblTitle.frame = lblframe;

    self.lblTitle.font = [UIFont systemFontOfSize: IS_IPAD ? 28.0f : 14.0f];

    [self doLocalize];
}

- (void) fixTitleLabel {
    NSString *ctgTitleKey = [NSString stringWithFormat:kMENU_TITLE_Fmt, self.category];
    self.lblTitle.text = DPLocalizedString(ctgTitleKey);
}
- (void) doLocalize {
    [super doLocalize];

    [self fixTitleLabel];
    
    [self loadAdsView:YES];
    
    [self loadCategoryView:YES];
    
    [self loadMenuView:YES];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_category]
                                                                                           forKey:@"menuCategory"]];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
//    CGRect svf = self.view.superview.frame;
//    fixtop = NO;
//    int h = IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y;
//    int w = vf.size.width;
//    int top = fixtop ? vf.origin.y : 0;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

//    int h = vf.size.height - vf.origin.y;
//    int w = vf.size.width;
//    int top = fixtop ? vf.origin.y : 0;
    
    NSLog(@"############## DPCategoryView - h = %d, top = %d", h, top);

    // iphone sizes
    int H_ADS = 60;
    int H_MENU = 92;//80;
    int HL_ADS = 60;
    int WL_MENU= 120;
    
    // ipad sizes
    int PAD_H_ADS = 120;
    int PAD_H_MENU = 223;
    int PAD_HL_ADS = 120;
    int PAD_WL_MENU= 250;
    
    if (IS_IPHONE || IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            self.adsView.frame = CGRectMake(0, top, w, H_ADS);
            
            self.ctgView.frame = CGRectMake(0, top + H_ADS, w, h - H_ADS - H_MENU);

            self.mmView.frame = CGRectMake(0, top + h - H_MENU, w, H_MENU);
        } else {
            self.adsView.frame = CGRectMake(0, top, w - WL_MENU, HL_ADS);
            
            self.ctgView.frame = CGRectMake(0, top + HL_ADS, w - WL_MENU, h - HL_ADS);
            
            self.mmView.frame = CGRectMake(w - WL_MENU, top, WL_MENU, h);
        }
    } else /* IF (IS_IPAD) */{
        if (IS_PORTRAIT) {
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
    
    [self loadAdsView:NO];
    [self loadCategoryView:NO];
    [self loadMenuView:NO];
}

- (void) loadAdsView:(BOOL)reload {
    int groupNo = (_category == CTGID_EXCLUSIVE_ART || _category == CTGID_EXCLUSIVE_DESIGNER)
        ? BANNER_GROUP_LEVEL_1_EXCLUSIVE : BANNER_GROUP_LEVEL_1_NORMAL;
    BOOL grpChanged = self.adsViewController != nil && self.adsViewController.group != groupNo;

    if (reload || grpChanged) {
        if (self.adsViewController)
        {
            [self.adsViewController.view removeFromSuperview];
            [self.adsViewController removeFromParentViewController];
            self.adsViewController = nil;
        }
    }

    if (self.adsViewController == nil) {
        self.adsViewController = [[DPAdsViewController alloc] initWithGroup:groupNo];
        self.adsViewController.view.frame = self.adsView.bounds;
        [self addChildViewController:self.adsViewController];
        [self.adsView addSubview:self.adsViewController.view];
    } else {
        self.adsViewController.view.frame = self.adsView.bounds;
        [self.adsViewController.view setNeedsDisplay];
    }
}

- (void) showCategory:(int)ctgID {
    if (_category != ctgID) {
        _category = ctgID;
        [self fixTitleLabel];
        [self loadAdsView:NO];
        [self loadCategoryView:YES];
    }
}

- (void) loadCategoryView:(BOOL)reload {
    if (self.category == 0)
        return;

//    if (reload)
    {
        if (self.ctgViewController)
        {
            [self.ctgViewController.view removeFromSuperview];
            [self.ctgViewController removeFromParentViewController];
            self.ctgViewController = nil;
        }
    }
    
    if (self.ctgViewController == nil) {
        self.ctgViewController = [[DPAnimatedScrollViewController alloc] initWithCategory:self.category
                                                                                   isLeaf:NO
                                                                                    frame:self.actualCtgView.bounds];
        
        [self addChildViewController:self.ctgViewController];
        [self.actualCtgView addSubview:self.ctgViewController.view];
    } else {
        [self.ctgViewController changeFrame:self.actualCtgView.bounds];
        [self.ctgViewController changeRows:1 columns:1];
    }
}

- (void) loadMenuView:(BOOL)reload {
    int rows = IS_PORTRAIT ? 1 : 3;
    int cols = IS_PORTRAIT ? 3 : 1;
    DPScrollDirection scrolldir = IS_PORTRAIT ? DPScrollDirectionHorizontal : DPScrollDirectionVertical;

    if (self.mmViewController != nil) {
        [self.mmViewController.view removeFromSuperview];
        [self.mmViewController removeFromParentViewController];
        self.mmViewController = nil;
    }
    
    self.mmViewController = [[DPMenuViewController alloc] initWithRows:rows
                                                               columns:cols
                                                            autoScroll:NO
                                                             showPages:NO
                                                       scrollDirection:scrolldir
                                                             menulevel:1];
    CGRect mmfrm = self.mmView.bounds;
    self.mmViewController.view.frame = mmfrm;
    [self addChildViewController:self.mmViewController];
    [self.mmView addSubview:self.mmViewController.view];

//    if (self.mmView.subviews.count == 0)
//    {
//        self.mmViewController = [[DPMenuViewController alloc] initWithRows:rows
//                                                                   columns:cols
//                                                                autoScroll:NO
//                                                                 showPages:NO
//                                                           scrollDirection:scrolldir];
//        
//        [self addChildViewController:self.mmViewController];
//        [self.mmView addSubview:self.mmViewController.view];
//        self.mmViewController.view.frame = self.mmView.bounds;
//    }
//    else {
//        self.mmViewController.view.frame = self.mmView.bounds;
//        [self.mmViewController changeRows:rows
//                                  columns:cols
//                          scrollDirection:scrolldir];
//    }
}

@end
