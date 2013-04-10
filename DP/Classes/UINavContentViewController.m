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

@interface UINavContentViewController ()

@property (strong, nonatomic) UIButton *navbarTitleItemButton;
@property (strong, nonatomic) UIButton *navbarLang_EN;
@property (strong, nonatomic) UIButton *navbarLang_EL;

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
    [self layoutForOrientation:INTERFACE_ORIENTATION fixtop:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [self langSelected];
    [super viewDidAppear:animated];
}

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation fixtop:(BOOL)fixtop {
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
/*
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForOrientation:toInterfaceOrientation fixtop:YES];
}
*/
/*
- (UIButton *) createButtonWithImageUrl:(NSURL *)imgUrl
                                 tag:(int)index
                              action:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (sel)
        [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIImage *img = [UIImage imageNamed: imgName];
    button.frame = CGRectMake(0, 0, img.size.width, 30);
    [button setImage: img forState:UIControlStateNormal];
    [button setTag: index];
    
    return button;
}
*/

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

NSString *const NAVBAR_BACK_IMG = @"Navbar/back_arrow.png";
NSString *const NAVBAR_BACK_SEL_IMG = @"Navbar/back_arrow_rol.png";

NSString *const NAVBAR_LOGO_IMG_FMT = @"Navbar/logo_%@.png";

NSString *const NAVBAR_LANG_EN_IMG = @"Navbar/lang_en.png";
NSString *const NAVBAR_LANG_EN_SEL_IMG = @"Navbar/lang_en_roll.png";

NSString *const NAVBAR_LANG_EL_IMG = @"Navbar/lang_el.png";
NSString *const NAVBAR_LANG_EL_SEL_IMG = @"Navbar/lang_el_roll.png";

NSString *const NAVBAR_FAV_IMG = @"Navbar/fav.png";
NSString *const NAVBAR_FAV_SEL_IMG = @"Navbar/fav_roll.png";

NSString *const NAVBAR_SHARE_IMG = @"Navbar/share.png";
NSString *const NAVBAR_SHARE_SEL_IMG = @"Navbar/share_roll.png";

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


- (void) setupNavBar {
    if (!self.navigationController) return;
    
    self.navigationItem.title = nil;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.hidesBackButton = YES;

    bool ischild = self.navigationController.viewControllers[0] != self &&
                    self.navigationController.topViewController == self;
    
    self.navbarTitleItemButton = [self
                                  createButtonWithImage: [self calcTitleImageName]
                                  highlightedImage: [self calcTitleImageName]
                                  tag:0
                                  action:nil];

    if (ischild) {
        self.navigationItem.leftBarButtonItems = @[
                                                   [[UIBarButtonItem alloc]
                                                    initWithCustomView: [self
                                                                         createButtonWithImage:[self calcImageName:NAVBAR_BACK_IMG]
                                                                         highlightedImage: [self calcImageName:NAVBAR_BACK_SEL_IMG]
                                                                         tag:TAG_NBI_BACK
                                                                         action:@selector(onNavButtonTapped:)]],
                                                   
                                                   [[UIBarButtonItem alloc]
                                                    initWithCustomView: self.navbarTitleItemButton]
                                                   ];
    }
    else
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc]
                                                    initWithCustomView: self.navbarTitleItemButton]];
    
    UIView *rightButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    
    self.navbarLang_EL = [self
                          createButtonWithImage:NAVBAR_LANG_EL_IMG
                          highlightedImage:NAVBAR_LANG_EL_SEL_IMG
                          frame:CGRectMake(0, 7, 30, 30)
                          tag:TAG_NBI_LANG_EL
                          action:@selector(onNavButtonTapped:)];
    [rightButtons addSubview: self.navbarLang_EL];
    
    self.navbarLang_EN = [self
                          createButtonWithImage:NAVBAR_LANG_EN_IMG
                          highlightedImage:NAVBAR_LANG_EN_SEL_IMG
                          frame:CGRectMake(30, 7, 30, 30)
                          tag:TAG_NBI_LANG_EN
                          action:@selector(onNavButtonTapped:)];
    [rightButtons addSubview: self.navbarLang_EN];
    
    [rightButtons addSubview:[self
                              createButtonWithImage:NAVBAR_FAV_IMG
                              highlightedImage:NAVBAR_FAV_SEL_IMG
                              frame:CGRectMake(60, 7, 30, 30)
                              tag:TAG_NBI_ADD_FAV
                              action:@selector(onNavButtonTapped:)]];
    
    [rightButtons addSubview:[self
                              createButtonWithImage:NAVBAR_SHARE_IMG
                              highlightedImage:NAVBAR_SHARE_SEL_IMG
                              frame:CGRectMake(90, 7, 30, 30)
                              tag:TAG_NBI_SHARE
                              action:@selector(onNavButtonTapped:)]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView: rightButtons];
    
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
        button.frame = CGRectMake(0, (44 - img.size.height) / 2 , img.size.width, img.size.height);
    else
        button.frame = aFrame;
    
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

// PENDING use a delegate protocol form handling clicks
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
            // do stuff
            break;
            
        case TAG_NBI_SHARE:
            // do stuff
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
