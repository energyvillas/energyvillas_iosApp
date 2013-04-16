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


@interface DPRootViewController ()

@property (strong, nonatomic) NSMutableDictionary *coverFlowDict;
@property (strong, nonatomic) DPBuyViewController *buyController;

@end

@implementation DPRootViewController


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
    [self doLocalize];
    [self.bbiMore setAction:@selector(doMore:)];
    [self.bbiBuy setAction:@selector(doBuy:)];
}

- (void) doLocalize {
    [super doLocalize];
    self.bbiMore.title = DPLocalizedString(kbbiMore_Title);
    self.bbiBuy.title = DPLocalizedString(kbbiBuy_Title);
    
    if (self.bottomView.subviews.count > 0) {
        [self loadDetailView:YES];
        [self loadOpenFlow];
    }
}

- (void) showBuyDialog:(int)ctgId {
    AudioServicesPlaySystemSound(0x528);
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doLayoutSubViews {    
    CGRect vf = self.view.frame;
    
    int h = IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y ;
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
    
    self.topView.frame = CGRectMake(0, 0, w, topHeight);
    
    self.toolbar.frame = CGRectMake(0, topHeight,
                                    w, toolbarHeight);
    
    self.bottomView.frame = CGRectMake(0, topHeight + toolbarHeight,
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
                                                              autoScroll:YES
                                                                  parent:self];
        else
            detvc = [[DPCategoriesViewController alloc] initWithCategory:-1
                                                                    lang:apphelper.currentLang
                                                           localResource:@"free-details.plist"
                                                                    rows:1
                                                                 columns:4
                                                              autoScroll:YES
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

- (void) loadOpenFlow {    
    DPCarouselViewController *carousel = nil;
    int currImgIndex = -1;
    for (int i = 0; i < self.childViewControllers.count; i++)
        if ([self.childViewControllers[0] isKindOfClass:[DPCarouselViewController class]]) {
            carousel = (DPCarouselViewController *)self.childViewControllers[i];
            currImgIndex = carousel.currentIndex;
            [carousel.view removeFromSuperview];
            [carousel removeFromParentViewController];
            carousel = nil;
            break;
        }
    
    carousel = [[DPCarouselViewController alloc] init];
    CGRect frm = self.topView.bounds;
    carousel.view.frame = frm;
    [self addChildViewController:carousel];
    [self.topView addSubview:carousel.view];
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
    [super viewDidUnload];
}

@end
