//
//  DPRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPRootViewController.h"
#import "../External/OpenFlow/UIImageExtras.h"
#import "DPCategoriesViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "DPConstants.h"
#import "DPVimeoPlayerViewController.h"
#import "DPAppHelper.h"
#import "DPMainViewController.h"
#import "DPBuyViewController.h"
#import "Article.h"
#import "DPCategoryLoader.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DPCarouselViewController.h"
#import "DPFacebookViewController.h"
#import <Twitter/Twitter.h>
#import "DPIAPHelper.h"
#import "DPFavoritesViewController.h"
#import "DPHtmlContentViewController.h"



@interface DPRootViewController () 

@property (strong, nonatomic) NSMutableDictionary *coverFlowDict;
@property (strong, nonatomic) DPBuyViewController *buyController;

@end



@implementation DPRootViewController {
    BOOL showingMore;
}

- (id) init {
    self = [super init];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    self.topView = nil;
    self.toolbar = nil;
    
    self.spacingLeft = nil;
    
    self.bbiFavs = nil;
    self.bbiInfo = nil;
    
    self.spacingInfoMore = nil;
    
    self.bbiMore = nil;
    self.bbiBuy = nil;
    
    self.bottomView = nil;

    self.coverFlowDict = nil;
    self.buyController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self doLocalize];
    [self.bbiFavs setAction:@selector(doFavs:)];
    [self.bbiInfo setAction:@selector(doInfo:)];
    [self.bbiMore setAction:@selector(doMore:)];
    [self.bbiBuy setAction:@selector(doBuy:)];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fixToolbarSpacing];
    
    [self doLocalize];
}

-(void) fixToolbarSpacing {
    self.spacingLeft.width = IS_PORTRAIT ? (IS_IPAD ? 70 : 2) : (IS_IPAD ? 75 : 2);// (IS_IPHONE ? 8 : 8));
    self.spacingInfoMore.width = IS_PORTRAIT ? (IS_IPAD ? 160 : (IS_IPHONE ? 10 : 12)) : (IS_IPAD ? 285 : (IS_IPHONE ? 90 : 134));
}
- (void) doLocalize {
    [super doLocalize];
    self.bbiMore.title = showingMore ? DPLocalizedString(kbbiMoreBack_Title) : DPLocalizedString(kbbiMore_Title);
    self.bbiBuy.title = DPLocalizedString(kbbiBuy_Title);
    
//    if (self.bottomView.subviews.count > 0) {
        [self loadDetailView:YES];
        [self loadOpenFlow:YES];
//    }
}

- (void) showBuyDialog:(int)ctgId {
    DPIAPHelper *iap = [DPIAPHelper sharedInstance];
    if (![iap canMakePurchases])
        showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), @"Cannot make purchase at the moment. Please try later!");
    else {
        if (iap.product == nil)
            showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), @"No product found!Try again later!");
        else
            [self showBuyDialog:ctgId product:iap.product];
    }
}

- (void) showBuyDialog:(int)ctgId product:(SKProduct *)aProduct {
    [[DPAppHelper sharedInstance] playSoundBloodSplatOnWall];
    if (IS_IPAD)
        [self showBuyDialog_iPads:ctgId product:aProduct];
    else
        [self showBuyDialog_iPhones:ctgId product:aProduct];
}

- (void) showBuyDialog_iPads:(int)ctgId product:(SKProduct *)aProduct {    
    self.buyController = [[DPBuyViewController alloc] initWithCategoryId:ctgId
                                                                 product:aProduct
                                                              completion:^{
                                                                  self.view.userInteractionEnabled = YES;
                                                                  self.buyController = nil;
                                                              }];
    
    self.view.userInteractionEnabled = NO;
    self.buyController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:self.buyController animated:YES completion:nil];
    
    CGRect svfrm = [self.buyController calcFrame];
    self.buyController.view.superview.backgroundColor = [UIColor clearColor];
    if (IS_PORTRAIT)
        self.buyController.view.superview.frame = CGRectOffset(svfrm, 0, 170);
    else
        self.buyController.view.superview.frame = CGRectOffset(svfrm, 0, 180);
}

- (void) showBuyDialog_iPhones:(int)ctgId product:(SKProduct *)aProduct {
    id del = self.navigationController.delegate;
    DPMainViewController *main = del;
    
    DPBuyViewController *buyVC = [[DPBuyViewController alloc] initWithCategoryId:ctgId
                                                                         product:aProduct
                                                                      completion:^{
                                                                          self.view.userInteractionEnabled = YES;
                                                                          self.buyController = nil;
                                                                      }];

    self.view.userInteractionEnabled = NO;

    [main addChildViewController:buyVC];
    [main.view addSubview:buyVC.view];
}

- (void) doFavs:(id) sender {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    if ([[apphelper favoriteArticles] count] > 0) {
        DPFavoritesViewController *favs = [[DPFavoritesViewController alloc] init];
        [self.navigationController pushViewController:favs animated:YES];
        [apphelper playSoundWoosh];
    }
}

- (void) doInfo:(id) sender {
    DPHtmlContentViewController *vc = [[DPHtmlContentViewController alloc] initWithCategory:CTGID_INFO
                                                                                       lang:CURRENT_LANG];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) doBuy:(id) sender {
    [self showBuyDialog:CTGID_GENERAL_BUY_DLG];
}

- (void) doMore:(id) sender {
    // do the more stuff here
    showingMore = !showingMore;
        
    self.bbiMore.title = showingMore ? DPLocalizedString(kbbiMoreBack_Title) : DPLocalizedString(kbbiMore_Title);

    self.bbiMore.tintColor = showingMore ? [UIColor redColor] : [UIColor blackColor];
    
    [self loadOpenFlow:YES];
}

//==============================================================================
//==============================================================================
//==============================================================================

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

    int toolbarHeight = self.toolbar.frame.size.height;

    int BOTTOM_HEIGHT;
    if (IS_IPHONE)
        BOTTOM_HEIGHT = (IS_PORTRAIT) ? 170 : 64;
    else if (IS_IPHONE_5)
        BOTTOM_HEIGHT = (IS_PORTRAIT) ? 170 : 75;
    else // if (IS_IPAD)
        BOTTOM_HEIGHT = (IS_PORTRAIT) ? 408 : 136;;
    
    // adjust for pagecontrol
    BOTTOM_HEIGHT = BOTTOM_HEIGHT + PAGE_CONTROL_HEIGHT;

    int topHeight = h - toolbarHeight - BOTTOM_HEIGHT;
    
    self.topView.frame = CGRectMake(0, top, w, topHeight);
    
    self.toolbar.frame = CGRectMake(0, top + topHeight,
                                    w, toolbarHeight);
    
    self.bottomView.frame = CGRectMake(0, top + topHeight + toolbarHeight,
                                       w, BOTTOM_HEIGHT);
    
    // this is a fix for when returning from vimeo player in landscape
    CGRect nbf = self.navigationController.navigationBar.frame;
    nbf.size.height = 44;
    self.navigationController.navigationBar.frame = nbf;
    //
    
    [self loadOpenFlow:NO];
    [self loadDetailView:NO];
    
    [self fixToolbarSpacing];
}

- (void) loadDetailView:(BOOL)reload{
    UIView *bcv = self.bottomView;

    DPCategoriesViewController *detvc;
    for (int i = 0; i < self.childViewControllers.count; i++)
        if ([self.childViewControllers[i] isKindOfClass:[DPCategoriesViewController class]]) {
            detvc = (DPCategoriesViewController *)self.childViewControllers[i];
            if (reload) {
                [detvc.view removeFromSuperview];
                [detvc removeFromParentViewController];
                detvc = nil;
            }
            break;
        }
    
    [self.bottomView setNeedsDisplay];

    if (detvc == nil) {
        DPAppHelper *apphelper = [DPAppHelper sharedInstance];
        if (IS_PORTRAIT)
            detvc = [[DPCategoriesViewController alloc] initWithCategory:-1
                                                                    lang:apphelper.currentLang
                                                           localResource:@"free-details.plist"
                                                                    rows:2
                                                                 columns:2
                                                              autoScroll:NO
                                                                  parent:self];
        else
            detvc = [[DPCategoriesViewController alloc] initWithCategory:-1
                                                                    lang:apphelper.currentLang
                                                           localResource:@"free-details.plist"
                                                                    rows:1
                                                                 columns:4
                                                              autoScroll:NO
                                                                  parent:self];
        
        detvc.view.frame = self.bottomView.bounds;
        [self addChildViewController: detvc];
        [bcv addSubview: detvc.view];
    } else {
        detvc.view.frame = self.bottomView.bounds;
        if (IS_PORTRAIT)
            [detvc changeRows:2 columns:2];
        else
            [detvc changeRows:1 columns:4];
    }
    
    detvc = nil;
}

-(int) carouselCategory {
    return showingMore ? CTGID_CAROUSEL_MORE : CTGID_CAROUSEL;
}

- (void) loadOpenFlow:(BOOL)reload {
    //self.topView.backgroundColor = [UIColor yellowColor];
    
    DPCarouselViewController *carousel = nil;
    int currImgIndex = 0;
    for (int i = 0; i < self.childViewControllers.count; i++)
        if ([self.childViewControllers[i] isKindOfClass:[DPCarouselViewController class]]) {
            carousel = (DPCarouselViewController *)self.childViewControllers[i];
            currImgIndex = carousel.currentIndex;
            if (reload) {
                [carousel.view removeFromSuperview];
                [carousel removeFromParentViewController];
                carousel = nil;
            }
            break;
        }
    
    [self.topView setNeedsDisplay];

//    if (carousel != nil && carousel.carouselCategoryID != [self carouselCategory]) {
//        [carousel.view removeFromSuperview];
//        [carousel removeFromParentViewController];
//        carousel = nil;
//        currImgIndex = 0;
//    }
    
    if (carousel == nil) {
        carousel = [[DPCarouselViewController alloc] initWithCtg:[self carouselCategory]];
        CGRect frm = self.topView.bounds;
        carousel.view.frame = frm;
        [self addChildViewController:carousel];
        [self.topView addSubview:carousel.view];
    } else {
        CGRect frm = self.topView.bounds;
        carousel.view.frame = frm;
    }
    [carousel makeCurrentImageAtIndex:currImgIndex];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setBbiMore:nil];
    [self setBbiBuy:nil];
    [self setTopView:nil];
    [self setBottomView:nil];
    [self setBbiFavs:nil];
    [self setBbiInfo:nil];
    [self setSpacingInfoMore:nil];
    [self setSpacingLeft:nil];
    [super viewDidUnload];
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
//    return NO;
//}
//==============================================================================

@end
