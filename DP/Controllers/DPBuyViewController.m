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
#import "DPCtgScrollViewController.h"


@interface DPBuyViewController ()

@end

@implementation DPBuyViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view bringSubviewToFront:self.contentView];
    
    [self loadDetailView];
}

- (void) loadDetailView {
    UIView *bcv = self.innerView;
    
    NSLog(@"inner frame : (x, y, w, h) = (%f, %f, %f, %f)", bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);
    
    DPCtgScrollViewController *detvc;
    if (bcv.subviews.count == 0) {
                
        NSArray *content = [DPAppHelper sharedInstance].freeBuyContent;
        detvc = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:1 columns:1];        
        
        [self addChildViewController: detvc];
        [bcv addSubview: detvc.view];
        
        detvc = nil;
    } else {
        detvc = (DPCtgScrollViewController *)self.childViewControllers[0];
        [detvc changeRows:1 columns:1];
    }
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

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation fixtop:(BOOL)fixtop{
    CGSize nextViewSize = [UIApplication sizeInOrientation:toOrientation];
    self.view.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);
    self.backView.frame = self.view.frame;
    
    int PHONE_W = 280;
    int PHONE_H = 250;
    
    int PAD_W = 680;
    int PAD_H = PAD_W * PHONE_H / PHONE_W;
    
    int toolbarHeight = self.toolbar.frame.size.height;
    if (toolbarHeight == 0)
        toolbarHeight = 44;

    CGRect cf;
    if (IS_IPHONE || IS_IPHONE_5) {
        cf = CGRectMake((nextViewSize.width - PHONE_W) / 2,
                               (nextViewSize.height - PHONE_H) / 2,
                               PHONE_W, PHONE_H);
    } else {
        cf = CGRectMake((nextViewSize.width - PAD_W) / 2,
                               (nextViewSize.height - PAD_H) / 2,
                               PAD_W, PAD_H);
    }

    self.contentView.frame = cf;
    self.toolbar.frame = CGRectMake(0, 0, cf.size.width, toolbarHeight);
    self.innerView.frame = CGRectMake(0, toolbarHeight,
                                      cf.size.width, cf.size.height - toolbarHeight - 40);
    self.btnBuy.center = CGPointMake(cf.size.width / 2,
                                     cf.size.height - (self.btnBuy.frame.size.height / 2) - 4);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTouchUpInside:(id)sender forEvent:(UIEvent *)event {
    SKProduct *product = [[SKProduct alloc] init];
    //product.
    [[DPIAPHelper sharedInstance] buyProduct:product];
}

- (IBAction)onClose:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void) dealloc {
    
}
- (void)viewDidUnload {
    [self setBackView:nil];
    [self setContentView:nil];
    [self setInnerView:nil];
    [self setToolbar:nil];
    [self setBtnBuy:nil];
    [super viewDidUnload];
}
@end
