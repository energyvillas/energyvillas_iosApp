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



@interface DPRootViewController () 

@property (strong, nonatomic) NSMutableDictionary *coverFlowDict;
@property (strong, nonatomic) DPBuyViewController *buyController;
//@property (strong, nonatomic) DPSocialViewController *socialController;
@property (strong, nonatomic) DPSocialManager *socialManager;

@end

@implementation DPRootViewController {
    int onAfterAppear;
    BOOL showingMore;
}


- (id) init {
    self = [super init];
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
        [self loadOpenFlow];
    }
}

- (void) showBuyDialog:(int)ctgId {
    //AudioServicesPlaySystemSound(1320);
    if (IS_IPAD)
        [self showBuyDialog_iPads:ctgId];
    else
        [self showBuyDialog_iPhones:ctgId];
}

- (void) showBuyDialog_iPads:(int)ctgId {    
    self.buyController = [[DPBuyViewController alloc]
                                  initWithCategoryId:ctgId
                                  completion:^{
                                      self.view.userInteractionEnabled = YES;
                                      self.buyController = nil;
                                  }];
    
    self.view.userInteractionEnabled = NO;
    self.buyController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:self.buyController animated:YES completion:nil];
    CGRect svfrm = [self.buyController calcFrame];
    if (IS_PORTRAIT)
        self.buyController.view.superview.frame = CGRectOffset(svfrm, 0, 170);
    else
        self.buyController.view.superview.frame = CGRectOffset(svfrm, 0, 180);
}

- (void) showBuyDialog_iPhones:(int)ctgId {
    id del = self.navigationController.delegate;
    DPMainViewController *main = del;
    
    DPBuyViewController *buyVC = [[DPBuyViewController alloc]
                                  initWithCategoryId:ctgId
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

    [self loadOpenFlow];
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
    
    [self.socialManager showSocialsDialog:^{
        //self.socialManager = nil;
    }];
}


////==============================================================================
//
//- (void) showSocialsDialog {
//    AudioServicesPlaySystemSound(0x528);
//    if (IS_IPAD)
//        [self showSocialsDialog_iPads];
//    else
//        [self showSocialsDialog_iPhones];
//}
//
//- (void) showSocialsDialog_iPads {
//    self.socialController = [[DPSocialViewController alloc]
//                             initWithCompletion:^(int indx){
//                                 self.view.userInteractionEnabled = YES;
//                                 self.socialController = nil;
//                                 
//                                 if (indx == -1)
//                                     ;//[self showSocialsDialog];
//                                 else if (indx > 0)
//                                     [self launchSocialAction:indx];
//                             }];
//    
//    self.view.userInteractionEnabled = NO;
//    self.socialController.modalPresentationStyle = UIModalPresentationFormSheet;
//    self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self.navigationController presentViewController:self.socialController animated:YES completion:nil];
//    CGRect svfrm = [self.socialController calcFrame];
//    if (IS_PORTRAIT)
//        self.socialController.view.superview.frame = svfrm;
//    else
//        self.socialController.view.superview.frame = svfrm;
//}
//
//- (void) showSocialsDialog_iPhones {
//    id del = self.navigationController.delegate;
//    DPMainViewController *main = del;
//    
//    DPSocialViewController *vc = [[DPSocialViewController alloc]
//                                  initWithCompletion:^(int indx){
//                                      self.view.userInteractionEnabled = YES;
//                                      self.socialController = nil;
//                                      
//                                      if (indx == -1)
//                                          [self showSocialsDialog];
//                                      else if (indx > 0)
//                                          [self launchSocialAction:indx];
//                                  }];
//    
//    self.view.userInteractionEnabled = NO;
//    
//    [main addChildViewController:vc];
//    [main.view addSubview:vc.view];
//}
//
//-(void) launchSocialAction:(int) action {
//    switch (action) {
//        case SOCIAL_ACT_FACEBOOK: {
//            DPFacebookViewController *facebook = [[DPFacebookViewController alloc] init];
//            [self.navigationController pushViewController:facebook animated:YES];
//
//            break;
//        }
//        case SOCIAL_ACT_TWITTER:
//            [self tweet:nil url:nil];
//            break;
//            
//        case SOCIAL_ACT_LINKEDIN:
//            
//            break;
//            
//        case SOCIAL_ACT_EMAIL:
//            [self composeEmail];
//            break;
//            
//        case SOCIAL_ACT_FAVS:
//            
//            break;
//            
//        case SOCIAL_ACT_OTHER:
//            
//            break;
//            
//        default:
//            break;
//    }
//}
//
////==============================================================================
//
//-(void) composeEmail {
//    MFMailComposeViewController *composer = [DPMailHelper composeEmail];
//    composer.mailComposeDelegate = self;
//	[self.navigationController presentModalViewController:composer animated:YES];
//}
//
//#pragma mark - MFMailComposeViewControllerDelegate
//
//-(void) mailComposeController:(MFMailComposeViewController *)controller
//          didFinishWithResult:(MFMailComposeResult)result
//                        error:(NSError *)error {
//	[controller dismissModalViewControllerAnimated:YES];
//
//    onAfterAppear++;
//}
//
////==============================================================================
//
//- (void) tweet:(NSString *)imgUrl url:(NSString *)urlstr {
////    if (![TWTweetComposeViewController canSendTweet])
////    {
////        UIAlertView *alertView = [[UIAlertView alloc]
////                                  initWithTitle:@"Sorry"
////                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
////                                  delegate:self
////                                  cancelButtonTitle:@"OK"
////                                  otherButtonTitles:nil];
////        [alertView show];
////        
////        return;
////    }
//    
//    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
//    [tweetSheet setInitialText: @"Tweeting from energyVillas! :)"];
//    
//    if (imgUrl) {
//        UIImage *img = [UIImage imageNamed:imgUrl];
//        if (img)
//            [tweetSheet addImage:img];
//    }
//    
//    if (urlstr) {
//        NSURL *url = [NSURL URLWithString:urlstr];
//        if (url)
//            [tweetSheet addURL:url];
//    }
//    
//    [self presentModalViewController:tweetSheet animated:YES];
//}

//==============================================================================
//==============================================================================
//==============================================================================

- (void)didReceiveMemoryWarning
{
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
    
    [self loadOpenFlow];
    [self loadDetailView:NO];
    
    if (/*IS_IPAD && */self.buyController) {
        int ctgid = self.buyController.category;
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        self.view.userInteractionEnabled = YES;
        self.buyController = nil;
        [self showBuyDialog:ctgid];
    }
//    if (IS_IPAD && self.socialController) {
//        //int ctgid = self.socialController.category;
//        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
//        self.view.userInteractionEnabled = YES;
//        self.socialController = nil;
//        [self showSocialsDialog];
//    }
    if (IS_IPAD && self.socialManager && self.socialManager.showingDialog) {
        [self.socialManager hideSocialsDialog];
        self.socialManager = nil;
        [self showSocialsDialog];
    }
}

- (void) loadDetailView:(BOOL)reload{
    UIView *bcv = self.bottomView;

    DPCategoriesViewController *detvc;
    if (reload && bcv.subviews.count > 0) {
        detvc = (DPCategoriesViewController *)self.childViewControllers[0];
        [detvc.view removeFromSuperview];
        [detvc removeFromParentViewController];
        detvc = nil;
    }        
    
    if (bcv.subviews.count == 0) {
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
        
        detvc = nil;
    } else {
        for (int i = 0; i < self.childViewControllers.count; i++)
            if ([self.childViewControllers[0] isKindOfClass:[DPCategoriesViewController class]]) {
                detvc = (DPCategoriesViewController *)self.childViewControllers[i];
                detvc.view.frame = self.bottomView.bounds;
                if (IS_PORTRAIT)
                    [detvc changeRows:2 columns:2];
                else
                    [detvc changeRows:1 columns:4];
                
                break;
            }
    }
}

-(int) carouselCategory {
    return showingMore ? CTGID_CAROUSEL_MORE : CTGID_CAROUSEL;
}

- (void) loadOpenFlow {
    //self.topView.backgroundColor = [UIColor yellowColor];
    
    DPCarouselViewController *carousel = nil;
    int currImgIndex = 0;
    for (int i = 0; i < self.childViewControllers.count; i++)
        if ([self.childViewControllers[i] isKindOfClass:[DPCarouselViewController class]]) {
            carousel = (DPCarouselViewController *)self.childViewControllers[i];
            currImgIndex = carousel.currentIndex;
            [carousel.view removeFromSuperview];
            [carousel removeFromParentViewController];
            carousel = nil;
            break;
        }
    
    [self.topView setNeedsDisplay];
    
    carousel = [[DPCarouselViewController alloc] initWithCtg:[self carouselCategory]];
    CGRect frm = self.topView.bounds;
    carousel.view.frame = frm;
    [self addChildViewController:carousel];
    [self.topView addSubview:carousel.view];
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
