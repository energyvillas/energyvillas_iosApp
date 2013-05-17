//
//  DPFBLoginViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPFBLoginViewController.h"
#import "DPAppDelegate.h"


@interface DPFBLoginViewController ()

@property (strong) NSString *apiKey;
@property (strong) NSString *requestedPermissions;

@end

@implementation DPFBLoginViewController


//- (id)initWithAppId:(NSString *)apiKey
//requestedPermissions:(NSString *)requestedPermissions
//           delegate:(id<DPFBLoginDialogDelegate>)delegate {
//    if ((self = [self initWithNibName:nil bundle:nil])) {
//        self.apiKey = apiKey;
//        self.requestedPermissions = requestedPermissions;
//        self.delegate = delegate;
//    }
//    return self;    
//}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBusyIndicator:nil];
    [super viewDidUnload];
}

- (IBAction)btnTouchUpInside:(id)sender {
    [self.busyIndicator startAnimating];
    
    DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
    [appdel openFBSession];
}

- (void) loginFailed {
    [self.busyIndicator stopAnimating];
}

@end
