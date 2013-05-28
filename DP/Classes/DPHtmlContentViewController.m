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
    }
    
    return self;
}

- (void) doInitWebView {
    while (self.view.subviews.count > 0)
        [self.view.subviews[0] removeFromSuperview];
    
    CGRect aframe = self.view.bounds;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:aframe];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
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
    if (self.categoryID != 0) {
        self.articlesLoader = [[DPArticlesLoader alloc] initWithView:self.view
                                                            category:self.categoryID
                                                                lang:self.lang];
        self.articlesLoader.delegate = self;
        [self.articlesLoader loadData];
    }
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


- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    fixtop = (!self.isInner) && IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

    UIView *innerview = self.view.subviews.count == 1 ? self.view.subviews[0] : nil;
    if (innerview) {
        innerview.frame = CGRectMake(0, top, w, h);
        [innerview setNeedsDisplay];
    }
}

-(void) clearDataLoader {
    if (self.articlesLoader) {
        self.articlesLoader.delegate = nil;
    }
    self.articlesLoader = nil;
}

-(void) dealloc {
    [self clearDataLoader];
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
    return self.categoryID != 0;
}
- (BOOL) showNavBarSocial {
    return YES;
}
//- (BOOL) showNavBarInfo {
//    return YES;
//}
//==============================================================================


@end
