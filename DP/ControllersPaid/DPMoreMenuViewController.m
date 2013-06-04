//
//  DPMoreMenuViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMoreMenuViewController.h"

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
    self.scrollView.contentSize = CGSizeMake(64, 6*64);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scrollView flashScrollIndicators];
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
    [super viewDidUnload];
}
@end
