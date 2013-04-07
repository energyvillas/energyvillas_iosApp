//
//  DPFloatingViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPFloatingViewController.h"
#import "DPConstants.h"


@interface DPFloatingViewController ()

@end

@implementation DPFloatingViewController

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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation fixtop:(BOOL)fixtop {
    int szx = IS_IPAD ? 2 * 85 : 85;
    int szy = szx;
    CGRect frm = CGRectMake(0, 0, szx, szy);
    CGRect imgfrm = CGRectMake(0, 0, szx, szy - 20);
    CGRect lblfrm = CGRectMake(0, szy - 20, szx, 20);
    int cw = self.view.bounds.size.width;
    int ch = self.view.bounds.size.height;
    
    UIView *v;
    for (v in self.view.subviews) {
        NSInteger rx = arc4random() % (cw - szx);
        NSInteger ry = arc4random() % (ch - szy);
        frm = CGRectMake(rx, ry, szx, szy);;
        v.frame = frm;
        ((UIView *)v.subviews[0]).frame = imgfrm;
        ((UIView *)v.subviews[1]).frame = lblfrm;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
