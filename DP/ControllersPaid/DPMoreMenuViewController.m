//
//  DPMoreMenuViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMoreMenuViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"

#define TBI_MORE_BTN_ALL_COUNT ((int)7)
#define TBI_MORE_BTN_VISIBLE_COUNT ((int)3)

#define TBI_MORE_HEIGHT ((int)49)

#define TBI_MORE_WIDTH_PORTAIT_IPHONE ((CGFloat)64)
#define TBI_MORE_WIDTH_LANDSCAPE_IPHONE ((CGFloat)96)

#define TBI_MORE_WIDTH_PORTAIT_IPHONE5 ((CGFloat)64)
#define TBI_MORE_WIDTH_LANDSCAPE_IPHONE5 ((CGFloat)113.6)

#define TBI_MORE_WIDTH_PORTAIT_IPAD ((CGFloat)80)
#define TBI_MORE_WIDTH_LANDSCAPE_IPAD ((CGFloat)80)


#define TBI_MORE_ORIGIN_X_PORTRAIT_IPHONE ((CGFloat)256)
#define TBI_MORE_ORIGIN_X_LANDSCAPE_IPHONE ((CGFloat)384)

#define TBI_MORE_ORIGIN_X_PORTRAIT_IPHONE5 ((CGFloat)256)
#define TBI_MORE_ORIGIN_X_LANDSCAPE_IPHONE5 ((CGFloat)454.4)

#define TBI_MORE_ORIGIN_X_PORTRAIT_IPAD ((CGFloat)564)
#define TBI_MORE_ORIGIN_X_LANDSCAPE_IPAD ((CGFloat)692)

@interface DPMoreMenuViewController ()

@end

@implementation DPMoreMenuViewController

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
    self.title = nil;
    CGSize btnSize = [self calcBtnSize];    
    self.scrollView.contentSize = CGSizeMake(btnSize.width, TBI_MORE_BTN_ALL_COUNT * btnSize.height);
    [self prepareButtons];
    [self doLocalize];
}

- (CGSize) calcBtnSize {
    CGFloat sizeX = 0;
    if (IS_IPHONE) {
        sizeX = IS_PORTRAIT ? TBI_MORE_WIDTH_PORTAIT_IPHONE : TBI_MORE_WIDTH_LANDSCAPE_IPHONE;
    } else if (IS_IPHONE_5) {
        sizeX = IS_PORTRAIT ? TBI_MORE_WIDTH_PORTAIT_IPHONE5 : TBI_MORE_WIDTH_LANDSCAPE_IPHONE5;
    } else { // if (IS_IPAD)
        sizeX = IS_PORTRAIT ? TBI_MORE_WIDTH_PORTAIT_IPAD : TBI_MORE_WIDTH_LANDSCAPE_IPAD;
    }
    
    return CGSizeMake(sizeX, TBI_MORE_HEIGHT);
}

- (CGPoint) calcOriginInFrame:(CGRect)frm {
    CGFloat X = 0;
    
    if (IS_IPHONE) {
        X = IS_PORTRAIT ? TBI_MORE_ORIGIN_X_PORTRAIT_IPHONE : TBI_MORE_ORIGIN_X_LANDSCAPE_IPHONE;
    } else if (IS_IPHONE_5) {
        X = IS_PORTRAIT ? TBI_MORE_ORIGIN_X_PORTRAIT_IPHONE5 : TBI_MORE_ORIGIN_X_LANDSCAPE_IPHONE5;
    } else { // if (IS_IPAD)
        X = IS_PORTRAIT ? TBI_MORE_ORIGIN_X_PORTRAIT_IPAD : TBI_MORE_ORIGIN_X_LANDSCAPE_IPAD;
    }
    
    X = X + ([self calcBtnSize].width / 2.0f);
    return CGPointMake(X, CGRectGetMaxY(frm) - TBI_MORE_HEIGHT);
}

- (void) prepareButtons {
    NSString *orientation = IS_IPAD ? @"" : (IS_PORTRAIT ? @"_v" : @"_h");
    [self.btnWho setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBar/more_icons%@_who-we-are.jpg", orientation]]
                           forState:UIControlStateNormal];
    
    [self.btnFranchise setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBar/more_icons%@_franchise.jpg", orientation]]
                                 forState:UIControlStateNormal];
    
    [self.btnCost setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBar/more_icons%@_cost.jpg", orientation]]
                            forState:UIControlStateNormal];
    
    [self.btnProfit setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBar/more_icons%@_profit.jpg", orientation]]
                              forState:UIControlStateNormal];
    
    [self.btnMaterial setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBar/more_icons%@_materials.jpg", orientation]]
                                forState:UIControlStateNormal];
    
    [self.btnPlanet setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBar/more_icons%@_planet.jpg", orientation]]
                              forState:UIControlStateNormal];
    
    [self.btnFavs setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBar/more_icons%@_favorites.jpg", orientation]]
                            forState:UIControlStateNormal];
    
    self.btnWho.tag = TAG_TBIX_WHO;
    self.btnFranchise.tag = TAG_TBIX_FRANCHISE;
    self.btnCost.tag = TAG_TBIX_COST;
    self.btnProfit.tag = TAG_TBIX_PROFIT;
    self.btnMaterial.tag = TAG_TBIX_MATERIALS;
    self.btnPlanet.tag = TAG_TBIX_PLANET;
    self.btnFavs.tag = TAG_TBIX_FAVORITES;
}

- (void) doLocalize {
    [self.btnWho setTitle:DPLocalizedString(ktbiWho_Title) forState:UIControlStateNormal];
    [self.btnFranchise setTitle:DPLocalizedString(ktbiFranchise_Title) forState:UIControlStateNormal];
    [self.btnCost setTitle:DPLocalizedString(ktbiCost_Title) forState:UIControlStateNormal];
    [self.btnProfit setTitle:DPLocalizedString(ktbiProfit_Title) forState:UIControlStateNormal];
    [self.btnMaterial setTitle:DPLocalizedString(ktbiMaterials_Title) forState:UIControlStateNormal];
    [self.btnPlanet setTitle:DPLocalizedString(ktbiPlanet_Title) forState:UIControlStateNormal];
    [self.btnFavs setTitle:DPLocalizedString(ktbiFavorites_Title) forState:UIControlStateNormal];
}

- (CGSize) calcViewSize {
    CGSize btnSize = [self calcBtnSize];
    return CGSizeMake(btnSize.width, TBI_MORE_BTN_VISIBLE_COUNT * btnSize.height);
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGSize scrlSize = [self calcViewSize];
    self.scrollView.frame = CGRectMake(0, 0, scrlSize.width, scrlSize.height);
    
    CGSize btnSize = [self calcBtnSize];
    CGRect btnfrm = CGRectMake(0, 0, btnSize.width, btnSize.height);
    self.btnWho.frame = btnfrm;
    self.btnFranchise.frame = CGRectOffset(btnfrm, 0, 1 * btnSize.height);
    self.btnCost.frame = CGRectOffset(btnfrm, 0, 2 * btnSize.height);
    self.btnProfit.frame = CGRectOffset(btnfrm, 0, 3 * btnSize.height);
    self.btnMaterial.frame = CGRectOffset(btnfrm, 0, 4 * btnSize.height);
    self.btnPlanet.frame = CGRectOffset(btnfrm, 0, 5 * btnSize.height);
    self.btnFavs.frame = CGRectOffset(btnfrm, 0, 6 * btnSize.height);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self doflashScrollIndicators:3 delay:0.3];
}

- (void) doflashScrollIndicators:(int)times delay:(CGFloat)secsDelay {
    for (int i = 0; i < times; i++) {
        double delayInSeconds = secsDelay * (i + 1) ;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.scrollView flashScrollIndicators];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnTouchUpInside:(id)sender {
    UIButton *btn = sender;
    if (self.menuDelegate)
        [self.menuDelegate menuItemSelected:btn.tag];
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setBtnWho:nil];
    [self setBtnFranchise:nil];
    [self setBtnCost:nil];
    [self setBtnProfit:nil];
    [self setBtnMaterial:nil];
    [self setBtnPlanet:nil];
    [self setBtnFavs:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [self setScrollView:nil];
    [self setBtnWho:nil];
    [self setBtnFranchise:nil];
    [self setBtnCost:nil];
    [self setBtnProfit:nil];
    [self setBtnMaterial:nil];
    [self setBtnPlanet:nil];
    [self setBtnFavs:nil];
}
@end
