//
//  DPBuyViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import "DPBuyViewController.h"
#import "UIApplication+ScreenDimensions.h"
#import "DPConstants.h"
#import "DPIAPHelper.h"
#import "DPAppHelper.h"
#import "DPConstants.h"
#import "DPBuyContentViewController.h"


@interface DPBuyViewController ()

@property (strong, nonatomic) DPBuyContentViewController *buyContentController;
@property (strong) void (^onClose)(void);
@property (strong, nonatomic) SKProduct *product;

@end

@implementation DPBuyViewController {
    CGRect actualFrame;
}

@synthesize category = _category;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (id) initWithCategoryId:(int)ctgid
                  product:(SKProduct *)aProduct
               completion:(void (^)(void))completion {
    self = [super init];
    if (self) {
        _category = ctgid;
        self.product = aProduct;
        self.onClose = completion;
    }
    return self;
}

- (void) dealloc {
    self.backView = nil;
    self.contentView = nil;
    self.innerView = nil;
    self.toolbar = nil;
    self.btnBuy = nil;
    self.btnRestore = nil;
    self.btnClose = nil;
    
    self.buyContentController = nil;
    self.onClose = nil;
    self.product = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    actualFrame = CGRectZero;
    
    [self.view bringSubviewToFront:self.contentView];
    
    [self doLocalize];
    [self prepareButtons];
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    if (IS_IPAD)
        [self doLayoutSubViews:NO];
}

- (void) doLocalize {
    [self.btnClose setTitle:DPLocalizedString(@"BUY_DLG_bbiClose_Title")
                 forState:UIControlStateNormal];
    
    [self.btnRestore setTitle:DPLocalizedString(@"BUY_DLG_btnRestore_Title")
                     forState:UIControlStateNormal];
    
    [self.btnBuy setTitle:[self buyBtnTitle] // TODO:GGSE
                 forState:UIControlStateNormal];
}

- (NSString *) buyBtnTitle {
    return [NSString stringWithFormat:@"%@", self.product.localizedPrice];
    //return [NSString stringWithFormat:@"%@", @"2"];
}

-(void) prepareButtons {
    [self prepareBuyBtn];
    [self prepareCloseAndRestoreBtn:self.btnClose];
    [self prepareCloseAndRestoreBtn:self.btnRestore];
}

-(void) prepareBuyBtn {
    CGFloat fntSize = IS_IPAD ? 44.0 : 28.0;
    if (self.category == CTGID_EXCLUSIVE)
        fntSize = IS_IPAD ? 44.0 : 26.0;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold"
                                   size:fntSize];
    
    UIColor *textColor = self.category == CTGID_EXCLUSIVE
    ? [UIColor colorWithRed:226/256.0 green:109/256.0 blue:51/256.0 alpha:1.0]
    : [UIColor whiteColor];
    [self.btnBuy setTitleColor:textColor forState:UIControlStateNormal];
    [self.btnBuy setTitleColor:textColor forState:UIControlStateHighlighted];
    
    int start = IS_IPAD ? 20 : IS_IPHONE ? 6 : 6;
    int width = IS_IPAD ? 116 : IS_IPHONE ? 70 : 70;
    if (self.category == CTGID_EXCLUSIVE) {
        start = IS_IPAD ? 0 : IS_IPHONE ? 0 : 0;
        width = IS_IPAD ? 110 : IS_IPHONE ? 60 : 60;
    }
    
    NSString *btnTitle = [self buyBtnTitle];
    CGFloat actualFontSize;
    CGSize lblsize = [btnTitle sizeWithFont:font minFontSize:fntSize*0.5 actualFontSize:&actualFontSize forWidth:width lineBreakMode:NSLineBreakByWordWrapping];
    start = start + (width - lblsize.width) / 2;
    
    font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold"
                           size:actualFontSize];
    self.btnBuy.titleLabel.font = font;
    [self.btnBuy setTitleEdgeInsets:UIEdgeInsetsMake(0, start, 0, 0)];
}

-(void) prepareCloseAndRestoreBtn:(UIButton *)btn {
    NSString *btnTitle = btn.titleLabel.text;
    CGSize lblsize = [btnTitle sizeWithFont:btn.titleLabel.font];
    CGRect frm = btn.frame;
    frm = CGRectMake(0, 0, lblsize.width + 16, lblsize.height + 4);
    btn.frame = frm;

    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor blackColor];
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 1.5f;
    btn.layer.cornerRadius = 4.0f;
}

- (void) removeBuyContent {
    if (self.buyContentController != nil) {
        [self.buyContentController.view removeFromSuperview];
        [self.buyContentController removeFromParentViewController];
    }
}

- (void) loadDetailView:(BOOL)reload {
    if (reload)
        [self removeBuyContent];
    
    if (self.buyContentController == nil) {
        self.buyContentController = [[DPBuyContentViewController alloc] initWithCategory:self.category];
        
        self.buyContentController.view.frame = self.innerView.bounds;
        [self addChildViewController: self.buyContentController];
        [self.innerView addSubview: self.buyContentController.view];        
    } else {
        self.buyContentController.view.frame = self.innerView.bounds;
//        [self.buyContentController changeRows:1 columns:1];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];   //it hides
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];    // it shows
    [super viewWillDisappear:animated];
}


-(CGRect) calcFrame {
    [self internalLayoutSubViews];
    return actualFrame;
}

-(void) doLayoutSubViews:(BOOL)fixtop {
    [self internalLayoutSubViews];
    [self loadDetailView:NO];
}

-(void) internalLayoutSubViews {
        CGSize nextViewSize = [UIApplication sizeInOrientation:INTERFACE_ORIENTATION];
        if (IS_IPAD)
            self.backView.hidden = YES;
        else
            self.backView.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);
        
        CGRect cf;
        if (IS_IPHONE) {
            cf = CGRectMake(0, IS_PORTRAIT ? 18 - PAGE_CONTROL_HEIGHT : 18,
                            nextViewSize.width, nextViewSize.height);
        } else if (IS_IPHONE_5) {
            cf = CGRectMake(0, IS_PORTRAIT ? 105 - PAGE_CONTROL_HEIGHT : 18,
                            nextViewSize.width, nextViewSize.height);
        } else /*if (IS_IPAD)*/ {
            cf = CGRectMake(0, IS_PORTRAIT ? 165 - PAGE_CONTROL_HEIGHT : 180 - PAGE_CONTROL_HEIGHT,
                            nextViewSize.width, nextViewSize.height);
        }
        
        self.contentView.frame = cf;
        
        // toolbar
        NSString *dlgImgName = self.category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_01.jpg" : @"BuyDialog/Buy_our_app_01.jpg";
        UIImage *img = [UIImage imageNamed:dlgImgName];
        CGRect frm = CGRectMake(0, 0,
                                img.size.width, img.size.height);
        self.toolbar.frame = frm;
        self.toolbar.image = img;
        
        int BTN_HEIGHT = 22;
        // btn close
//        [self.btnClose sizeToFit];
        self.btnClose.frame = CGRectMake(frm.origin.x + 10,
                                         (frm.size.height - BTN_HEIGHT ) / 2,
                                         self.btnClose.bounds.size.width,
                                         BTN_HEIGHT );
        
        // btn Restore
//        [self.btnRestore sizeToFit];
        self.btnRestore.frame = CGRectMake(frm.origin.x + frm.size.width -
                                           self.btnRestore.bounds.size.width - 10,
                                           (frm.size.height - BTN_HEIGHT ) / 2,
                                           self.btnRestore.bounds.size.width,
                                           BTN_HEIGHT );
        
        // center
        dlgImgName = self.category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_02.jpg" : @"BuyDialog/Buy_our_app_02.jpg";
        img = [UIImage imageNamed:dlgImgName];
        frm = CGRectMake(0, frm.origin.y + frm.size.height,
                         img.size.width, img.size.height);
        self.innerView.frame = frm;
        self.innerView.backgroundColor = [UIColor colorWithPatternImage:img];
        
        // buy btn
        dlgImgName = self.category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_03.jpg" : @"BuyDialog/Buy_our_app_03.jpg";
        img = [UIImage imageNamed:[self calcImageName:dlgImgName
                                          isHighlight:NO ]];
        frm = CGRectMake(0, frm.origin.y + frm.size.height,
                         img.size.width, img.size.height);
        self.btnBuy.frame = frm;
        [self.btnBuy setBackgroundImage:img forState:UIControlStateNormal];
        img = [UIImage imageNamed:[self calcImageName:dlgImgName
                                          isHighlight:YES ]];
        [self.btnBuy setBackgroundImage:img forState:UIControlStateHighlighted];
            
        // container
        if (IS_IPAD)
            cf = CGRectMake(0, 0,
                            frm.size.width,
                            frm.origin.y + frm.size.height);
        else
            cf = CGRectMake((nextViewSize.width - frm.size.width) / 2,
                            cf.origin.y,
                            frm.size.width,
                            frm.origin.y + frm.size.height);
        
        self.contentView.frame = cf;
    self.contentView.layer.cornerRadius = 4.0f;
    self.contentView.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.8f].CGColor;
    self.contentView.layer.borderWidth = IS_IPAD ? 3.0f : 1.5f;
    
        if (IS_IPAD) {
            actualFrame = CGRectMake((nextViewSize.width - cf.size.width) / 2,
                                     cf.origin.y,
                                     cf.size.width,
                                     cf.size.height);
        }
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
        NSLog(@"Uncaught exception: %@", exception.debugDescription);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        return baseName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTouchUpInside:(id)sender forEvent:(UIEvent *)event {
    if (sender == self.btnClose) {
        [[DPAppHelper sharedInstance] playSoundSpitSplat];
    } else if (sender == self.btnBuy) {
        NSLog(@"buy tapped");
        
        DPIAPHelper *iap = [DPIAPHelper sharedInstance];
        
        if (![iap canMakePurchases])
            showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), @"Cannot make purchase at the moment. Please try later!");
        else {
            [iap buy];
            [[DPAppHelper sharedInstance] playSoundBip];// playSoundElectricalSweep];
        }
    } else if (sender == self.btnRestore) {
        NSLog(@"restore tapped");
        DPIAPHelper *iap = [DPIAPHelper sharedInstance];
        if (![iap canMakePurchases])
            showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), @"Cannot restore purchase at the moment. Please try later!");
        else {
            [iap restoreCompletedTransactions];
            [[DPAppHelper sharedInstance] playSoundBip];// playSoundElectricalSweep];
        }
    }
    
    if (IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
    
    if (self.onClose != nil)
        self.onClose();
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

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
