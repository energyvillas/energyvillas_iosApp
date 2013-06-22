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
#import "DPFavoritesViewController.h"

#define USE_HOLDER_VIEW ((BOOL)YES)


@interface DPImageContentViewController ()

@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) ASIHTTPRequest *request;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;


@property (strong, nonatomic) UIView *lblContainer;
@property (strong, nonatomic) UIButton *btnAdd2Favs;
@property (strong, nonatomic) UILabel *lblCounter;
@property (strong, nonatomic) UILabel *lblTitle;


@end

@implementation DPImageContentViewController {
    BOOL showNavigationItem;
    BOOL showSocials;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithArticle:(Article *)aArticle showSocials:(BOOL)aShowSocials {
    self = [self initWithArticle:aArticle showNavItem:NO showSocials:aShowSocials];
    if (self) {
    }
    
    return self;
}

- (id) initWithArticle:(Article *)aArticle showNavItem:(BOOL)showNavItem showSocials:(BOOL)aShowSocials {
    self = [super init];
    if (self) {
        self.article = aArticle;
        showNavigationItem = showNavItem;
        showSocials = aShowSocials;
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
    [self loadScrollAndImageView];
}

- (void) clearScrollAndImageView {
    if (self.imageView)
        [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    if (self.scrollView)
        [self.scrollView removeFromSuperview];
    self.scrollView = nil;
}
- (void) loadScrollAndImageView {
    [self clearScrollAndImageView];
    
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
    if (self.request) {
        [self.request clearDelegatesAndCancel];
        self.request.delegate = nil;
    }
    
    if (self.queue) {
        [self.queue cancelAllOperations];
    }
    
    self.request = nil;
    self.queue = nil;
    
    self.article = nil;
    self.image = nil;
    self.busyIndicator = nil;
    
    self.scrollView = nil;
    self.imageView = nil;
    
    self.lblContainer = nil;
    self.btnAdd2Favs = nil;
    self.lblCounter = nil;
    self.lblTitle = nil;
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

    [self loadScrollAndImageView];
    self.scrollView.frame = CGRectMake(0, top, w, h);
    self.imageView.frame = self.scrollView.bounds;

    [self doInitImageView];
    
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds),
                                      CGRectGetMidY(self.scrollView.bounds));
    [self view:self.imageView setCenter:centerPoint];
    
    [self setupLabel];
    [self updateLabels];

    if (self.lblContainer) {
        CGRect lcf = self.lblContainer.frame;
        lcf.origin.y = top;
        self.lblContainer.frame = lcf;
    }
}

- (void) doInitImageView {
    self.imageView.image = self.image;
    //[self.imageView sizeToFit];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self setupScrollZoom];
}

-(void) setupScrollZoom {
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.contentSize = self.image.size;
    self.scrollView.delegate = self;
    //    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 10.0;
    self.scrollView.zoomScale = 1.01f;
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
//        [self.request setDelegate:self];
//        [self.request setDidFinishSelector:@selector(imageRequestDone:)];
        __block ASIHTTPRequest *ir = self.request;
        __block id this = self;
        [self.request setCompletionBlock:^{ [this imageRequestDone:ir]; }];
        [self.request setFailedBlock:^{ [this requestFailed:ir]; }];

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
- (BOOL) showNavBar {
    return ( [super showNavBar] || showNavigationItem );
}
- (BOOL) showNavBarLanguages {
    return NO;
}
- (BOOL) showNavBarAddToFav {
    return NO;//(self.article != nil);
}
- (BOOL) showNavBarSocial {
    return (showSocials && self.article != nil);
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

//==============================================================================

-(void) clearLabels {
    if (self.lblContainer!=nil) {
        [self.btnAdd2Favs removeFromSuperview];
        [self.btnAdd2Favs removeTarget:self
                                action:@selector(addToFavs:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self.lblCounter removeFromSuperview];
        [self.lblTitle removeFromSuperview];
        [self.lblContainer removeFromSuperview];
        self.lblCounter = nil;
        self.lblTitle = nil;
        self.btnAdd2Favs = nil;
        self.lblContainer = nil;
    }
}

#define IPHONES_FONT_SIZE ((CGFloat) 17.0f)
#define IPHONES_FAV_SIZE_WIDTH ((CGFloat) 31.0f)
#define IPHONES_FAV_SIZE_HEIGHT ((CGFloat) 21.0f)
#define IPHONES_COUNTER_WIDTH ((CGFloat) 48.0f)

#define IPADS_FONT_SIZE ((CGFloat) 32.0f)
#define IPADS_FAV_SIZE_WIDTH ((CGFloat) 44.0f)
#define IPADS_FAV_SIZE_HEIGHT ((CGFloat) 34.0f)
#define IPADS_COUNTER_WIDTH ((CGFloat) 86.0f)


-(void) setupLabel {
    [self clearLabels];
    if (!self.article) return;
    
    CGSize favSize = CGSizeMake(IS_IPAD ? IPADS_FAV_SIZE_WIDTH : IPHONES_FAV_SIZE_WIDTH,
                                IS_IPAD ? IPADS_FAV_SIZE_HEIGHT : IPHONES_FAV_SIZE_HEIGHT);
    CGRect frmbtn = CGRectMake(0, 0, favSize.width, favSize.height);
    
    self.btnAdd2Favs = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAdd2Favs.frame = frmbtn;
    self.btnAdd2Favs.contentMode = UIViewContentModeCenter;
    [self.btnAdd2Favs setImageEdgeInsets:UIEdgeInsetsMake(-4, 0, -4, 0)];
    self.btnAdd2Favs.backgroundColor = [UIColor whiteColor];
    [self.btnAdd2Favs addTarget:self
                         action:@selector(addToFavs:)
               forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frmcntr = CGRectOffset(frmbtn, frmbtn.size.width + 2, 0);
    self.lblCounter = [[UILabel alloc] initWithFrame: frmcntr];
    self.lblCounter.font = [UIFont systemFontOfSize: IS_IPAD ? IPADS_FONT_SIZE : IPHONES_FONT_SIZE];
    self.lblCounter.backgroundColor = [UIColor whiteColor];
    self.lblCounter.textAlignment = UITextAlignmentRight;
    
    CGRect frmtitle = CGRectOffset(frmcntr, frmcntr.origin.x + frmcntr.size.width + 2, 0);
    self.lblTitle = [[UILabel alloc] initWithFrame:frmtitle];
    self.lblTitle.font = [UIFont systemFontOfSize:IS_IPAD ? IPADS_FONT_SIZE : IPHONES_FONT_SIZE];
    self.lblTitle.backgroundColor = [UIColor whiteColor];
    self.lblTitle.textAlignment = UITextAlignmentCenter;
    
    CGRect frm = CGRectUnion(frmbtn, frmtitle);
    self.lblContainer = [[UIView alloc] initWithFrame:frm];
    self.lblContainer.backgroundColor = [UIColor blackColor];
    
    [self.lblContainer addSubview:self.btnAdd2Favs];
    [self.lblContainer addSubview:self.lblCounter];
    [self.lblContainer addSubview:self.lblTitle];
    
    [self.view addSubview:self.lblContainer];
}

- (void) addToFavs:(id)sender {
    if (self.article) {
        [self toggleInFavorites];
        [self fixFavsButton];
    }
}

- (void) fixFavsButton {
    [super fixFavsButton];
    
    NSString *favImgName = [self isInFavorites] ? NAVBAR_FAV_SEL_IMG : NAVBAR_FAV_IMG;
    [self.btnAdd2Favs setImage:[UIImage imageNamed:favImgName]
                      forState:UIControlStateNormal];
}

- (int) currentIndex {
    if (self.navigatorDelegate)
        return [self.navigatorDelegate currentItemIndex] + 1;
    return 0;
}
- (int) itemsCount {
    if (self.navigatorDelegate)
        return [self.navigatorDelegate itemsCount];
    return 0;
}

-(void) updateLabels {
    if (!self.article)
        return;
        
    [self fixFavsButton];
    
    int currIndex = [self currentIndex];
    int itmsCount = [self itemsCount];
    
    self.lblCounter.text = [NSString stringWithFormat:@"%d/%d", currIndex, itmsCount];
    
    [self.lblCounter sizeToFit];
    
    CGRect counterfrm = CGRectMake(0, 0,
                                   IS_IPAD ? IPADS_COUNTER_WIDTH : IPHONES_COUNTER_WIDTH,
                                   self.lblCounter.frame.size.height);
    counterfrm = CGRectOffset(counterfrm, self.btnAdd2Favs.frame.size.width + 2, 0);
    self.lblCounter.frame = counterfrm;
    
    if (currIndex == 0) {
        self.lblTitle.text = @"";
        [self.lblTitle sizeToFit];
    } else {
        NSString *title = [self.article title];
        self.lblTitle.text = title;
        [self.lblTitle sizeToFit];
    }
    CGRect titlefrm = CGRectMake(0, 0,
                                 self.lblTitle.frame.size.width + 6,
                                 self.lblTitle.frame.size.height);
    
    CGRect r = self.btnAdd2Favs.frame;
    self.btnAdd2Favs.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width, counterfrm.size.height);
    
    titlefrm = CGRectOffset(titlefrm, counterfrm.origin.x + counterfrm.size.width + 2, 0);
    self.lblTitle.frame = titlefrm;
    self.lblContainer.frame = CGRectUnion(self.btnAdd2Favs.frame, titlefrm);
}

@end
