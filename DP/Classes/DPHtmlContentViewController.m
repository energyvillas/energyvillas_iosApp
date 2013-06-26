//
//  DPWebContentViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPHtmlContentViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "../Models/Article.h"
#import "../Models/ArticleParser.h"
#import "../Models/DPDataLoader.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "DPArticlesLoader.h"


@interface DPHtmlContentViewController ()

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *htmlData;
@property (strong, nonatomic) NSString *mimetype;
@property (strong, nonatomic) NSData *mimeData;
@property (strong, nonatomic) DPArticlesLoader *articlesLoader;
@property (strong, nonatomic) Article *article;
@property int categoryID;
@property (strong, nonatomic) NSString *lang;

@property (strong, nonatomic) UIView *containerView;
//@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation DPHtmlContentViewController


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
    }
    
    return self;
}

- (void) doInitWebView {
    if (self.webView)
        [self.webView removeFromSuperview];
    self.webView = nil;
    
    if (self.containerView == nil) return;
    
    releaseSubViews(self.containerView);
//    [self.busyIndicator stopAnimating];
    
    CGRect aframe = self.containerView.bounds;
    
    UIWebView *aWebView = [[UIWebView alloc] initWithFrame:aframe];
    aWebView.backgroundColor = [UIColor clearColor];
    aWebView.opaque = NO;
    //webView.contentMode = UIViewContentModeScaleAspectFit;
    aWebView.userInteractionEnabled = YES;
    [aWebView setScalesPageToFit:NO];
    
    if (self.url) {
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:self.url];
        [aWebView loadRequest:request];
    } else if (self.htmlData) {
        [aWebView loadHTMLString:self.htmlData
                        baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", BASE_HOST_NAME]]];
    } else if (self.mimeData) {
        [aWebView loadData:self.mimeData
                 MIMEType:self.mimetype
         textEncodingName:@"utf-8"
                  baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", BASE_HOST_NAME]]];
    }
//    [self addGestureRecognizersTo:webView];
    [self.containerView addSubview:aWebView];
    self.webView = aWebView;
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
        self.article = articles[0];
        self.htmlData = self.article.body;
        [self doInitWebView];
    }
    
    [self fixFavsButton];
    
    if (self.dataloaderDelegate)
        [self.dataloaderDelegate loadFinished:loader];
}

- (void)loadFailed:(DPDataLoader *)loader {
    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));

    [self fixFavsButton];

    if (self.dataloaderDelegate)
        [self.dataloaderDelegate loadFailed:loader];
}

#pragma

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.containerView];
        
    if (self.categoryID != 0) {
        self.articlesLoader = [[DPArticlesLoader alloc] initWithView:self.view
                                                            category:self.categoryID
                                                                lang:self.lang];
        self.articlesLoader.delegate = self;
        [self.articlesLoader loadData];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [self checkInitWebView];
    [super viewWillAppear:animated];
}

- (void) checkInitWebView {
    if (self.url)
        [self doInitWebView];
    else if (self.htmlData)
        [self doInitWebView];
    else if (self.mimeData)
        [self doInitWebView];
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    fixtop = (!self.isInner) && IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

    if (self.containerView) {
        self.containerView.frame = CGRectMake(0, top, w, h);
    }
    
    if (self.categoryID != 0) {
        [self.containerView addSubview:createImageViewLoading(self.containerView.bounds, NO, NO)];
//        if (!self.busyIndicator)
//            self.busyIndicator = makeIndicatorForView(self.containerView);
//        else
//            self.busyIndicator.center = calcBoundsCenterOfView(self.containerView);
//        
//        [self.containerView addSubview:makeIndicatorForView(self.busyIndicator)];
//        [self.busyIndicator startAnimating];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkInitWebView];
    });
}

-(void) clearDataLoader {
    if (self.articlesLoader) {
        self.articlesLoader.delegate = nil;
    }
    self.articlesLoader = nil;
}

-(void) dealloc {
    [self clearDataLoader];
    self.webView = nil;
    self.containerView = nil;
    
    self.url = nil;
    self.htmlData = nil;
    self.mimetype = nil;
    self.mimeData = nil;
    self.articlesLoader = nil;
    self.article = nil;
    self.lang = nil;
    
    self.containerView = nil;
    self.webView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//==============================================================================
#pragma mark - favorites handling
- (BOOL) isInFavorites {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    BOOL infavs = [apphelper isArticleInFavorites:self.article];
    return infavs;
}

- (void) toggleInFavorites {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    BOOL infavs = [self isInFavorites];
    if (infavs)
        [apphelper removeFromFavorites:self.article];
    else
        [apphelper addToFavorites:self.article];
}

- (NSString *) aquireImageTitleToShare {
    if (self.article != nil)
        return  self.article.title;
    
    return nil;
}

//==============================================================================
#pragma mark - nav bar button selection
//- (BOOL) showNavBar {
//    return self.navigationController != nil;
//}
- (BOOL) showNavBarLanguages {
    return NO;
}
- (BOOL) showNavBarAddToFav {
    return self.categoryID != 0 && self.categoryID != CTGID_INFO;
}
- (BOOL) showNavBarSocial {
    return NO;
}
//- (BOOL) showNavBarInfo {
//    return YES;
//}
//==============================================================================


@end
