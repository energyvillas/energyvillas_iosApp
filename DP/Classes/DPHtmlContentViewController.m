//
//  DPWebContentViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPHtmlContentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "../External/ASIHttpRequest/ASIFormDataRequest.h"
#import "../Models/Article.h"
#import "../Models/ArticleParser.h"
#import "../Models/DPDataLoader.h"


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
    NSLog(self.htmlData);
    
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
    
//    NSURL *url = [NSURL URLWithString:@"http://www.designprojectsapss.com/iphonenews.php"];
    ASIFormDataRequest *webRequest = [[ASIFormDataRequest alloc] initWithURL:aUrl];
	webRequest.defaultResponseEncoding = NSUTF8StringEncoding;
	[webRequest setPostValue:USER_NAME forKey:@"user"];
	[webRequest setPostValue:[DPDataLoader digestSHA1:PASSWORD] forKey:@"pass"];
	[webRequest setPostValue:@"en" forKey:@"lang"];
	[webRequest setPostValue:[NSString stringWithFormat:@"%i", CTGID_WHO_WE_ARE] forKey:@"cid"];
    //[webRequest setPostValue:@"phone" forKey:@"count"]; // optional
	//[webRequest setPostValue:@"phone" forKey:@"from"]; // optional, requires "count

    [webRequest setDelegate:self];
    [self.queue addOperation:webRequest];
    [self startIndicator];
}

- (void) requestFinished:(ASIHTTPRequest *)request{
    [self stopIndicator];
    
    NSString *resp = [request responseString];
	NSLog(@"Response: \n%@", resp);
    //resp = [resp stringByReplacingOccurrencesOfString:@"&gt;" withString:<#(NSString *)#>]
    
//    NSString *aResponse = [[NSString alloc] initWithString:
//						   [[request responseString] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

    
    ArticleParser *parser = [[ArticleParser alloc] init];
	[parser parseXMLFile:resp];
    NSArray *articles = [NSArray arrayWithArray:parser.articles];

    if (articles.count == 0)
        [self showAlertMessage:NSLocalizedString(@"URL_LOAD_FAILED_MESSAGE", nil)
                         title:NSLocalizedString(@"URL_LOAD_FAILED_TITLE", nil)];
    else {
        NSString *body = ((Article *)articles[0]).body;
        body = [[body stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
                stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        self.htmlData = body;
        [self doInitWebView];
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	[self stopIndicator];
    
    [self showAlertMessage:NSLocalizedString(@"URL_LOAD_FAILED_MESSAGE", nil)
                     title:NSLocalizedString(@"URL_LOAD_FAILED_TITLE", nil)];
}

-(void) showAlertMessage:(NSString *)aMessage title:(NSString *)aTitle {
	UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc]
                   initWithTitle:aTitle
                   message:aMessage
                   delegate:nil
                   cancelButtonTitle: NSLocalizedString(@"btnOK_Title", nil)
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
