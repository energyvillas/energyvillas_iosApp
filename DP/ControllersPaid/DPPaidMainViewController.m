//
//  DPPaidMainViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "DPPaidMainViewController.h"
#import "../Classes/DPHtmlContentViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "../Models/DPDataLoader.h"
#import "DPConstants.h"
#import "DPAppHelper.h"



@interface DPPaidMainViewController ()
@property (strong, nonatomic) UIViewController *whoViewController;
@property (strong, nonatomic) UIViewController *buyViewController;
@property (strong, nonatomic) UIViewController *callViewController;
@property (strong, nonatomic) UIViewController *moreViewController;

@property (strong, nonatomic) FPPopoverController *popupController;
@property (strong, nonatomic) DPMoreMenuViewController *popupContentViewController;
@end

@implementation DPPaidMainViewController {
    bool framesDone;
    bool isPortrait;
    int currentBackgroundCategory;
}

//@synthesize navController, tabBar;
//@synthesize whoViewController, buyViewController, callViewController, moreViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        framesDone = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationObservers];
	// Do any additional setup after loading the view.
    [self.view insertSubview:self.navController.view atIndex:0];
    self.navController.delegate = self;
    self.tabBar.delegate = self;
}

-(void) doLocalize {
    [super doLocalize];

    self.tbiMain.title = DPLocalizedString(ktbiMain_Title);
    self.tbiWho.title = DPLocalizedString(ktbiWho_Title);
    self.tbiBuy.title = DPLocalizedString(ktbiBuy_Title);
    self.tbiCall.title = DPLocalizedString(ktbiCall_Title);
    self.tbiMore.title = DPLocalizedString(ktbiMore_Title);
    
    self.tbiMain.image = [UIImage imageNamed:[NSString
                                              stringWithFormat:@"TabBar/bottom_menu_ev_%@.png",
                                              CURRENT_LANG]];
    
    self.tbiWho.image = [UIImage imageNamed:@"TabBar/bottom_menu_poioi_eimaste.png"];
    
    self.tbiBuy.image = [UIImage imageNamed:@"TabBar/bottom_menu_agora_oikopedou.png"];
    
    self.tbiCall.image = [UIImage imageNamed:@"TabBar/bottom_menu_klisi.png"];
    
    self.tbiMore.image = [UIImage imageNamed:@"TabBar/bottom_menu_more.png"];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [self fixBackgroundImage];
    if (!framesDone) {
        [self fixFrames:YES];
        self.tabBar.selectedItem = self.tbiMain;
        framesDone = YES;
    }
    [super viewWillAppear:animated];
    [self doLocalize];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearPopups];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    [self clearPopups];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [self doFixFrames:viewController fixTop:YES];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self fixBackgroundImage];
    
    [self doFixFrames:self.navController.topViewController fixTop:NO];
}

-(void) doFixFrames:(UIViewController *)viewController fixTop:(BOOL)fixtop {
    [self clearPopups];

    [self fixFrames:NO];
    if (viewController && [viewController isKindOfClass:[UINavContentViewController class]])
       // dispatch_async(dispatch_get_main_queue(), ^{
//        [(UINavContentViewController *)viewController doLayoutSubViews:fixtop];
    [viewController.view setNeedsDisplay];
       // });
}

- (void) fixFrames:(BOOL)fixNavView {
    if (fixNavView) {
        CGRect sf = [UIScreen mainScreen].applicationFrame;
        self.view.frame = sf;
        CGRect tbf = self.tabBar.frame;

        self.navController.view.frame = CGRectMake(0, 0,
                                                   sf.size.width,
                                                   sf.size.height - tbf.size.height);
    } else {
        UIViewController *tvc = self.navController.topViewController;
        
        CGRect nc_nbf = self.navController.navigationBar.frame;
        CGRect tvc_svf = tvc.view.superview.frame;
        CGRect tvc_vf = tvc.view.frame;
        
        if (IS_LANDSCAPE) {
            tvc_vf = CGRectMake(0, nc_nbf.size.height - tvc_svf.origin.y,
                                tvc_svf.size.width,
                                tvc_svf.size.height);
        //    tvc.view.frame = tvc_vf;
            //        [tvc.view setNeedsDisplay];
        }
    }
}

- (void) addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:DPN_PAID_SelectedCategoryChanged_Notification
                                               object:nil];

}
- (void) removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DPN_PAID_SelectedCategoryChanged_Notification
                                                  object:nil];
}
-(void) onNotified:(NSNotification *)notification {
    if ([notification.name isEqualToString:DPN_PAID_SelectedCategoryChanged_Notification]) {
        int ctg = [notification.userInfo[@"menuCategory"] intValue];
        currentBackgroundCategory = ctg;
        [self fixBackgroundImage];
    }
}

- (void) fixBackgroundImage {
    NSString *imgName;
    switch (currentBackgroundCategory) {
        case CTGID_EXCLUSIVE_DESIGNER:
            imgName = IS_PORTRAIT ? @"Background/bg_exclusive_designer_v.jpg" : @"Background/bg_exclusive_designer_h.jpg";
            break;
            
        case CTGID_EXCLUSIVE_ART:
            imgName = IS_PORTRAIT ? @"Background/bg_exclusive_art_v.jpg" : @"Background/bg_exclusive_art_h.jpg";
            break;
            
        default:
            imgName = IS_PORTRAIT ? @"Background/bg_v.jpg" : @"Background/bg_h.jpg";
            break;
    }    
    
    self.view.layer.contents = (id)[[UIImage imageNamed:imgName] CGImage];
}

- (void) cleanControllers:(UIViewController *)tvc {
    if (tvc == self.whoViewController) self.whoViewController = nil;
    if (tvc == self.buyViewController) self.buyViewController = nil;
    if (tvc == self.callViewController) self.callViewController = nil;
    if (tvc == self.moreViewController) self.moreViewController = nil;
}

- (void) checkRootAndPop:(UIViewController *)tvc {
    UIViewController *rvc = self.navController.viewControllers[0];
    if (tvc != rvc && [self isTabBarPage:tvc]) {
        [self.navController popViewControllerAnimated:NO];
        [self cleanControllers:tvc];
    }
}

- (BOOL) checkTop:(UIViewController *)vc {
    UIViewController *tvc = [self.navController topViewController];
    if (tvc == vc) return YES;
    
    [self checkRootAndPop:tvc];
    return NO;
}

- (void) showViewController:(UIViewController *) vc {
    [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                           forKey:@"menuCategory"]];
    
    if (!self.navController.navigationBarHidden)
        [self.navController setNavigationBarHidden:YES animated:YES];
    [self.navController pushViewController:vc animated:YES];
}

-(BOOL) isTabBarPage:(UIViewController *)tvc {
    return (tvc != nil) && (
                            (tvc == self.whoViewController) ||
                            (tvc == self.buyViewController) ||
                            (tvc == self.callViewController) ||
                            (tvc == self.moreViewController)
                            );
}

- (void) showMain {
    UIViewController *tvc = [self.navController topViewController];
    if ([self isTabBarPage:tvc]){
        [self.navController setNavigationBarHidden:NO animated:NO];
        [self.navController popViewControllerAnimated:YES];
        [self cleanControllers:tvc];
    } else {
        [self.navController setNavigationBarHidden:NO animated:NO];
        [self.navController popToRootViewControllerAnimated:YES];
    }
}

- (void) showWho {
    if ([self checkTop:self.whoViewController]) return;
    
    self.whoViewController = [[DPHtmlContentViewController alloc]
                              initWithCategory:CTGID_WHO_WE_ARE lang:CURRENT_LANG];
    
    [self showViewController:self.whoViewController];
}

- (void) showBuy {
    if ([self checkTop:self.buyViewController]) return;
    
    self.buyViewController = [[DPHtmlContentViewController alloc]
                               initWithCategory:CTGID_PURCHASE_LAND lang:CURRENT_LANG];

    [self showViewController:self.buyViewController];
}

- (void) showCall {
    if ([self checkTop:self.callViewController]) return;
    
    self.callViewController = [[DPHtmlContentViewController alloc]
                              initWithCategory:CTGID_CALL_US lang:CURRENT_LANG];
    
    [self showViewController:self.callViewController];
}

- (void) showMore {
    double delayInSeconds = 0.4f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showMoreMenu];
    });
}

// called when a new view is selected by the user (but not programatically)
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"tapped on tbi => %d", item.tag);
    
    switch (item.tag) {
        case TAG_TBI_MAIN: [self showMain];
            break;
            
        case TAG_TBI_WHO: [self showWho];
            break;
            
        case TAG_TBI_BUY: [self showBuy];
             break;
            
        case TAG_TBI_CALL: [self showCall];
            break;
            
        case TAG_TBI_MORE: [self showMore];
            break;
    }
}

#pragma mark - START :: "more" popover submenus

- (void) menuItemSelected:(int)menuTag {
    [self.popupController dismissPopoverAnimated:YES];
    self.popupController = nil;

    switch (menuTag) {
        case TAG_TBIX_COST: 
            break;
            
        case TAG_TBIX_FRANCHISE:
            break;
            
        case TAG_TBIX_IDEA:
            break;
            
        case TAG_TBIX_MATERIALS:
            break;
            
        case TAG_TBIX_PLANET:
            break;
            
        case TAG_TBIX_PROFIT:
            break;
    }
}
- (void)handleIslandTap:(UITapGestureRecognizer *)sender {
//    [self.popupController dismissPopoverAnimated:YES];
//    self.popupController = nil;
//
//    if (sender.state == UIGestureRecognizerStateEnded) {
//        // handling code
//        int indx = sender.view.tag;
//        DPDataElement *element = self.islandsContent[indx];
//        NSLog(@"Clicked island image at index %i named %@ ", indx, element.title);
//        
//        [self elementTapped:nil element:element];
//    }
}

-(id) doCreatePopupContentViewController {
    DPMoreMenuViewController *vc = [[DPMoreMenuViewController alloc] init];
    vc.menuDelegate = self;
    
//    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
//    self.islandsContent = [appHelper paidMenuOfCategory:ctgId lang:appHelper.currentLang];
//    
//    for (int i = 0; i < self.islandsContent.count; i++) {
//        DPDataElement *element = self.islandsContent[i];
//        [vc.view addSubview:[self doCreateItem:element tag:i]];
//    }
    
    return vc;
}

- (void) clearPopups {
    if (self.popupController) {
        [self.popupController dismissPopoverAnimated:YES];
        self.popupController = nil;
    }
    if (self.popupContentViewController)
        self.popupContentViewController.menuDelegate = nil;
    self.popupContentViewController = nil;
}

-(void) showMoreMenu {
    [self clearPopups];
    CGRect frm = self.view.bounds;
    
    
    //the view controller you want to present as popover
    if (!self.popupContentViewController)
        self.popupContentViewController = [self doCreatePopupContentViewController];
    
    self.popupContentViewController.title = nil;
    
    //our popover
    self.popupController = [[FPPopoverController alloc]
                          initWithViewController:self.popupContentViewController];
    self.popupController.delegate = self;
    self.popupController.border = NO;
    self.popupController.tint = FPPopoverBlackTint;
    self.popupController.arrowDirection = FPPopoverNoArrow;
    CGSize sz = self.popupContentViewController.view.bounds.size;
    sz.width += 20; sz.height += 40;
    self.popupController.contentSize = sz;
    CGPoint pnt = CGPointMake(frm.size.width, frm.size.height - 49);
    [self.popupController presentPopoverFromPoint:pnt];
}


- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    self.tabBar.selectedItem = nil;
}
#pragma END :: islands and exclusive popover sbmenus


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// PENDING
- (void)viewDidUnload {
    [self removeNotificationObservers];
    
    [self setNavController:nil];
    [self setTabBar:nil];
    [self setTbiMain:nil];
    [self setTbiWho:nil];
    [self setTbiBuy:nil];
    [self setTbiCall:nil];
    [self setTbiMore:nil];

    if (self.whoViewController) {
        self.whoViewController=nil;
    }

    if (self.buyViewController) {
//        [self.buyViewController.view removeFromSuperview];
//        [self.buyViewController removeFromParentViewController];
        self.buyViewController=nil;
    }

    if (self.callViewController) {
//        [self.callViewController.view removeFromSuperview];
//        [self.callViewController removeFromParentViewController];
        self.callViewController=nil;
    }

    if (self.moreViewController) {
//        [self.moreViewController.view removeFromSuperview];
//        [self.moreViewController removeFromParentViewController];
        self.moreViewController=nil;
    }
    
    [super viewDidUnload];
}


@end
