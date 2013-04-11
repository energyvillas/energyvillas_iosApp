//
//  DPBuyViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPBuyViewController.h"
#import "UIApplication+ScreenDimensions.h"
#import "DPConstants.h"
#import <StoreKit/StoreKit.h>
#import "DPIAPHelper.h"
#import "DPAppHelper.h"
#import "DPConstants.h"
#import "DPCtgScrollViewController.h"
#import <UIKit/UIKit.h>
#import "DPBuyContentViewController.h"


@interface DPBuyViewController ()

//@property (strong, nonatomic) DPBuyContentViewController *contentController;
@property (strong) void (^onClose)(void);

@end

@implementation DPBuyViewController {
    int category;
    UIInterfaceOrientation uiio;
    
}

//@synthesize backView, contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (id) initWithCategoryId:(int)ctgid completion:(void (^)(void))completion {
    self = [super init];
    if (self) {
        category = ctgid;
        uiio = -1;
        self.onClose = completion;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view bringSubviewToFront:self.contentView];
    
    [self doLocalize];

    [self loadDetailView: NO];
}

- (void) doLocalize {
    [self.btnClose setTitle:DPLocalizedString(@"BUY_DLG_bbiClose_Title")
                 forState:UIControlStateNormal];
    
    [self.btnRestore setTitle:DPLocalizedString(@"BUY_DLG_btnRestore_Title")
                     forState:UIControlStateNormal];
    
    [self.btnBuy setTitle:@"€2.99" // TODO:GGSE :: DPLocalizedString(@"BUY_DLG_btnBuy_Title")
                 forState:UIControlStateNormal];
    
    [self doLayoutSubViews];

    if (self.innerView.subviews.count > 0)
        [self loadDetailView:YES];
}

- (void) removeBuyContent {
    if (self.innerView.subviews.count == 0) return;
    
    DPBuyContentViewController *contentController =
                (DPBuyContentViewController *)self.childViewControllers[0];
    
    [contentController.view removeFromSuperview];
    [contentController removeFromParentViewController];
}

- (void) loadDetailView:(BOOL)reload {
    if (reload)
        [self removeBuyContent];
    
    DPBuyContentViewController *contentController;
    if (self.innerView.subviews.count == 0) {
        contentController = [[DPBuyContentViewController alloc] initWithCategory:category];
        
        [self addChildViewController: contentController];
        [self.innerView addSubview: contentController.view];        
    } else {
        contentController = (DPBuyContentViewController *)self.childViewControllers[0];
        [contentController changeRows:1 columns:1];
    }
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
//    CGSize nextViewSize = [UIApplication sizeInOrientation:toInterfaceOrientation];
//    self.view.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);

}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];   //it hides
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self layoutForOrientation:INTERFACE_ORIENTATION fixtop:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];    // it shows
    [super viewWillDisappear:animated];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self doLayoutSubViews];
}

-(void) doLayoutSubViews {
    
    if (uiio == INTERFACE_ORIENTATION) return;
    uiio = INTERFACE_ORIENTATION;
    
    CGSize nextViewSize = [UIApplication sizeInOrientation:INTERFACE_ORIENTATION];
    self.backView.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);//self.view.bounds;

    CGRect cf;
    if (IS_IPHONE) {
        cf = CGRectMake(0, IS_PORTRAIT ? 18 - PAGE_CONTROL_HEIGHT : 18,
                        nextViewSize.width, nextViewSize.height);
    } else if (IS_IPHONE_5) {
        cf = CGRectMake(0, IS_PORTRAIT ? 105 - PAGE_CONTROL_HEIGHT : 18,
                        nextViewSize.width, nextViewSize.height);        
    } else if (IS_IPAD) {
        cf = CGRectMake(0, IS_PORTRAIT ? 170 - PAGE_CONTROL_HEIGHT : 120 - PAGE_CONTROL_HEIGHT,
                        nextViewSize.width, nextViewSize.height);
    }
    
    self.contentView.frame = cf;

    // toolbar
    NSString *dlgImgName = category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_01.png" : @"BuyDialog/Buy_our_app_01.png";
    UIImage *img = [UIImage imageNamed:dlgImgName];
    CGRect frm = CGRectMake(0, 0,
                            img.size.width, img.size.height);
    self.toolbar.frame = frm;
    self.toolbar.image = img;
    
    int BTN_HEIGHT = 22;
    // btn close
    [self.btnClose sizeToFit];
    self.btnClose.frame = CGRectMake(frm.origin.x + 10,
                                     (frm.size.height - BTN_HEIGHT /*self.btnClose.bounds.size.height*/) / 2,
                                     self.btnClose.bounds.size.width,
                                     BTN_HEIGHT /*self.btnClose.bounds.size.height*/);

    // btn Restore
    [self.btnRestore sizeToFit];
    self.btnRestore.frame = CGRectMake(frm.origin.x + frm.size.width -
                                       self.btnRestore.bounds.size.width - 10,
                                       (frm.size.height - BTN_HEIGHT /*self.btnRestore.bounds.size.height*/) / 2,
                                       self.btnRestore.bounds.size.width,
                                       BTN_HEIGHT /*self.btnRestore.bounds.size.height*/);
    
    // center
    dlgImgName = category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_02.png" : @"BuyDialog/Buy_our_app_02.png";
    img = [UIImage imageNamed:dlgImgName];
    frm = CGRectMake(0, frm.origin.y + frm.size.height,
                     img.size.width, img.size.height);
    self.innerView.frame = frm;
    self.innerView.backgroundColor = [UIColor colorWithPatternImage:img];
    
    // buy btn
    dlgImgName = category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_03.png" : @"BuyDialog/Buy_our_app_03.png";
    img = [UIImage imageNamed:[self calcImageName:dlgImgName
                                      isHighlight:NO ]];
    frm = CGRectMake(0, frm.origin.y + frm.size.height,
                     img.size.width, img.size.height);
    self.btnBuy.frame = frm;
    [self.btnBuy setBackgroundImage:img forState:UIControlStateNormal];
    img = [UIImage imageNamed:[self calcImageName:dlgImgName
                                      isHighlight:YES ]];
    [self.btnBuy setBackgroundImage:img forState:UIControlStateHighlighted];
    
    CGFloat fntSize = IS_IPAD ? 44.0 : 28.0;
    if (category == CTGID_EXCLUSIVE)
        fntSize = IS_IPAD ? 44.0 : 26.0;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:fntSize];

    UIColor *textColor = category == CTGID_EXCLUSIVE
            ? [UIColor colorWithRed:226/256.0 green:109/256.0 blue:51/256.0 alpha:1.0]
            : [UIColor whiteColor];
    [self.btnBuy setTitleColor:textColor forState:UIControlStateNormal];
    [self.btnBuy setTitleColor:textColor forState:UIControlStateHighlighted];

    self.btnBuy.titleLabel.font = font;
    NSString *btnTitle = self.btnBuy.titleLabel.text;

    CGSize lblsize = [btnTitle sizeWithFont:font];
    int start = IS_IPAD ? 26 : 8;
    int width = IS_IPAD ? 108 : 70;
    if (category == CTGID_EXCLUSIVE) {
        start = IS_IPAD ? 10 : 0;
        width = IS_IPAD ? 90 : 60;
    }
    start = start + (width - lblsize.width) / 2;
    [self.btnBuy setTitleEdgeInsets:UIEdgeInsetsMake(0, start, 0, 0)];

    // container
    cf = CGRectMake((nextViewSize.width - frm.size.width) / 2,
                     cf.origin.y,
                     frm.size.width,
                     frm.origin.y + frm.size.height);
    self.contentView.frame = cf;
}

- (NSString *) calcImageName:(NSString *)baseName {
    return [self calcImageName:baseName isHighlight:NO];
}
- (NSString *) calcImageName:(NSString *)baseName isHighlight:(BOOL)ishighlight {
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            //NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            NSString *high = ishighlight ? @"_roll" : @"";
            NSString *lang = [DPAppHelper sharedInstance].currentLang;
            NSString *result = [NSString stringWithFormat:@"%@%@_%@.%@",
                                parts[0], high, lang, parts[1]];
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

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation fixtop:(BOOL)fixtop{
    return;
    
//    CGSize nextViewSize = [UIApplication sizeInOrientation:toOrientation];
//    self.view.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);
//    self.backView.frame = self.view.frame;
//    
//    int PHONE_W = 280;
//    int PHONE_H = 250;
//    
//    int PAD_W = 680;
//    int PAD_H = PAD_W * PHONE_H / PHONE_W;
//    
//    int toolbarHeight = self.toolbar.frame.size.height;
//    if (toolbarHeight == 0)
//        toolbarHeight = 44;
//
//    CGRect cf;
//    if (IS_IPHONE || IS_IPHONE_5) {
//        cf = CGRectMake((nextViewSize.width - PHONE_W) / 2,
//                               (nextViewSize.height - PHONE_H) / 2,
//                               PHONE_W, PHONE_H);
//    } else {
//        cf = CGRectMake((nextViewSize.width - PAD_W) / 2,
//                               (nextViewSize.height - PAD_H) / 2,
//                               PAD_W, PAD_H);
//    }
//
//    self.contentView.frame = cf;
//    self.toolbar.frame = CGRectMake(0, 0, cf.size.width, toolbarHeight);
//    self.innerView.frame = CGRectMake(0, toolbarHeight,
//                                      cf.size.width, cf.size.height - toolbarHeight - 40);
//    
//    self.bbiTitle.width = cf.size.width - 80;
//    [self.btnBuy sizeToFit];
//    [self.btnRestore sizeToFit];
//    CGRect br = self.btnBuy.frame;
//    CGRect rr = self.btnRestore.frame;
//    
//    br = CGRectInset(br, -8, -2);
//    rr = CGRectInset(rr, -8, -2);
//
//    br.origin = CGPointMake((cf.size.width - br.size.width - rr.size.width - 8) / 2,
//                            cf.size.height - br.size.height - 8);
//    
//    rr.origin = CGPointMake(br.origin.x + br.size.width + 8,
//                            cf.size.height - rr.size.height - 8);
//    
//    self.btnBuy.frame = br;
//    
//    self.btnRestore.frame = rr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTouchUpInside:(id)sender forEvent:(UIEvent *)event {
    if (sender == self.btnClose) {
//        [self.presentingViewController dismissModalViewControllerAnimated:YES];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (self.onClose != nil)
            self.onClose();
    } else if (sender == self.btnBuy) {
        NSLog(@"buy tapped");
//        SKProduct *product = [[SKProduct alloc] init];
//        //product.
//        [[DPIAPHelper sharedInstance] buyProduct:product];
    } else if (sender == self.btnRestore) {
        NSLog(@"restore tapped");
//        SKProduct *product = [[SKProduct alloc] init];
//        //product.
//        [[DPIAPHelper sharedInstance] buyProduct:product];
    }
}

- (void)viewDidUnload {
    [self removeBuyContent];
    [self setBackView:nil];
    [self setContentView:nil];
    [self setInnerView:nil];
    [self setToolbar:nil];
    [self setBtnBuy:nil];
    [self setBtnClose:nil];
    [self setBtnRestore:nil];
    self.onClose = nil;
    [super viewDidUnload];
}
@end
