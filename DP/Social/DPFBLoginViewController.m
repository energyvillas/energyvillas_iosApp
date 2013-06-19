//
//  DPFBLoginViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPFBLoginViewController.h"
#import "DPAppDelegate.h"
#import "DPAppHelper.h"
#import "DPConstants.h"


@interface DPFBLoginViewController ()

@end

@implementation DPFBLoginViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:0.0f
                                                green:51.0f / 256.0f
                                                 blue:102.0f / 256.0f
                                                alpha:1.0f];
    
    self.logoImgView.image = [UIImage imageNamed:[NSString stringWithFormat: @"NavBar/logo_%@.png", CURRENT_LANG]];
}

- (void) doLocalize {
    [super doLocalize];
    self.logoImgView.image = [UIImage imageNamed:[NSString stringWithFormat: @"NavBar/logo_%@.png", CURRENT_LANG]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBusyIndicator:nil];
    [self setLogoImgView:nil];
    [self setBtnLogin:nil];
    [self setBtnClose:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [self setBusyIndicator:nil];
    [self setLogoImgView:nil];
    [self setBtnLogin:nil];
    [self setBtnClose:nil];
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    
}

- (IBAction)btnTouchUpInside:(id)sender {
    if (sender == self.btnLogin) {
        [self.busyIndicator startAnimating];
        
        DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
        [appdel openFBSession];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void) loginFailed {
    [self.busyIndicator stopAnimating];
}

@end
