//
//  UINavContentViewController.m
//  testSV
//
//  Created by george on 16/3/13.
//  Copyright (c) 2013 george. All rights reserved.
//

#import <Quartzcore/Quartzcore.h>
#import "UINavContentViewController.h"
#import "Reachability.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "DPSocialManager.h"


@interface UINavContentViewController ()

@property (strong, nonatomic) UIButton *navbarTitleItemButton;
@property (strong, nonatomic) UIButton *navbarLang_EN;
@property (strong, nonatomic) UIButton *navbarLang_EL;
@property (strong, nonatomic) UIButton *navbarFavorite;
@property (strong, nonatomic) DPSocialManager *socialManager;

@end

@implementation UINavContentViewController 

- (void) hookToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:DPN_currentLangChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:DPN_FavoritesChangedNotification
                                               object:nil];
}

- (void) onNotified:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:DPN_currentLangChanged]) {
        NSLog (@"Successfully received the ==DPN_currentLangChanged== notification!");
        
        [self langSelected];
        [self doLocalize];
    }
    
    if ([[notification name] isEqualToString:kReachabilityChangedNotification]) {
        NSLog (@"Successfully received the ==kReachabilityChangedNotification== notification!");
        
        [self reachabilityChanged];
    }
    
    if ([[notification name] isEqualToString:DPN_FavoritesChangedNotification]) {
        NSLog (@"Successfully received the ==kReachabilityChangedNotification== notification!");
        
        [self fixFavsButton];
    }
}

- (void) reachabilityChanged {
    
}

- (void) doLocalize {
    NSString *titleImgName = [self calcTitleImageName];
    [self.navbarTitleItemButton setImage:[UIImage imageNamed: titleImgName]
                                forState:UIControlStateNormal];
    
    [self.navbarTitleItemButton setImage:[UIImage imageNamed: titleImgName]
                                forState:UIControlStateHighlighted];
    
    [self.navbarTitleItemButton setImage:[UIImage imageNamed: titleImgName]
                                forState:UIControlStateSelected];
}


- (void) viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];

    [self hookToNotifications];
    [self setupNavBar];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [self langSelected];
    [super viewDidAppear:animated];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self doLayoutSubViews:NO];
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) langSelected {
    if (self.navbarLang_EN && self.navbarLang_EL) {
        NSString *lng = [DPAppHelper sharedInstance].currentLang;
        UIButton *langSelControl = nil;
        if ([lng isEqualToString:@"el"])
            langSelControl = self.navbarLang_EL;
        else if ([lng isEqualToString:@"en"])
            langSelControl = self.navbarLang_EN;
        else // fall back to default
            langSelControl = self.navbarLang_EN;
        
        [self langSelControlPressed:langSelControl];
    }
}

- (void) langSelControlPressed:(id)sender {
    if (sender != nil) {
        UIButton *langSelControl = sender;
            if (langSelControl == self.navbarLang_EN) {
                [self.navbarLang_EN setImage:[UIImage imageNamed:NAVBAR_LANG_EN_SEL_IMG] forState:UIControlStateNormal];
                [self.navbarLang_EL setImage:[UIImage imageNamed:NAVBAR_LANG_EL_IMG] forState:UIControlStateNormal];
                [DPAppHelper sharedInstance].currentLang = @"en";
            }else if (langSelControl == self.navbarLang_EL) {
                [self.navbarLang_EN setImage:[UIImage imageNamed:NAVBAR_LANG_EN_IMG] forState:UIControlStateNormal];
                [self.navbarLang_EL setImage:[UIImage imageNamed:NAVBAR_LANG_EL_SEL_IMG] forState:UIControlStateNormal];
                [DPAppHelper sharedInstance].currentLang = @"el";
            }
    }
}

- (NSString *) calcTitleImageName {
    NSString *lang = [DPAppHelper sharedInstance].currentLang;
    NSString *imgName = [NSString stringWithFormat: NAVBAR_LOGO_IMG_FMT, lang];
    return imgName;
}

- (NSString *) calcImageName:(NSString *)baseName {
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *lang = [DPAppHelper sharedInstance].currentLang;
//            NSString *orientation = IS_PORTRAIT ? @"h" : @"h";  //PENDING
//            // pending also fix the format string below.... NSString *lang = [DPAppHelper sharedInstance].currentLang;
            NSString *result = [NSString stringWithFormat:@"%@_%@.%@", parts[0], lang, parts[1]];
            return result;
        }
        else
            return baseName;
    }
    @catch (NSException* exception) {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        return baseName;
    }
}

//==============================================================================
#pragma mark - nav bar button selection
- (BOOL) showNavBar {
    return self.navigationController != nil;
}
- (BOOL) showNavBarLanguages {
    return YES;
}
- (BOOL) showNavBarAddToFav {
    return NO;
}
- (BOOL) showNavBarSocial {
    return NO;
}
- (BOOL) showNavBarInfo {
    return YES;
}
- (BOOL) showNavBarNavigator {
    return self.navigatorDelegate != nil;
}
//==============================================================================

#pragma mark -

#define NAVBAR_BTN_WIDTH ((int)34)
#define NAVBAR_BTN_HEIGTH ((int)34)
#define NAVBAR_BTN_TOP ((int)5)

- (void) setupNavBar {
    if (![self showNavBar]) return;
    
    self.navigationItem.title = nil;
    self.navigationItem.leftItemsSupplementBackButton = NO;
    self.navigationItem.hidesBackButton = YES;

    bool ischild = self.navigationController.viewControllers[0] != self &&
                    self.navigationController.topViewController == self;
    
    UIView *leftButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    
    self.navbarTitleItemButton = [self createButtonWithImage: [self calcTitleImageName]
                                            highlightedImage: [self calcTitleImageName]
                                                       frame:CGRectZero
                                                         tag:0
                                                      action:nil];
    self.navbarTitleItemButton.userInteractionEnabled = NO;
    
    if (ischild) {
        UIButton *backBtn = [self createButtonWithImage:NAVBAR_BACK_IMG
                                       highlightedImage:NAVBAR_BACK_SEL_IMG
                                                  frame:CGRectZero 
                                                    tag:TAG_NBI_BACK
                                                 action:@selector(onNavButtonTapped:)];
        
        CGRect frm = CGRectMake(backBtn.frame.origin.x + backBtn.frame.size.width - 10,
                                NAVBAR_BTN_TOP,
                                self.navbarTitleItemButton.frame.size.width,
                                self.navbarTitleItemButton.frame.size.height);
        self.navbarTitleItemButton.frame = frm;
        
        [leftButtons addSubview: backBtn];
        [leftButtons addSubview: self.navbarTitleItemButton];

        self.navigationItem.leftBarButtonItems = @[
                                                   [[UIBarButtonItem alloc] initWithCustomView: leftButtons]
                                                   ];
    }
    else
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc]
                                                    initWithCustomView: self.navbarTitleItemButton]];
    
    UIView *rightButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    int pos = 0;
    if ([self showNavBarLanguages]) {
        self.navbarLang_EL = [self
                              createButtonWithImage:NAVBAR_LANG_EL_IMG
                              highlightedImage:NAVBAR_LANG_EL_SEL_IMG
                              frame:CGRectMake(pos, NAVBAR_BTN_TOP, NAVBAR_BTN_WIDTH, NAVBAR_BTN_HEIGTH)
                              tag:TAG_NBI_LANG_EL
                              action:@selector(onNavButtonTapped:)];
        [rightButtons addSubview: self.navbarLang_EL];
        pos += NAVBAR_BTN_WIDTH;
        
        self.navbarLang_EN = [self
                              createButtonWithImage:NAVBAR_LANG_EN_IMG
                              highlightedImage:NAVBAR_LANG_EN_SEL_IMG
                              frame:CGRectMake(pos, NAVBAR_BTN_TOP, NAVBAR_BTN_WIDTH, NAVBAR_BTN_HEIGTH)
                              tag:TAG_NBI_LANG_EN
                              action:@selector(onNavButtonTapped:)];
        [rightButtons addSubview: self.navbarLang_EN];
        pos += NAVBAR_BTN_WIDTH;
    }
    
    if ([self showNavBarAddToFav]) {
        BOOL inFavs = [self isInFavorites];
        NSString *favImgName = inFavs ? NAVBAR_FAV_SEL_IMG : NAVBAR_FAV_IMG;
        self.navbarFavorite = [self createButtonWithImage:favImgName
                                                    frame:CGRectMake(pos, NAVBAR_BTN_TOP, NAVBAR_BTN_WIDTH, NAVBAR_BTN_HEIGTH)
                                                      tag:TAG_NBI_ADD_FAV
                                                   action:@selector(onNavButtonTapped:)];
        [rightButtons addSubview:self.navbarFavorite];
        pos += NAVBAR_BTN_WIDTH;
    }
    
    if ([self showNavBarSocial]) {
        [rightButtons addSubview:[self
                                  createButtonWithImage:NAVBAR_SHARE_IMG
                                  highlightedImage:NAVBAR_SHARE_SEL_IMG
                                  frame:CGRectMake(pos, NAVBAR_BTN_TOP, NAVBAR_BTN_WIDTH, NAVBAR_BTN_HEIGTH)
                                  tag:TAG_NBI_SHARE
                                  action:@selector(onNavButtonTapped:)]];
        pos += NAVBAR_BTN_WIDTH;
    }
    
    if ([self showNavBarNavigator]) {
        CGFloat topOfs = 5.0f, vlineGap = 2.0f;
        UIColor *bordersColor = [UIColor whiteColor];
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(pos,
                                                                     NAVBAR_BTN_TOP + topOfs,
                                                                     2 * NAVBAR_BTN_WIDTH + 1.0f, // for vLine
                                                                     NAVBAR_BTN_HEIGTH - 2 * topOfs)];
        container.contentMode = UIViewContentModeCenter;
        container.backgroundColor = [UIColor clearColor];
        
        UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(NAVBAR_BTN_WIDTH,
                                                                 vlineGap,
                                                                 1.0f,
                                                                 NAVBAR_BTN_HEIGTH - 2 * (topOfs + vlineGap))];
        vLine.layer.borderWidth = 1.0f;
        vLine.layer.borderColor = bordersColor.CGColor;
        [container addSubview:vLine];
//        UIImageView *borderView = [[UIImageView alloc] initWithFrame:container.bounds];
//        borderView.contentMode = UIViewContentModeCenter;
//        borderView.image = [UIImage imageNamed:NAVBAR_PREVNEXT_BORDER_IMG];
//        [container addSubview:borderView];
        
        UIButton *prevBtn = [self
                             createButtonWithImage:NAVBAR_PREV_IMG
                             highlightedImage:NAVBAR_PREV_SEL_IMG
                             frame:CGRectMake(0, 0,
                                              NAVBAR_BTN_WIDTH, NAVBAR_BTN_HEIGTH - 2 * topOfs)
                             tag:TAG_NBI_PREV
                             action:@selector(onNavButtonTapped:)];
        [container addSubview:prevBtn];
        
        UIButton *nextBtn = [self
                             createButtonWithImage:NAVBAR_NEXT_IMG
                             highlightedImage:NAVBAR_NEXT_SEL_IMG
                             frame:CGRectMake(NAVBAR_BTN_WIDTH + 1.0f, // for vLine
                                              0,
                                              NAVBAR_BTN_WIDTH,
                                              NAVBAR_BTN_HEIGTH - 2 * topOfs)
                             tag:TAG_NBI_NEXT
                             action:@selector(onNavButtonTapped:)];
        [container addSubview:nextBtn];
        
//        prevBtn.layer.cornerRadius = 6.0f;
//        prevBtn.layer.borderWidth = 1.0f;
//        prevBtn.layer.borderColor = bordersColor.CGColor;
//        nextBtn.layer.cornerRadius = 6.0f;
//        nextBtn.layer.borderWidth = 1.0f;
//        nextBtn.layer.borderColor = bordersColor.CGColor;
        container.layer.cornerRadius = 6.0f;
        container.layer.borderWidth = 1.0f;
        container.layer.borderColor = bordersColor.CGColor;
        
        [rightButtons addSubview:container];
        
        pos += 2 * NAVBAR_BTN_WIDTH;
    }
    
    if (pos > 0) {
        rightButtons.frame = CGRectMake(0, 0, pos, 44);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView: rightButtons];
    }
    [self langSelected];
}

- (UIButton *) createButtonWithImage:(NSString *)imgName
                               frame:(CGRect)aFrame
                                 tag:(int)index
                              action:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (sel)
        [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *img = [UIImage imageNamed: imgName];
     
    if (CGRectEqualToRect(aFrame, CGRectZero))
        aFrame = CGRectMake(0, (44 - img.size.height) / 2 , img.size.width, img.size.height);

    button.frame = aFrame;
    button.contentMode = UIViewContentModeCenter;
    
    [button setImage: img forState:UIControlStateNormal];
    [button setTag: index];
    
    return button;
}

- (UIButton *) createButtonWithImage:(NSString *)imgName
                                 tag:(int)index
                              action:(SEL)sel {
    return [self createButtonWithImage:imgName frame:CGRectZero
                                   tag:index action:sel];
}

- (UIButton *) createButtonWithImage:(NSString *)imgName
                    highlightedImage:(NSString *)imgNameHigh
                                frame:(CGRect)aFrame
                                 tag:(int)index
                              action:(SEL)sel {
    UIButton *button = [self createButtonWithImage:imgName frame:aFrame tag:index action:sel];
    [button setImage:[UIImage imageNamed: imgNameHigh] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed: imgNameHigh] forState:UIControlStateSelected];
    
    return button;
}

- (UIButton *) createButtonWithImage:(NSString *)imgName
                    highlightedImage:(NSString *)imgNameHigh
                                 tag:(int)index
                              action:(SEL)sel {
    UIButton *button = [self createButtonWithImage:imgName tag:index action:sel];
    [button setImage:[UIImage imageNamed: imgNameHigh] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed: imgNameHigh] forState:UIControlStateSelected];
    
    return button;
}

-(BOOL) doOnTapped:(id)sender {
    if (self.actionDelegate) {
        [self.actionDelegate onTapped:sender];
        return YES;
    }
    return NO;
}

- (void) doNavigate:(BOOL)next {
    if (self.navigatorDelegate) {
        if (next)
            [self.navigatorDelegate next];
        else
            [self.navigatorDelegate prev];
    }
}

// PENDING use a delegate protocol for handling clicks
- (void) onNavButtonTapped: (id) sender {
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    if (bbi == nil) return;
    
    switch (bbi.tag) {
        case TAG_NBI_LANG_EN:
        case TAG_NBI_LANG_EL:
            [self langSelControlPressed:sender];
            break;
            
        case TAG_NBI_BACK:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case TAG_NBI_ADD_FAV:
            [self toggleInFavorites];
            [self fixFavsButton];
            break;
            
        case TAG_NBI_SHARE:
            [self showSocialsDialog];
            break;
            
        case TAG_NBI_PREV:
            [self doNavigate:NO];
            break;
            
        case TAG_NBI_NEXT:
            [self doNavigate:YES];
            break;
            
        default:
            break;
    }
}

- (BOOL) isInFavorites {
    return NO;
}

- (void) toggleInFavorites {
}

- (void) fixFavsButton {
    NSString *favImgName = [self isInFavorites] ? NAVBAR_FAV_SEL_IMG : NAVBAR_FAV_IMG;
    [self.navbarFavorite setImage:[UIImage imageNamed:favImgName]
                         forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) aquireImageTitleToShare {
    return nil;
}

- (NSString *) aquireImageUrlToShare {
    return nil;
}

- (void) showSocialsDialog {
    if (!self.socialManager)
        self.socialManager = [[DPSocialManager alloc] initWithController:self
                                                          onSocialClosed:nil];

    [DPAppHelper sharedInstance].imageTitle2Share = [self aquireImageTitleToShare];
    [DPAppHelper sharedInstance].imageUrl2Share = [self aquireImageUrlToShare];
   
    [self.socialManager showSocialsDialog:nil];
}

@end
