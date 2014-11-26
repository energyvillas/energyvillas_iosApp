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
#import "DPMailHelper.h"
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
    int prevBackgroundCategory;
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
	self.tabBar.TintColor = [UIColor greenColor];
	self.tabBar.barTintColor = [UIColor blackColor];
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
		[self prepareVideoPlayerNotification];
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
- (void)navigationController:(UINavigationController *)navigationController
      didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (viewController == navigationController.viewControllers[0]) {
        [viewController.view setNeedsDisplay];
        [viewController.view setNeedsLayout];
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self fixBackgroundImage];
    
    [self doFixFrames:self.navController.topViewController fixTop:NO];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[self setNeedsStatusBarAppearanceUpdate];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

-(void) doFixFrames:(UIViewController *)viewController fixTop:(BOOL)fixtop {
    [self clearPopups];

    [self fixFrames:NO];
    if (viewController && [viewController isKindOfClass:[UINavContentViewController class]])

    [viewController.view setNeedsDisplay];
}

void NSLogRect(NSString *msg, CGRect rect) {
	NSLog(@"%@ :: (x, y, w, h) = (%f, %f, %f, %f)",
		  msg,
		  rect.origin.x, rect.origin.y,
		  rect.size.width, rect.size.height);
}

void LogDevInfo() {
	UIDevice* devc = [UIDevice  currentDevice];
	UIScreen* scrn = [UIScreen mainScreen];
	UIWindow* wind = [UIApplication sharedApplication].keyWindow;
	NSLog(@"Device name %@", devc.name);
	NSLog(@"Device model %@", devc.model);
	NSLog(@"Device model lc %@", devc.localizedModel);
	NSLog(@"Device System Name %@", devc.systemName);
	NSLog(@"Device System Version %@", devc.systemVersion);
	NSLog(@"Device Type %@", IS_IPAD ? @"iPad" : (IS_IPHONE ? @"iPhone" : (IS_IPHONE_5 ? @"iPhone 5" : @"Unknown!!!")));
	NSLogRect(@"SCR-B", scrn.bounds);
	NSLogRect(@"WND-F", wind.frame);
	NSLogRect(@"WND-B", wind.bounds);
	NSLogRect(@"SCR-APP_FRM", scrn.applicationFrame);
}

-(void) videoPlayerFinished {
	LogDevInfo();

	if (!Is_iOS_Version_LessThan(@"8")) {
		[self fixFrames:YES];

		CGRect r = self.navController.topViewController.view.frame;
		if (r.origin.y > 45) {
			r.origin.y -= 20.0f;
			r.size.height += 20.0f;
		}
		self.navController.topViewController.view.frame = r;
	}


	[self setNeedsStatusBarAppearanceUpdate];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

-(void) prepareVideoPlayerNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(videoPlayerFinished)
												 name:@"VIDEO_PALYER_FINISHED_NOTIFICATION"
											   object:nil];
}

- (void) fixFrames:(BOOL)fixNavView {
    if (fixNavView) {
		CGRect sf = [UIScreen mainScreen].applicationFrame;
		if (sf.origin.y < 1.0f) {
			sf.origin.y = 20.0f;
			sf.size.height -= 20.0f;
		}

		self.view.frame = sf;
        CGRect tbf = self.tabBar.frame;

		CGFloat yofs = Is_iOS_Version_LessThan(@"8") ? sf.origin.y : 0.0f;
		self.navController.view.frame = CGRectMake(0, yofs,
                                                   sf.size.width,
                                                   sf.size.height - tbf.size.height
												   - yofs
												   );
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

- (void) cleanControllers {
	self.ideaViewController = nil;
	self.realEstateViewController = nil;
	self.whoViewController = nil;
	self.franchiseViewController = nil;
	self.costViewController = nil;
	self.profitViewController = nil;
	self.materialsViewController = nil;
	self.planetViewController = nil;
	self.favoritesViewController = nil;
}

- (int) findTabViewControllerIndexInNavigator {
    int result = -1;
    int count = (int)self.navController.viewControllers.count;
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
        [self cleanControllers];
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
        if (self.navController.viewControllers.count > 1) {
            [self.navController popToRootViewControllerAnimated:NO];
            prevBackgroundCategory = 0;
            [[self.navController topViewController].view setNeedsDisplay];
            [[self.navController topViewController].view setNeedsLayout];
        }
    }
   
    [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                        object:nil
                                                      userInfo:@{@"menuCategory": @(prevBackgroundCategory)}];
}

- (void) showIdea {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
    if ([self checkTop:self.ideaViewController]) return;
    
    self.ideaViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_IDEA
                                                                 fromParent:CTGID_ROOT_CATEGORY
                                                              useDeviceType:YES];
    
    [self showViewController:self.ideaViewController];
}

- (void) showRealEstate {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
    if ([self checkTop:self.realEstateViewController]) return;
    
    self.realEstateViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_REAL_ETATE
                                                                       fromParent:CTGID_ROOT_CATEGORY
                                                                    useDeviceType:YES];
    
    [self showViewController:self.realEstateViewController];
}

- (void) showWho {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
    if ([self checkTop:self.whoViewController]) return;
    
    self.whoViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_WHO_WE_ARE
                                                                fromParent:CTGID_ROOT_CATEGORY
                                                             useDeviceType:YES];
    
    [self showViewController:self.whoViewController];
}

- (void) showFranchise {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
    if ([self checkTop:self.franchiseViewController]) return;
    
    self.franchiseViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_FRANCHISE
                                                                      fromParent:CTGID_ROOT_CATEGORY
                                                                   useDeviceType:YES];
    
    [self showViewController:self.franchiseViewController];
}

- (void) showCost {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
    if ([self checkTop:self.costViewController]) return;
    
    self.costViewController = [[DPHtmlContentViewController alloc]
             initWithCategory:CTGID_COST lang:CURRENT_LANG];
    
    [self showViewController:self.costViewController];
}


- (void) showProfit {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
    if ([self checkTop:self.profitViewController]) return;
    
    self.profitViewController = [[DPHtmlContentViewController alloc]
             initWithCategory:CTGID_PROFIT lang:CURRENT_LANG];
    
    [self showViewController:self.profitViewController];
}


- (void) showMaterials {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
    if ([self checkTop:self.materialsViewController]) return;
    
    self.materialsViewController = [[DPCTGViewController alloc] initWithCategory:CTGID_MATERIALS
                                                                      fromParent:CTGID_ROOT_CATEGORY
                                                                   useDeviceType:YES];

    
    [self showViewController:self.materialsViewController];
}

;
- (void) showPlanet {
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
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
    if ([self findTabViewControllerIndexInNavigator] == -1)
        prevBackgroundCategory = currentBackgroundCategory;
    
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
    DPCallUsViewController *callusVC = [[DPCallUsViewController alloc] init];

    [callusVC setCompletion:^(int tag) {
        self.dlgManager.modalController = nil;

        switch (tag) {
            case 100:
                [[DPAppHelper sharedInstance] playSoundSpitSplat];
                // cancelled... ok go on...
                break;
                
            case 101: {
                [[DPAppHelper sharedInstance] playSoundDialTone];
                
                double delayInSeconds = 2.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // make the call
                    NSString *telNo = [NSString stringWithFormat:@"%@", @"tel:+302103611150"];
                    telNo = [telNo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telNo]];
                });
                break;
            }
            case 102: {
                [[DPAppHelper sharedInstance] playSoundOpenSoda];
                // open mail composer
                [self composeEmail];
                break;
            }
        }
        
        [self fixSelectedTabBarItem];
        
        self.dlgManager = nil;
    }];
    
    if (!self.dlgManager)
		self.dlgManager = [[DPModalDialogManager alloc] init];
    [self.dlgManager showDialog:callusVC];
}

//==============================================================================
#pragma mark - eMail

-(void) composeEmail {
    if (![MFMailComposeViewController canSendMail]){
        showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), DPLocalizedString(kERR_MSG_UNABLE_TO_SEND_MAIL));
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
    MFMailComposeViewController *composer = [DPMailHelper composeEmail2Us];
    composer.mailComposeDelegate = self;
    if (!IS_IPAD) {
        [self presentModalViewController:composer
                                             animated:YES];
    } else {
		self.navController.modalPresentationStyle = UIModalPresentationPageSheet;
		[self.navController presentModalViewController:composer
                                                                animated:YES];
    }
    
    });
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void) mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
	[controller dismissModalViewControllerAnimated:YES];
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


- (void)viewDidUnload {
    [self removeNotificationObservers];
    
    self.navController = nil;
    
    self.tabBar = nil;
    self.tbiMain = nil;
    self.tbiIdea = nil;
    self.tbiRealEstate = nil;
    self.tbiCall = nil;
    self.tbiMore = nil;
    
    self.ideaViewController = nil;
    self.realEstateViewController = nil;
    
    self.whoViewController = nil;
    self.franchiseViewController = nil;
    self.costViewController = nil;
    self.profitViewController = nil;
    self.materialsViewController = nil;
    self.planetViewController = nil;
    self.favoritesViewController = nil;
    
    self.popupController = nil;
    self.popupContentViewController = nil;
    
    self.dlgManager = nil;

    [super viewDidUnload];
}

- (void) dealloc {
    self.navController = nil;
    
    self.tabBar = nil;
    self.tbiMain = nil;
    self.tbiIdea = nil;
    self.tbiRealEstate = nil;
    self.tbiCall = nil;
    self.tbiMore = nil;

    self.ideaViewController = nil;
    self.realEstateViewController = nil;
    
    self.whoViewController = nil;
    self.franchiseViewController = nil;
    self.costViewController = nil;
    self.profitViewController = nil;
    self.materialsViewController = nil;
    self.planetViewController = nil;
    self.favoritesViewController = nil;
    
    self.popupController = nil;
    self.popupContentViewController = nil;
    
    self.dlgManager = nil;
}

@end
