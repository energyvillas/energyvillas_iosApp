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
#import "DPSocialViewController.h"
#import "DPMailHelper.h"

#import "DPSocialManager.h"
#import "DPIAPHelper.h"



@interface DPRootViewController () 

@property (strong, nonatomic) NSMutableDictionary *coverFlowDict;
@property (strong, nonatomic) DPBuyViewController *buyController;
//@property (strong, nonatomic) DPSocialViewController *socialController;
@property (strong, nonatomic) DPSocialManager *socialManager;


//@property (strong, nonatomic) FPPopoverController *popController;

@end

@implementation DPRootViewController {
    int onAfterAppear;
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

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.actionDelegate = self;
    [self doLocalize];
    [self.bbiMore setAction:@selector(doMore:)];
    [self.bbiBuy setAction:@selector(doBuy:)];
}

- (void) doLocalize {
    [super doLocalize];
    self.bbiMore.title = showingMore ? DPLocalizedString(kbbiMoreBack_Title) : DPLocalizedString(kbbiMore_Title);
    self.bbiBuy.title = DPLocalizedString(kbbiBuy_Title);
    
    if (self.bottomView.subviews.count > 0) {
        [self loadDetailView:YES];
        [self loadOpenFlow:YES];
    }
}

- (void) showBuyDialog:(int)ctgId {
    DPIAPHelper *iap = [DPIAPHelper sharedInstance];
    if (![iap canMakePurchases])
        showAlertMessage(nil, @"Info", @"Cannot make purchase at the moment. Please try later!");
    else {
        if (iap.product == nil)
            showAlertMessage(nil, @"Info", @"No product found!Try again later!");
        else
            [self showBuyDialog:ctgId product:iap.product];
    }
}

- (void) showBuyDialog:(int)ctgId product:(SKProduct *)aProduct {
    //AudioServicesPlaySystemSound(1320);
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

- (void) doBuy:(id) sender {
    [self showBuyDialog:CTGID_GENERAL_BUY_DLG];
}

- (void) doMore:(id) sender {
    // do the more stuff here
    showingMore = !showingMore;
        
    self.bbiMore.title = showingMore ? DPLocalizedString(kbbiMoreBack_Title) : DPLocalizedString(kbbiMore_Title);

    [self loadOpenFlow:YES];
}

#pragma mark - DPActionDelegate

-(void) onTapped:(id)sender {
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    if (bbi == nil) return;
    
    switch (bbi.tag) {
//        case TAG_NBI_LANG_EN:
//        case TAG_NBI_LANG_EL:
//            [self langSelControlPressed:sender];
//            break;
//            
//        case TAG_NBI_BACK:
//            [self.navigationController popViewControllerAnimated:YES];
//            break;
//        case TAG_NBI_ADD_FAV:
//            // do stuff
//            break;
//            
        case TAG_NBI_SHARE: {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self sendMail];
//            });

            [self showSocialsDialog];
            break;
        }
        default:
            break;
    }
}

- (void) showSocialsDialog {
    if (self.socialManager == nil) {
        self.socialManager = [[DPSocialManager alloc] initWithController:self
                                                          onSocialClosed:^{
                                                              onAfterAppear++;
//                                                              dispatch_async(dispatch_get_main_queue(), ^{
//                                                                  [self loadDetailView:YES];
//                                                              });
                                                          }];
//        self.socialManager.socialDelegate = self;
    }
    
    [self.socialManager showSocialsDialog:^(int socialAction){
        //self.socialManager = nil;
//        [self sendMail];
     }];
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

//    int h = vf.size.height - vf.origin.y; //IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y;
//    int w = vf.size.width;
//    int topOfs = fixtop ? vf.origin.y : 0;
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
    
    [self loadOpenFlow:NO];
    [self loadDetailView:NO];
    
//    if (/*IS_IPAD && */self.buyController) {
//        int ctgid = self.buyController.category;
//        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
//        self.view.userInteractionEnabled = YES;
//        self.buyController = nil;
//        [self showBuyDialog:ctgid];
//    }
    
//    if (self.buyController) {
//        CGRect svfrm = [self.buyController calcFrame];
//        svfrm.origin = CGPointMake((w - svfrm.size.width - 2.0f) / 2.0f, svfrm.origin.y);
//                                   //(h - svfrm.size.height) / 2.0f);
//        self.buyController.view.superview.backgroundColor = [UIColor clearColor];
//        svfrm = IS_PORTRAIT ? CGRectOffset(svfrm, 0, 170) : CGRectOffset(svfrm, 0, 180);
//        NSLogFrame(@"BUY FRM:", svfrm);
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLogFrame(@"BUY FRM CONTAINER", self.view.frame);
////            self.buyController.view.superview.center = self.view.center;
//        });
//    }
    
//    if (IS_IPAD && self.socialManager && self.socialManager.showingDialog) {
//        [self.socialManager hideSocialsDialog];
//        self.socialManager = nil;
//        [self showSocialsDialog];
//    }
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
    
    if (onAfterAppear>0) {
        onAfterAppear--;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadDetailView:YES];
        });
    }
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setBbiMore:nil];
    [self setBbiBuy:nil];
    [self setTopView:nil];
    [self setBottomView:nil];
    self.socialManager = nil;
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
- (BOOL) showNavBarSocial {
    return YES;
}
//- (BOOL) showNavBarInfo {
//    return YES;
//}
//==============================================================================

@end
