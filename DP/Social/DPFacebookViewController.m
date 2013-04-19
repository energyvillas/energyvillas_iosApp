//
//  DPFacebookViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPFacebookViewController.h"


@interface DPFacebookViewController ()

@property (strong, nonatomic) DPFBLoginViewController *loginDialog;
@end

@implementation DPFacebookViewController {
    LoginState loginState;
}

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
    [self setLblLoginStatus:nil];
    [self setBtnLogin:nil];
    [super viewDidUnload];
}
- (IBAction)btnLoginTapped:(id)sender {
    NSString *appId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    NSString *permissions = @"publish_stream";
    
    if (self.loginDialog == nil) {
        self.loginDialog = [[DPFBLoginViewController alloc] initWithAppId:appId
                                               requestedPermissions:permissions
                                                                 delegate:self];
       // UIView *v = self.loginDialog.view;
    }
    
    if (loginState == LoginStateStartup || loginState == LoginStateLoggedOut) {
        loginState = LoginStateLoggingIn;
        [self.loginDialog login];
    } else if (loginState == LoginStateLoggedIn) {
        loginState = LoginStateLoggedOut;
        [self.loginDialog logout];
    }
    
    [self refresh];
}

- (void)refresh {
    if (loginState == LoginStateStartup || loginState == LoginStateLoggedOut) {
        self.lblLoginStatus.text = @"Not connected to Facebook";
        [self.btnLogin setTitle:@"Login" forState:UIControlStateNormal];
        self.btnLogin.hidden = NO;
    } else if (loginState == LoginStateLoggingIn) {
        self.lblLoginStatus.text = @"Connecting to Facebook...";
        self.btnLogin.hidden = YES;
    } else if (loginState == LoginStateLoggedIn) {
        self.lblLoginStatus.text = @"Connected to Facebook";
        [self.btnLogin setTitle:@"Logout" forState:UIControlStateNormal];
        self.btnLogin.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)accessTokenFound:(NSString *)accessToken {
    NSLog(@"Access token found: %@", accessToken);
    loginState = LoginStateLoggedIn;
    [self dismissModalViewControllerAnimated:YES];
    [self refresh];
}

- (void)displayRequired {
    [self presentModalViewController:self.loginDialog animated:YES];
}

- (void)closeTapped {
    [self dismissModalViewControllerAnimated:YES];
    loginState = LoginStateLoggedOut;
    [self.loginDialog logout];
    [self refresh];
}
@end
