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
#import <MediaPlayer/MediaPlayer.h>


@interface DPBuyViewController ()

@property (strong, nonatomic) DPBuyContentViewController *buyContentController;
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (strong, nonatomic) MPMoviePlayerController *playerController;
@property (strong) void (^onClose)(void);

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

- (id) initWithCategoryId:(int)ctgid completion:(void (^)(void))completion {
    self = [super init];
    if (self) {
        _category = ctgid;
        self.onClose = completion;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    actualFrame = CGRectZero;
    
    [self.view bringSubviewToFront:self.contentView];
    
    [self doLocalize];
    [self prepareBuyBtn];
    //[self loadDetailView: NO];
}

- (void) doLocalize {
    [self.btnClose setTitle:DPLocalizedString(@"BUY_DLG_bbiClose_Title")
                 forState:UIControlStateNormal];
    
    [self.btnRestore setTitle:DPLocalizedString(@"BUY_DLG_btnRestore_Title")
                     forState:UIControlStateNormal];
    
    [self.btnBuy setTitle:[self buyBtnTitle] // TODO:GGSE
                 forState:UIControlStateNormal];
    
    [self doLayoutSubViews];

//    if (self.innerView.subviews.count > 0)
//        [self loadDetailView:YES];
}

- (NSString *) buyBtnTitle {
    return [NSString stringWithFormat:@"€%.2f", 2.99];
    //return [NSString stringWithFormat:@"%@", @"2"];
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

    NSString *btnTitle = [self buyBtnTitle]; //self.btnBuy.currentTitle;// titleLabel.text;
    CGFloat actualFontSize;
    CGSize lblsize = [btnTitle sizeWithFont:font minFontSize:fntSize*0.5 actualFontSize:&actualFontSize forWidth:width lineBreakMode:UILineBreakModeWordWrap];
    start = start + (width - lblsize.width) / 2;
    
    font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold"
                           size:actualFontSize];
    self.btnBuy.titleLabel.font = font;
    [self.btnBuy setTitleEdgeInsets:UIEdgeInsetsMake(0, start, 0, 0)];
}

- (void) removeBuyContent {
    if (self.buyContentController != nil) {
        [self.buyContentController.view removeFromSuperview];
        [self.buyContentController removeFromParentViewController];
    }
    
    if (self.playerVC) {
        MPMoviePlayerViewController *mpvc = self.playerVC;
        [self.playerVC.moviePlayer.view removeFromSuperview];
        self.playerVC = nil;
        [mpvc.moviePlayer stop];
    }

    if (self.playerController) {
        MPMoviePlayerController *mpc = self.playerController;
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
        [mpc stop];
    }
}

- (void) createAndConfigMoviePlayer {
    if (!self.playerVC) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *moviePath = [bundle pathForResource:@"Videos/test-video" ofType:@"mp4"];
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        
        self.playerVC= [[MPMoviePlayerViewController alloc] initWithContentURL: movieURL];
        self.playerVC.view.frame = self.innerView.bounds;
        
        self.playerVC.moviePlayer.controlStyle = MPMovieControlStyleNone;
        
        [self.playerVC.moviePlayer prepareToPlay];
        self.playerVC.moviePlayer.repeatMode = MPMovieRepeatModeOne;
        self.playerVC.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        
        [self.innerView addSubview:self.playerVC.moviePlayer.view];
        [self.playerVC.moviePlayer play];
    } else
        self.playerVC.view.frame = self.innerView.bounds;
}

- (void) createAndConfigMoviePlayer2 {
    if (!self.playerController) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *moviePath = [bundle pathForResource:@"Videos/test-video" ofType:@"mp4"];
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        
        self.playerController= [[MPMoviePlayerController alloc] initWithContentURL: movieURL];
        self.playerController.view.frame = self.innerView.bounds;
        
        self.playerController.controlStyle = MPMovieControlStyleNone;
        
        [self.playerController prepareToPlay];
        self.playerController.scalingMode = MPMovieScalingModeAspectFill;
        self.playerController.repeatMode = MPMovieRepeatModeNone;
        
        [self.innerView addSubview:self.playerController.view];
        [self.playerController play];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinished:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.playerController];
    } else {
        NSTimeInterval pos = self.playerController.currentPlaybackTime;
        [self.playerController pause];
        self.playerController.view.frame = self.innerView.bounds;
        self.playerController.currentPlaybackTime = pos;
    }
}

-(void)moviePlayBackDidFinished:(NSNotification *)notification {
    if ([[notification name] isEqualToString:MPMoviePlayerPlaybackDidFinishNotification]) {
        NSLog (@"Successfully received the ==MPMoviePlayerPlaybackDidFinishNotification== notification!");
     
//        notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
        if (self.playerController != nil)
            [self.playerController play];
    }

}

- (void) loadDetailView:(BOOL)reload {
    if (reload)
        [self removeBuyContent];
    
    if (self.category == -1) {
        [self createAndConfigMoviePlayer2];
    } else {
    if (self.buyContentController == nil) {
        self.buyContentController = [[DPBuyContentViewController alloc] initWithCategory:self.category];
        
        self.buyContentController.view.frame = self.innerView.bounds;
        [self addChildViewController: self.buyContentController];
        [self.innerView addSubview: self.buyContentController.view];        
    } else {
        self.buyContentController.view.frame = self.innerView.bounds;
        [self.buyContentController changeRows:1 columns:1];
    }
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

-(void) doLayoutSubViews {
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
        NSString *dlgImgName = self.category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_01.png" : @"BuyDialog/Buy_our_app_01.png";
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
        dlgImgName = self.category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_02.png" : @"BuyDialog/Buy_our_app_02.png";
        img = [UIImage imageNamed:dlgImgName];
        frm = CGRectMake(0, frm.origin.y + frm.size.height,
                         img.size.width, img.size.height);
        self.innerView.frame = frm;
        self.innerView.backgroundColor = [UIColor colorWithPatternImage:img];
        
        // buy btn
        dlgImgName = self.category == CTGID_EXCLUSIVE ? @"BuyDialog/Buy_our_app_exclusive_03.png" : @"BuyDialog/Buy_our_app_03.png";
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
        
        if (IS_IPAD) {
            actualFrame = CGRectMake((nextViewSize.width - frm.size.width) / 2,
                                     cf.origin.y,
                                     frm.size.width,
                                     frm.origin.y + frm.size.height);
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
        NSLog(@"Uncaught exception: %@", exception.description);
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
        if (IS_IPAD) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
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
