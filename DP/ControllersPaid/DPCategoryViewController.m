//
//  DPCategoryViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCategoryViewController.h"
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

@implementation DPCategoryViewController {
    int initialMenuPage;
}

@synthesize category = _category;


- (id) initWithCategory:(int)ctgID andPage:(int)pg {
    if (self = [super init]) {
        _category = ctgID;
		initialMenuPage = pg;
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
    self.imgTitle.backgroundColor = [UIColor clearColor];
    self.imgTitle.contentMode = UIViewContentModeTop;
    
    CGRect lblframe = self.lblTitle.frame;
    lblframe.size.height = IS_IPAD ? 32 : 20;
    self.lblTitle.frame = lblframe;
    self.lblTitle.font = [UIFont systemFontOfSize: IS_IPAD ? 28.0f : 14.0f];
    
    [self fixTitleLabel];
}

- (void) fixTitleLabel {
    if (self.category == CTGID_EXCLUSIVE_DESIGNER || self.category == CTGID_EXCLUSIVE_ART) {
        self.lblTitle.text = nil;
        self.lblTitle.hidden = YES;
        self.imgTitle.hidden = NO;
        NSString *ctgName = self.category == CTGID_EXCLUSIVE_DESIGNER ? @"designer" : @"art";
        NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
        NSString *imgName = [NSString stringWithFormat:@"Background/logo_%@_%@.png", ctgName, orientation];
        self.imgTitle.image = [UIImage imageNamed:imgName];
    } else {
        self.imgTitle.hidden = YES;
        self.lblTitle.hidden = NO;
        NSString *ctgTitleKey = [NSString stringWithFormat:kMENU_TITLE_Fmt, self.category];
        self.lblTitle.text = DPLocalizedString(ctgTitleKey);
    }
}

- (void) doLocalize {
    [super doLocalize];

    [self fixTitleLabel];
    
    [self loadAdsView:YES];
    
    [self loadCategoryView:YES];
    
    if (self.mmViewController)
        //[self loadMenuView:YES];
        [self.mmViewController doLocalize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.ctgView = nil;
    self.adsView = nil;
    self.mmView = nil;
    
    self.imgTitle = nil;
    self.lblTitle = nil;
    self.actualCtgView = nil;
    
    self.adsViewController = nil;
    self.ctgViewController = nil;
    self.mmViewController = nil;
    [super viewDidUnload];
}

- (void) dealloc {
    self.ctgView = nil;
    self.adsView = nil;
    self.mmView = nil;
    
    self.imgTitle = nil;
    self.lblTitle = nil;
    self.actualCtgView = nil;
    
    self.adsViewController = nil;
    self.ctgViewController = nil;
    self.mmViewController = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.ctgViewController)
        [self.ctgViewController changeRows:self.ctgViewController.rowCount
                                   columns:self.ctgViewController.colCount
                           scrollDirection:self.ctgViewController.scrollDirection];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doLocalize];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_category]
                                                                                           forKey:@"menuCategory"]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void) doLayoutSubViews:(BOOL)fixtop {
    [self internlLayoutSubViews];
    
    [self loadAdsView:NO];
    [self loadCategoryView:NO];
    [self loadMenuView:NO];
}

- (void) internlLayoutSubViews {
    CGRect vf = self.view.frame;
    
    BOOL fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

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
    
    if (self.category == CTGID_EXCLUSIVE_DESIGNER || self.category == CTGID_EXCLUSIVE_ART) {
        self.lblTitle.frame = CGRectZero;
        self.imgTitle.frame = CGRectMake(0, self.category == CTGID_EXCLUSIVE_ART ? 8 : 4,
                                         self.ctgView.frame.size.width,
                                         120);
    } else {
        self.imgTitle.frame = CGRectZero;
        self.lblTitle.frame = CGRectMake(0, 0,
                                         self.ctgView.frame.size.width,
                                         IS_IPAD ? 32 : 20);
    }
    self.actualCtgView.frame = CGRectMake(0,
                                          self.lblTitle.frame.size.height,
                                          self.ctgView.frame.size.width,
                                          self.ctgView.frame.size.height - self.lblTitle.frame.size.height);
}

- (void) loadAdsView:(BOOL)reload {
    int groupNo = (_category == CTGID_EXCLUSIVE_ART || _category == CTGID_EXCLUSIVE_DESIGNER)
        ? BANNER_GROUP_EXCLUSIVE : BANNER_GROUP_COMMON_LVL1;
    BOOL grpChanged = self.adsViewController != nil && self.adsViewController.group != groupNo;
    
    int currPage = groupNo == BANNER_GROUP_EXCLUSIVE ? 0 : GET_ADS_COMMON_CURR_PAGE();

    if (reload || grpChanged) {
        if (self.adsViewController)
        {
            if (grpChanged)
                currPage = 0;
            else
                currPage = self.adsViewController.currentAdPage;
            SET_ADS_COMMON_CURR_PAGE(currPage);
            [self.adsViewController.view removeFromSuperview];
            [self.adsViewController removeFromParentViewController];
            self.adsViewController = nil;
        }
    }

    if (self.adsViewController == nil) {
        self.adsViewController = [[DPAdsViewController alloc] initWithGroup:groupNo initialPage:currPage];
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
        [self internlLayoutSubViews];
        [self fixTitleLabel];
        [self loadAdsView:NO];
        [self loadCategoryView:YES];
        [self updateMenuView];
    }
}

- (void) loadCategoryView:(BOOL)reload {
    if (self.category == 0)
        return;

    //if (reload || (self.ctgViewController && self.category != self.ctgViewController.category))
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

- (void) updateMenuView {
    if (self.category == 0) return;
    if (self.mmViewController == nil) return;
    [self.mmViewController updateHighlights:self.category];
}

- (void) loadMenuView:(BOOL)reload {
    if (self.category == 0) return;
    
    int rows = IS_PORTRAIT ? 1 : 3;
    int cols = IS_PORTRAIT ? 3 : 1;
    DPScrollDirection scrolldir = IS_PORTRAIT ? DPScrollDirectionHorizontal : DPScrollDirectionVertical;

    if (self.mmViewController != nil) {
        reload = (rows != self.mmViewController.rowCount ||
                  cols != self.mmViewController.colCount ||
                  scrolldir != self.mmViewController.scrollDirection);
        
    }
    
    if (reload && self.mmViewController != nil)
    {
        initialMenuPage = self.mmViewController.currentMenuPage;
        [self.mmViewController.view removeFromSuperview];
        [self.mmViewController removeFromParentViewController];
        self.mmViewController = nil;
    }
    
    if (self.mmViewController == nil) {
        self.mmViewController = [[DPMenuViewController alloc] initWithRows:rows
                                                                   columns:cols
                                                                autoScroll:NO
                                                                 showPages:NO
                                                           scrollDirection:scrolldir
                                                                 menulevel:1
                                                               initialPage:initialMenuPage
                                                                activeMenu:self.category];
        CGRect mmfrm = self.mmView.bounds;
        self.mmViewController.view.frame = mmfrm;
        [self addChildViewController:self.mmViewController];
        [self.mmView addSubview:self.mmViewController.view];
    }
    else {
        CGRect mmfrm = self.mmView.bounds;
        self.mmViewController.view.frame = mmfrm;
        [self.mmViewController changeRows:rows columns:cols scrollDirection:scrolldir];
    }
}

@end
