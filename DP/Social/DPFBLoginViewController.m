//
//  DPFBLoginViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPFBLoginViewController.h"

@interface DPFBLoginViewController ()

@property (strong) NSString *apiKey;
@property (strong) NSString *requestedPermissions;
@property (weak) id <DPFBLoginDialogDelegate> delegate;

@end

@implementation DPFBLoginViewController


- (id)initWithAppId:(NSString *)apiKey
requestedPermissions:(NSString *)requestedPermissions
           delegate:(id<DPFBLoginDialogDelegate>)delegate {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        self.apiKey = apiKey;
        self.requestedPermissions = requestedPermissions;
        self.delegate = delegate;
    }
    return self;    
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
    self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setBtnClose:nil];
    [super viewDidUnload];
}

-(void) login {
    if (self.view == nil)
        return;
    
    [self.webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    NSString *redirectUrlStr = @"http://www.facebook.com/connect/login_success.html";
    NSString *authFmtStr = @"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=touch";
    NSString *urlStr = [NSString stringWithFormat:authFmtStr,
                        self.apiKey, redirectUrlStr, self.requestedPermissions];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

-(void) logout {
    NSHTTPCookieStorage *cookiesStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookiesStorage cookies])
        [cookiesStorage deleteCookie:cookie];
}

- (BOOL) webView: (UIWebView *)webview
shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlStr = request.URL.absoluteString;
    NSLog(@"WVDEL :: %@", urlStr);
    
    [self checkForAccessToken:urlStr];
    [self checkLoginRequired:urlStr];
    
    return YES;
}

-(void)checkForAccessToken:(NSString *)urlString {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"access_token=(.*)&"
                                  options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch =
        [regex firstMatchInString:urlString
                          options:0 range:NSMakeRange(0, [urlString length])];
        if (firstMatch) {
            NSRange accessTokenRange = [firstMatch rangeAtIndex:1];
            NSString *accessToken = [urlString substringWithRange:accessTokenRange];
            accessToken = [accessToken
                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.delegate accessTokenFound:accessToken];
        }
    }
}

-(void)checkLoginRequired:(NSString *)urlString {
    if ([urlString rangeOfString:@"login.php"].location != NSNotFound) {
        [self.delegate displayRequired];
    }
}

- (IBAction)onCloseTapped:(id)sender {
    [self.delegate closeTapped];
}

@end
