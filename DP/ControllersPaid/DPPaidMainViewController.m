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
#import "DPModalDialogManager.h"
#import "DPCallUsViewController.h"
#import "DPCTGViewController.h"
#import "DPFavoritesViewController.h"



@interface DPPaidMainViewController ()
@property (strong, nonatomic) UIViewController *ideaViewController;
@property (strong, nonatomic) UIViewController *realEstateViewController;
//@property (strong, nonatomic) UIViewController *callViewController;
//@property (strong, nonatomic) UIViewController *moreViewController;

@property (strong, nonatomic) UIViewController *whoViewController;
@property (strong, nonatomic) UIViewController *franchiseViewController;
@property (strong, nonatomic) UIViewController *costViewController;
@property (strong, nonatomic) UIViewController *profitViewController;
@property (strong, nonatomic) UIViewController *materialsViewController;
@property (strong, nonatomic) UIViewController *planetViewController;
@property (strong, nonatomic) UIViewController *favoritesViewController;

@property (strong, nonatomic) FPPopoverController *popupController;
@property (strong, nonatomic) DPMoreMenuViewController *popupContentViewController;

@property (strong, nonatomic) DPModalDialogManager *dlgManager;
@end

@implementation DPPaidMainViewController {
    bool framesDone;
    bool isPortrait;
    int currentBackgroundCategory;
    int tbSelItem;
    BOOL inClearPopups;
}


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
    self.tbiIdea.title = DPLocalizedString(ktbiIdea_Title);
    self.tbiRealEstate.title = DPLocalizedString(ktbiRealEstate_Title);
    self.tbiCall.title = DPLocalizedString(ktbiCall_Title);
    self.tbiMore.title = DPLocalizedString(ktbiMore_Title);
    
    self.tbiMain.image = [UIImage imageNamed:[NSString
                                              stringWithFormat:@"TabBar/bottom_menu_ev_%@.png",
                                              CURRENT_LANG]];
    
    self.tbiIdea.image = [UIImage imageNamed:@"TabBar/bottom_menu_idea.png"];
    
    self.tbiRealEstate.image = [UIImage imageNamed:@"TabBar/bottom_menu_agora_oikopedou.png"];
    
    self.tbiCall.image = [UIImage imageNamed:@"TabBar/bottom_menu_klisi.png"];
    
    self.tbiMore.image = [UIImage imageNamed:@"TabBar/bottom_menu_more.png"];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [self fixBackgroundImage];
    if (!framesDone) {
        [self fixFrames:YES];
        self.tabBar.selectedItem = self.tbiMain;
        tbSelItem = TAG_TBI_MAIN;
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

- (void) cleanControllers { //:(UIViewController *)tvc {
//    if (tvc == self.ideaViewController)
        self.ideaViewController = nil;
    
//    if (tvc == self.realEstateViewController)
        self.realEstateViewController = nil;
    
    //if (tvc == self.callViewController) self.callViewController = nil;
    //if (tvc == self.moreViewController) self.moreViewController = nil;

//    if (tvc == self.whoViewController)
        self.whoViewController = nil;
    
//    if (tvc == self.franchiseViewController)
        self.franchiseViewController = nil;
    
//    if (tvc == self.costViewController)
        self.costViewController = nil;
    
//    if (tvc == self.profitViewController)
        self.profitViewController = nil;
    
//    if (tvc == self.materialsViewController)
        self.materialsViewController = nil;
    
//    if (tvc == self.planetViewController)
        self.planetViewController = nil;
    
//    if (tvc == self.favoritesViewController)
        self.favoritesViewController = nil;
}

- (int) findTabViewControllerIndexInNavigator {
    int result = -1;
    int count = self.navController.viewControllers.count;
    for (int i = count - 1; i > 0; i--) { // i>0 to avoid touching the "root"
        UIViewController *vc = self.navController.viewControllers[i];
        if ([self isTabBarPage:vc]) {
            result = i;
            break;
        }
    }
    return result;
}

- (void) checkRootAndPop:(UIViewController *)tvc {
    UIViewController *rvc = self.navController.viewControllers[0];
    if (tvc != rvc) {
        [self checkPopTabBarViewController];
    }
    //    if (tvc != rvc && [self isTabBarPage:tvc]) {
    //        [self.navController popViewControllerAnimated:NO];
    //        [self cleanControllers:tvc];
    //    }
}

- (int) checkPopTabBarViewController {
    int tbvcIndex = [self findTabViewControllerIndexInNavigator];
    if (tbvcIndex != -1) {
        if (tbvcIndex == 1) {
            [self.navController popToRootViewControllerAnimated:NO];
        } else {
            UIViewController *tbvc = self.navController.viewControllers[tbvcIndex - 1];
            [self.navController popToViewController:tbvc animated:NO];
        }
        [self cleanControllers];//:tvc];
    }
    
    return tbvcIndex;
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
    [self fixSelectedTabBarItem];
}

-(BOOL) isTabBarPage:(UIViewController *)tvc {
    return (tvc != nil) && (
                            (tvc == self.ideaViewController) ||
                            (tvc == self.realEstateViewController) ||
                            //(tvc == self.callViewController) ||
                            //(tvc == self.moreViewController) ||
                            (tvc == self.whoViewController) ||
                            (tvc == self.franchiseViewController) ||
                            (tvc == self.costViewController) ||
                            (tvc == self.profitViewController) ||
                            (tvc == self.materialsViewController) ||
                            (tvc == self.planetViewController) ||
                            (tvc == self.favoritesViewController)
                            );
}

- (void) showMain {
    [self.navController setNavigationBarHidden:NO animated:NO];
    int indexOfTabBarController = [self checkPopTabBarViewController];
    if (indexOfTabBarController == -1) {
        // we were showing main controller, so we have to go to root...
        [self.navController popToRootViewControllerAnimated:YES];
    }
    
//    UIViewController *tvc = [self.navController topViewController];
//    if ([self isTabBarPage:tvc]){
//        [self.navController setNavigationBarHidden:NO animated:NO];
//        [self.navController popViewControllerAnimated:YES];
//        [self cleanControllers:tvc];
//    }
//    else {
//        [self.navController setNavigationBarHidden:NO animated:NO];
//        [self.navController popToRootViewControllerAnimated:YES];
//    }
}

- (void) showIdea {
    if ([self checkTop:self.ideaViewController]) return;
    
    self.ideaViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_IDEA
                                                                 fromParent:CTGID_ROOT_CATEGORY
                                                              useDeviceType:YES];
    
    [self showViewController:self.ideaViewController];
}

- (void) showRealEstate {
    if ([self checkTop:self.realEstateViewController]) return;
    
    self.realEstateViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_REAL_ETATE
                                                                       fromParent:CTGID_ROOT_CATEGORY
                                                                    useDeviceType:YES];
    
    [self showViewController:self.realEstateViewController];
}

- (void) showWho {
    if ([self checkTop:self.whoViewController]) return;
    
    self.whoViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_WHO_WE_ARE
                                                                fromParent:CTGID_ROOT_CATEGORY
                                                             useDeviceType:YES];
    
    [self showViewController:self.whoViewController];
}

- (void) showFranchise {
    if ([self checkTop:self.franchiseViewController]) return;
    
    self.franchiseViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_FRANCHISE
                                                                      fromParent:CTGID_ROOT_CATEGORY
                                                                   useDeviceType:YES];
    
    [self showViewController:self.franchiseViewController];
}

- (void) showCost {
    if ([self checkTop:self.costViewController]) return;
    
    self.costViewController = [[DPHtmlContentViewController alloc]
             initWithCategory:CTGID_COST lang:CURRENT_LANG];
    
    [self showViewController:self.costViewController];
}


- (void) showProfit {
    if ([self checkTop:self.profitViewController]) return;
    
    self.profitViewController = [[DPHtmlContentViewController alloc]
             initWithCategory:CTGID_PROFIT lang:CURRENT_LANG];
    
    [self showViewController:self.profitViewController];
}


- (void) showMaterials {
    if ([self checkTop:self.materialsViewController]) return;
    
    self.materialsViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_MATERIALS
                                                                      fromParent:CTGID_ROOT_CATEGORY
                                                                   useDeviceType:YES];

    
    [self showViewController:self.materialsViewController];
}

;
- (void) showPlanet {
    if ([self checkTop:self.planetViewController]) return;
    
    self.planetViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_PLANET
                                                                fromParent:CTGID_ROOT_CATEGORY
                                                             useDeviceType:YES];
    
    [self showViewController:self.planetViewController];
}

- (BOOL) canShowFavorites {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    return ([[apphelper favoriteArticles] count] > 0);
}

- (void) showFavorites {
    if ([self checkTop:self.favoritesViewController]) return;
    
    self.favoritesViewController = [[DPFavoritesViewController alloc] init];
    
    [self showViewController:self.favoritesViewController];
}

- (void) fixSelectedTabBarItem {
    switch (tbSelItem) {
        case TAG_TBI_MAIN: self.tabBar.selectedItem = self.tbiMain;
            break;
            
        case TAG_TBI_IDEA: self.tabBar.selectedItem = self.tbiIdea;
            break;
            
        case TAG_TBI_REAL_ESTATE: self.tabBar.selectedItem = self.tbiRealEstate;
            break;
            
        case TAG_TBIX_WHO:
        case TAG_TBIX_FRANCHISE:
        case TAG_TBIX_COST:
        case TAG_TBIX_PROFIT:
        case TAG_TBIX_MATERIALS:
        case TAG_TBIX_PLANET:
        case TAG_TBIX_FAVORITES:
            self.tabBar.selectedItem = self.tbiMore;
            break;
            
        default:
            break;
    }
    
}

- (void) showCall {
    UIViewController *contr = [self.navController topViewController];
    DPCallUsViewController *callusVC = [[DPCallUsViewController alloc] init];
    
    [callusVC setCompletion:^(int tag) {
        self.dlgManager.modalController = nil;
        contr.view.userInteractionEnabled = YES;
        
        switch (tag) {
            case 100:
                [[DPAppHelper sharedInstance] playSoundBloodSquirt];
                // cancelled... ok go on...
                break;
                
            case 101: {
                [[DPAppHelper sharedInstance] playSoundBloodSplatOnWall];
                // make the call
                NSString *telNo = [NSString stringWithFormat:@"%@", @"tel:+302103611150"];
                telNo = [telNo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telNo]];
                break;
            }
        }
        
        [self fixSelectedTabBarItem];
        
        self.dlgManager = nil;
    }];
    
    if (!self.dlgManager)
        self.dlgManager = [[DPModalDialogManager alloc] initWithController:contr];
    [self.dlgManager showDialog:callusVC];
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
        case TAG_TBI_MAIN: {
            tbSelItem = item.tag;
            [self showMain];
            break;
        }
        case TAG_TBI_IDEA: {
            tbSelItem = item.tag;
            [self showIdea];
            break;
        }
        case TAG_TBI_REAL_ESTATE: {
            tbSelItem = item.tag;
            [self showRealEstate];
             break;
        }
        case TAG_TBI_CALL: [self showCall];
            break;
            
        case TAG_TBI_MORE: [self showMore];
            break;
    }
}

#pragma mark - START :: "more" popover submenus

- (void) menuItemSelected:(int)menuTag {
    [self clearPopups];

    switch (menuTag) {
        case TAG_TBIX_WHO: {
            tbSelItem = menuTag;
            [self showWho];
            break;
        }
        case TAG_TBIX_FRANCHISE:{
            tbSelItem = menuTag;
            [self showFranchise];
            break;
        }

        case TAG_TBIX_COST:{
            tbSelItem = menuTag;
            [self showCost];
            break;
        }
        case TAG_TBIX_PROFIT: {
            tbSelItem = menuTag;
            [self showProfit];
            break;
        }
        case TAG_TBIX_MATERIALS: {
            tbSelItem = menuTag;
            [self showMaterials];
            break;
        }
        case TAG_TBIX_PLANET: {
            tbSelItem = menuTag;
            [self showPlanet];
            break;
        }
        case TAG_TBIX_FAVORITES:
            if ([self canShowFavorites]) {
                tbSelItem = menuTag;
                [self showFavorites];
                break;
            }
    }
    
    [self fixSelectedTabBarItem];
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
    inClearPopups = YES;
    @try {
        if (self.popupController) {
            [self.popupController dismissPopoverAnimated:NO];
            self.popupController = nil;
        }
        if (self.popupContentViewController)
            self.popupContentViewController.menuDelegate = nil;
        self.popupContentViewController = nil;
    }
    @finally {
        inClearPopups = NO;
    }
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

    CGSize sz = [self.popupContentViewController calcViewSize];
    //sz.width += 20; sz.height += 22;
    self.popupController.contentSize = sz;
    
    self.popupContentViewController.title = nil;
    self.popupController.title = nil;
    self.popupController.border = NO;
    self.popupController.tint = FPPopoverBlackTint;
    self.popupController.arrowDirection = FPPopoverNoArrow;//ArrowDirectionDown;//NoArrow;

    CGPoint orgn = [self.popupContentViewController calcOriginInFrame:frm];
    [self.popupController presentPopoverFromPoint:orgn];
}


- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:NO];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    if (!inClearPopups)
        [self fixSelectedTabBarItem];
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
    [self setTbiIdea:nil];
    [self setTbiRealEstate:nil];
    [self setTbiCall:nil];
    [self setTbiMore:nil];

    self.ideaViewController=nil;
    self.realEstateViewController=nil;
    self.whoViewController=nil;
    self.franchiseViewController=nil;
    self.costViewController=nil;
    self.profitViewController=nil;
    self.materialsViewController=nil;
    self.planetViewController=nil;
    self.favoritesViewController = nil;

    [super viewDidUnload];
}


@end
