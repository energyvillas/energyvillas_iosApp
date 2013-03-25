//
//  DPWebContentViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPHtmlContentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "../External/ASIHttpRequest/ASIHTTPRequest.h"

@interface DPHtmlContentViewController ()

@property (strong, nonatomic) NSString *htmlData;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation DPHtmlContentViewController

@synthesize htmlData, busyIndicator, queue;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithHTML:(NSString *)aHtml {
    if (self = [super init]) {
        self.htmlData = aHtml;
    }
    
    return self;
}

- (id) initWithContentUrl:(NSURL *)aUrl {
    if (self = [super init]) {
        [self downloadUrl:aUrl];
    }
    
    return self;
}

- (void) doInitWebView {
    CGRect aframe = CGRectMake(0, 0, self.view.superview.frame.size.width, self.view.superview.frame.size.height);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:aframe];
    webView.contentMode = UIViewContentModeScaleAspectFit;
    webView.userInteractionEnabled = YES;
    [webView loadHTMLString:htmlData baseURL:nil];
//    [self addGestureRecognizersTo:webView];
    [self.view addSubview:webView];
}

#pragma mark -
#pragma mark === busy indication handling  ===

- (void) startIndicator {
    if(!self.busyIndicator) {
		self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.busyIndicator.frame = CGRectMake((self.view.frame.size.width-25)/2,
                                              (self.view.frame.size.height-25)/2,
                                              25, 25);
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self.view addSubview:self.busyIndicator];
	}
    [self.busyIndicator startAnimating];
}

- (void) stopIndicator {
    if(self.busyIndicator) {
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        self.busyIndicator = nil;
    }
}

#pragma mark -
#pragma mark === downloading handling  ===

- (void) downloadUrl:(NSURL *)aUrl {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    ASIHTTPRequest *webRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:aUrl]];
    [webRequest setDelegate:self];
    [webRequest setDidFinishSelector:@selector(webRequestDone:)];
    //webRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:aIndex], @"imageIndex", nil];
    [self.queue addOperation:webRequest];
    [self startIndicator];
}

- (void) webRequestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];
    
//	self.htmlData = [NSString :[request responseData]];
    [self doInitWebView];
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	[self stopIndicator];
    
	UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc]
                   initWithTitle:@"Αποτυχία Σύνδεσης"
                   message:@"Η διαδικασία ανάκτησης νέων απέτυχε! Παρακαλούμε δοκιμάστε αργότερα..."
                   delegate:nil
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil];
    
	[alertDialog show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    if (htmlData)
        [self doInitWebView];
    
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark === device orientation change handling  ===

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation {
    UIView *innerview = self.view.subviews.count == 1 ? self.view.subviews[0] : nil;
    if (innerview) {
        innerview.frame = CGRectMake(0, 0,
                                     self.view.superview.bounds.size.width,
                                     self.view.superview.bounds.size.height);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
