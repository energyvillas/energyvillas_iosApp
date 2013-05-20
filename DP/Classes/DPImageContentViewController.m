//
//  DPImageContentViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/24/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPImageContentViewController.h"
#import "../External/ASIHttpRequest/ASIHTTPRequest.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
//#import "AsyncImageView.h"

#define USE_HOLDER_VIEW ((BOOL)YES)


@interface DPImageContentViewController ()

@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) ASIHTTPRequest *request;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation DPImageContentViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithArticle:(Article *)aArticle {
    if (self = [super init]) {
        self.article = aArticle;
    }
    
    return self;
}

//- (id) initWithImage:(UIImage *)aImage {
//    if (self = [super init]) {
//        self.image = aImage;
//    }
//    
//    return self;
//}

//- (id) initWithImageUrl:(NSURL *)imageUrl {
//    if (self = [super init]) {
//        [self downloadImageUrl:imageUrl];
//    }
//    
//    return self;
//}

- (id) initWithImageName:(NSString *)imageName {
    if (self = [super init]) {
        self.image = [UIImage imageNamed:imageName];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.imageView];
}


- (void) viewDidUnload {
    [super viewDidUnload];
}

-(void) cleanUp {
    if (self.queue) {
        [self.queue cancelAllOperations];
    }
    if (self.request) {
        [self.request cancel];
        self.request.delegate = nil;
    }
    self.request = nil;
    self.queue = nil;
}

-(void) dealloc {
    [self cleanUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    if (self.image)// && !self.article)
        [self doInitImageView];
    else if (self.article) {
        if (isLocalUrl(self.article.imageUrl)) {
            self.image = [UIImage imageNamed:self.article.imageUrl];
            [self doInitImageView];
        } else {
            UIImage *img = [[DPAppHelper sharedInstance] loadUIImageFromCache:self.article.imageUrl];
            if (img) {
                self.image = img;
                [self doInitImageView];
            } else {
                [self downloadImageUrl:self.article.imageUrl];
            }
        }
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

    self.scrollView.frame = CGRectMake(0, top, w, h);

    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds),
                                      CGRectGetMidY(self.scrollView.bounds));
    [self view:self.imageView setCenter:centerPoint];
}

- (void) doInitImageView {
    self.imageView.image = self.image;
    //[self.imageView sizeToFit];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.scrollView.contentSize = self.image.size;
    self.scrollView.delegate = self;
    //    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 10.0;
}

//==============================================================================
#pragma mark - === zooming handling  ===
- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.scrollView.contentOffset = co;
}

// MARK: - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}

//==============================================================================
#pragma mark - === busy indication handling  ===

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

//==============================================================================
#pragma mark - === image downloading handling  ===

- (void) downloadImageUrl:(NSString *)imageUrl {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];

    if (!self.request) {
        self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        [self.request setDelegate:self];
        [self.request setDidFinishSelector:@selector(imageRequestDone:)];
        self.request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 imageUrl, @"imageName",
                                 nil];
        [self.queue addOperation:self.request];
    }
    [self startIndicator];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];
    
    NSString *imgName = [request.userInfo objectForKey:@"imageName"];
    NSData *imgData = [request responseData];
	UIImage *aImage = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
    
    [[DPAppHelper sharedInstance] saveImageToCache:imgName data:imgData];
    
	self.image = aImage;
    [self doInitImageView];
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);

	[self stopIndicator];

    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
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
    return (self.article != nil);
}
- (BOOL) showNavBarSocial {
    return (self.article != nil);
}
//- (BOOL) showNavBarInfo {
//    return YES;
//}
//==============================================================================

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
    if ([self aquireImageUrlToShare] != nil)
        return  self.article.title;
    
    return nil;
}

- (NSString *) aquireImageUrlToShare {
    if (self.article &&
        self.article.imageUrl &&
        (!isLocalUrl(self.article.imageUrl)))
        return self.article.imageUrl;
    
    return nil;
}

@end
