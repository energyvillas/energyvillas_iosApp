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
#import "DPConstants.h"
#import "DPArticlesLoader.h"


@interface DPHtmlContentViewController ()

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *htmlData;
@property (strong, nonatomic) NSString *mimetype;
@property (strong, nonatomic) NSData *mimeData;
@property (strong, nonatomic) DPArticlesLoader *articlesLoader;
@property int categoryID;
@property (strong, nonatomic) NSString *lang;
@end

@implementation DPHtmlContentViewController

//@synthesize htmlData, busyIndicator, queue;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithUrl:(NSURL *)aUrl {
    if (self = [super init]) {
        self.url = aUrl;
    }
    
    return self;
}

- (id) initWithData:(NSData *)aData mimetype:(NSString *)aMimeType {
    if (self = [super init]) {
        self.mimeData = aData;
        self.mimetype = aMimeType;
    }
    
    return self;
}

- (id) initWithHTML:(NSString *)aHtml {
    if (self = [super init]) {
        self.htmlData = aHtml;
    }
    
    return self;
}

- (id) initWithCategory:(int)ctgid lang:(NSString *) aLang {
    if (self = [super init]) {
//        [self downloadUrl:aUrl];
        self.categoryID = ctgid;
        self.lang = aLang;
        self.articlesLoader = [[DPArticlesLoader alloc] initWithView:self.view category:ctgid lang:aLang];
        self.articlesLoader.delegate = self;
        [self.articlesLoader loadData];
    }
    
    return self;
}

- (void) doInitWebView {    
    CGRect aframe = CGRectMake(0, 0,
                               self.view.superview.frame.size.width,
                               self.view.superview.frame.size.height);
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:aframe];
    webView.contentMode = UIViewContentModeScaleAspectFit;
    webView.userInteractionEnabled = YES;
    
    if (self.url) {
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:self.url];
        [webView loadRequest:request];
    } else if (self.htmlData)
        [webView loadHTMLString:self.htmlData
                        baseURL:nil];
    else if (self.mimeData)
        [webView loadData:self.mimeData
                 MIMEType:self.mimetype
         textEncodingName:@"utf-8"
                  baseURL:nil];
    
//    [self addGestureRecognizersTo:webView];
    [self.view addSubview:webView];
}

#pragma -
#pragma dataloaderdelegate methods

- (void)loadFinished:(DPDataLoader *)loader {
    NSArray *articles = loader.datalist;
 
    if (articles.count == 0)
        showAlertMessage(nil,
                         DPLocalizedString(kERR_TITLE_INFO),
                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    else {
        NSString *body = ((Article *)articles[0]).body;
        body = [[body stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
                stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        self.htmlData = body;
        [self doInitWebView];
    }    
}

- (void)loadFailed:(DPDataLoader *)loader {
    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
}

#pragma

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    if (self.url)
        [self doInitWebView];
    else if (self.htmlData)
        [self doInitWebView];
    else if (self.mimeData)
        [self doInitWebView];
    
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark === device orientation change handling  ===

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation fixtop:(BOOL)fixtop{
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
