//
//  DPNewNextViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPNewNextViewController.h"
#import "Category.h"
#import "DPCategoryLoader.h"
#import "DPAppHelper.h"
#import "DPConstants.h"
#import "Reachability.h"
#import "DPHtmlContentViewController.h"
#import "DPAppDelegate.h"
#import "DPNextHouseViewController.h"
#import "DPCTGViewController.h"
#import "DPButton.h"
#import "DPImageListDownloader.h"

@interface DPNewNextViewController ()

@property (strong, nonatomic) DPCategoryLoader *loaderNew;
@property (strong, nonatomic) DPCategoryLoader *loaderNext;

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicatorNew;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicatorNext;

@property (strong, nonatomic) NSOperationQueue *queue;
//@property (strong, nonatomic) NSArray *datalist;
//@property (strong, nonatomic) NSMutableArray *imageCache;
@property (strong, nonatomic) NSMutableDictionary *imageRequests;

@property (strong, nonatomic) UIButton *houseNew;
@property (strong, nonatomic) UIButton *houseNext;

@property (strong, nonatomic) UIImageView *loadingImageNew;
@property (strong, nonatomic) UIImageView *loadingImageNext;

@property (strong, nonatomic) Category *ctgNew, *ctgNewTemp;
@property (strong, nonatomic) Category *ctgNext;

@property (strong, nonatomic) DPImageListDownloader *imglistDownloader;

@end

@implementation DPNewNextViewController

- (void) setCtgNew:(Category *)ctgNew {
    _ctgNew = ctgNew;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self loadData];
}

-(void) viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self loadData];
}

- (void) viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self cleanup];
    
    self.loaderNew = nil;
    self.loaderNext = nil;
    
    self.busyIndicatorNew = nil;
    self.busyIndicatorNext = nil;
    
    self.queue = nil;

    self.imageRequests = nil;
    
    self.loadingImageNew = nil;
    self.loadingImageNext = nil;
    
    self.houseNew = nil;
    self.houseNext = nil;
    
    self.ctgNew = nil;
    self.ctgNext = nil;

    self.imglistDownloader = nil;
    self.ctgNewTemp = nil;
}

-(void) cleanup {
    if (self.queue) {
        [self stopIndicator:0];
        [self stopIndicator:1];
        
        [self.queue cancelAllOperations];

        for (id op in self.queue.operations)
            if ([op isKindOfClass:[ASIHTTPRequest class]]) {
                [((ASIHTTPRequest *)op) clearDelegatesAndCancel];
                [((ASIHTTPRequest *)op) setDidFinishSelector:nil];
                ((ASIHTTPRequest *)op).delegate = nil;
            }
    }
    
    self.queue = nil;
    self.imageRequests = nil;
    [self clearDataLoaders];
}

//==============================================================================
#pragma mark - notifications

- (void) reachabilityChanged {
    [super reachabilityChanged];
    [self loadData];
}

//==============================================================================
#pragma mark - localization
- (void) doLocalize {
    [super doLocalize];
    [self refresh];
}

-(void) refresh {
    [self cleanup];
    [self cleanSubViews];
    [self loadData];
}

//==============================================================================
#pragma mark - layout

- (void) cleanSubViews {
    UIView *newhouse = self.houseNew; self.houseNew = nil;
    UIView *nexthouse = self.houseNext; self.houseNext = nil;

    [newhouse removeFromSuperview];
    [nexthouse removeFromSuperview];
}

-(void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    
    CGFloat w = IS_PORTRAIT ? vf.size.width / 2.0f : vf.size.width;
    CGFloat h = IS_PORTRAIT ? vf.size.height : vf.size.height / 2.0f;
    
    CGFloat x = IS_PORTRAIT ? w : 0;
    CGFloat y = IS_PORTRAIT ? 0 : h;
    
    if (self.houseNew == nil) {
        self.houseNew = [self createViewWithFrame:CGRectMake(0, 0, w, h)];
        [self.view addSubview:self.houseNew];
    } else {
        self.houseNew.frame = CGRectMake(0, 0, w, h);
    }
    
    if (self.houseNext == nil) {
        self.houseNext = [self createViewWithFrame:CGRectMake(x, y, w, h)];
        [self.view addSubview:self.houseNext];
    } else {
        self.houseNext.frame = CGRectMake(x, y, w, h);
    }
    
    if (self.loadingImageNew)
        [self.loadingImageNew removeFromSuperview];
    
    if (self.ctgNew)
        [self internalLoadImageNew];
    else {
        self.loadingImageNew = [self prepareLoadingImageViewNew];
        [self.houseNew addSubview:self.loadingImageNew];
    }
    
    if (self.loadingImageNext)
        [self.loadingImageNext removeFromSuperview];
    
    if (self.ctgNext)
        [self internalLoadImageNext];
    else {
        self.loadingImageNext = [self prepareLoadingImageViewNext];
        [self.houseNext addSubview:self.loadingImageNext];
    }
}

-(UIImageView *) prepareLoadingImageViewNew {
    NSString *imgname = [NSString stringWithFormat:@"NewNext/new_load_model_photo_%@_%@.png",
                         CURRENT_LANG, IS_PORTRAIT ? @"v":@"h"];
    UIImageView *iv = [self prepareLoadingImageViewWithFrame:self.houseNew.bounds
                                                  imageNamed:imgname];
    return iv;
}
-(UIImageView *) prepareLoadingImageViewNext {
    NSString *imgname = [NSString stringWithFormat:@"NewNext/next_load_model_photo_%@_%@.png",
                         CURRENT_LANG, IS_PORTRAIT ? @"v":@"h"];
    UIImageView *iv = [self prepareLoadingImageViewWithFrame:self.houseNext.bounds
                                                  imageNamed:imgname];
    return iv;
}

-(UIImageView *) prepareLoadingImageViewWithFrame:(CGRect)frm imageNamed:(NSString *)imgname {
    UIImageView *iv = [[UIImageView alloc] initWithFrame:frm];
    iv.contentMode = UIViewContentModeCenter;
    iv.backgroundColor = [UIColor clearColor];
    [iv setImage:[UIImage imageNamed:imgname]];
    return iv;
}

- (UIButton *) createViewWithFrame:(CGRect)frame {
    DPButton *result = [DPButton buttonWithType:UIButtonTypeCustom];
    result.adjustsImageWhenHighlighted = NO;
    result.showsTouchWhenHighlighted = NO;
    result.extraLayerColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
    result.showExtraLayerOnHighlight = YES;
    result.frame = frame;
    result.contentMode = UIViewContentModeCenter;//ScaleAspectFit;
    result.backgroundColor = [UIColor clearColor];

    [result addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return result;
}

- (void)handleTap:(id)sender {
    if (sender == nil) return;
    // handling code
    
    UIViewController *vc = nil;
    if (sender == self.houseNew) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.ctgNew.imageUrl];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.ctgNew.imageRollUrl];
        
        vc = [[DPCTGViewController alloc] initWithCategory:self.ctgNew.Id
                                             useDeviceType:YES];
        
    } else if (sender == self.houseNext) {
        vc = [[DPNextHouseViewController alloc] initWithCategory:self.ctgNext.Id];
    }
    
    if (vc) {
        UINavigationController *nvc = nil;
        if (self.parentViewController)
            nvc = self.parentViewController.navigationController;
        if (!nvc) {
            DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
            nvc = [appdel findNavController];
        }
        [nvc pushViewController: vc animated: YES];
    }
}

//==============================================================================
#pragma mark - data handling

-(void) clearDataLoaders {
    if (self.loaderNew) 
        self.loaderNew.delegate = nil;
    
    if (self.loaderNext)
        self.loaderNext.delegate = nil;
    
    self.loaderNew = nil;    
    self.loaderNext = nil;
}

-(void) loadData {
    if (!self.loaderNew) {
        self.loaderNew = [[DPCategoryLoader alloc] initWithView:self.view
                                                    useInternet:YES
                                                     useCaching:YES
                                                       category:CTGID_NEW
                                                           lang:CURRENT_LANG
                                                  useDeviceType:YES
                                                      localData:nil];
        self.loaderNew.delegate = self;
    }
    
    if (!self.loaderNext) {
        self.loaderNext = [[DPCategoryLoader alloc] initWithView:self.view
                                                    useInternet:YES
                                                     useCaching:YES
                                                       category:CTGID_NEXT
                                                           lang:CURRENT_LANG
                                                  useDeviceType:YES
                                                      localData:nil];
        self.loaderNext.delegate = self;
    }
    
    if ((self.ctgNew == nil && self.ctgNewTemp == nil) || self.loaderNew.dataRefreshNeeded)
        [self.loaderNew loadData];

    if (self.ctgNext == nil || self.loaderNext.dataRefreshNeeded)
            [self.loaderNext loadData];
}

//==============================================================================
#pragma mark - START DPDataLoaderDelegate

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist == nil || loader.datalist.count == 0) {
        // no data found...ok! //[self loadLocalData];
    } else {
        if (loader == self.loaderNew) {
            self.ctgNewTemp = loader.datalist[0];
            [self dataLoadedNew];
        } else if (loader == self.loaderNext) {
            self.ctgNext = loader.datalist[0];
            [self dataLoadedNext];
        }
    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    // ok .. no data found???//[self loadLocalData];
}

-(void) dataLoadedNew {
    NSArray *list = @[NullIfEmpty(self.ctgNewTemp.imageUrl),
                      NullIfEmpty(self.ctgNewTemp.imageRollUrl),
                      NullIfEmpty(self.ctgNewTemp.image2Url),
                      NullIfEmpty(self.ctgNewTemp.image2RollUrl)];
    __block id this = self;
    self.imglistDownloader = [[DPImageListDownloader alloc] initWithList:list
                                                              onComplete:^(BOOL success) {
                                                                  if (success)
                                                                      [this loadCtgNewImages];
                                                              }];
}

-(void) loadCtgNewImages {
    self.imglistDownloader = nil;
    self.ctgNew = self.ctgNewTemp;
    self.ctgNewTemp = nil;
    [self.view setNeedsLayout];
}

-(void)internalLoadImageNew {
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.houseNew.bounds];
    iv.tag = 1000;
    NSString *imgName = IS_PORTRAIT ? self.ctgNew.imageUrl : self.ctgNew.imageRollUrl;
    NSString *img2Name = IS_PORTRAIT ? self.ctgNew.image2Url : self.ctgNew.image2RollUrl;
    
    BOOL hasViewed = [[NSUserDefaults standardUserDefaults] boolForKey:imgName];
    if (hasViewed || (NilIfEmpty(img2Name) == nil)) {
        [iv setImage:[[DPAppHelper sharedInstance] loadUIImageFromCache:imgName]];
    } else {
        [iv setAnimationImages:@[[[DPAppHelper sharedInstance] loadUIImageFromCache:imgName],
                                 [[DPAppHelper sharedInstance] loadUIImageFromCache:img2Name]]
         ];
        [iv setAnimationRepeatCount:0]; // infinite
        [iv setAnimationDuration:0.3]; // seconds
        [iv startAnimating];
    }
    
    UIView *oldiv = [self.houseNew viewWithTag:1000];
    if (oldiv)
        [oldiv removeFromSuperview];
    
    [self.houseNew addSubview:iv];
}

-(void) setupImageCache {
    if (self.imageRequests == nil) 
        self.imageRequests = [[NSMutableDictionary alloc] init];
}

- (void) dataLoadedNext {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadImage];
    });
}

- (void) loadImage {
    [self doLayoutSubViews:NO];
    [self internalLoadImageNext];
}

- (void) internalLoadImageNext {
        NSString *imgName = IS_PORTRAIT ? self.ctgNext.imageUrl : self.ctgNext.imageRollUrl;
        if (![self loadCachedImage:imgName]) {
            [self downloadImageUrl:imgName atIndex:1];
        }
}

- (BOOL) loadCachedImage:(NSString *)imgName {
    UIImage *img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgName];

    if (self.loadingImageNext)
        [self.loadingImageNext removeFromSuperview];
    
    if (img != nil) {
        [self.houseNext setImage:img forState:UIControlStateNormal];
        return YES;
    }
    
    self.loadingImageNext = [self prepareLoadingImageViewNext];
    [self.houseNext addSubview:self.loadingImageNext];
    
    return NO;
}

//==============================================================================
#pragma mark - === busy indication handling  ===

- (UIActivityIndicatorView *) makeIndicatorForView:(UIView *)container {
    UIActivityIndicatorView *busyIndicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:(IS_IPAD
                                                          ? UIActivityIndicatorViewStyleWhiteLarge
                                                          : UIActivityIndicatorViewStyleWhite)];
    busyIndicator.frame = CGRectMake(0, 0,
                                     busyIndicator.frame.size.width,
                                     busyIndicator.frame.size.height);
    busyIndicator.hidesWhenStopped = TRUE;

    busyIndicator.center = [self calcBoundsCenterOfView:container];
    [container addSubview:busyIndicator];
    [busyIndicator startAnimating];
    
    return busyIndicator;
}

- (CGPoint) calcBoundsCenterOfView:(UIView *)view {
    CGPoint cntr = view.center;
    cntr.x -= view.frame.origin.x;
    cntr.y -= view.frame.origin.y;
    return cntr;
}

- (void) startIndicator:(int)aIndex {
    if (aIndex == 0) {
        if (!self.busyIndicatorNew)
            self.busyIndicatorNew = [self makeIndicatorForView:self.houseNew];
    } else if (aIndex == 1) {
        if (!self.busyIndicatorNext)
            self.busyIndicatorNext = [self makeIndicatorForView:self.houseNext];
    }
}

-(void) doStopIndicator:(UIActivityIndicatorView *)busyIndicator {
    if (busyIndicator) {
        [busyIndicator stopAnimating];
        [busyIndicator removeFromSuperview];
    }
}
- (void) stopIndicator:(int)aIndex {
    if (aIndex == 0) {
        [self doStopIndicator:self.busyIndicatorNew];
        self.busyIndicatorNew = nil;
    } else if (aIndex == 1) {
        [self doStopIndicator:self.busyIndicatorNext];
        self.busyIndicatorNext = nil;
    }
}

//==============================================================================
#pragma mark - === image downloading handling  ===

- (void) downloadImageUrl:(NSString *)imageUrl atIndex:(int)aIndex {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    if ([self.imageRequests objectForKey:imageUrl])
        return;
    
    [self.imageRequests setObject:imageUrl forKey:imageUrl];
    
    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
//    [imageRequest setDelegate:self];
//    [imageRequest setDidFinishSelector:@selector(imageRequestDone:)];
    __block ASIHTTPRequest *ir = imageRequest;
    __block id this = self;
    [imageRequest setCompletionBlock:^{
        [this imageRequestDone:ir];
        this = nil;
        ir = nil;
    }];
    [imageRequest setFailedBlock:^{
        [this requestFailed:ir];
        this = nil;
        ir = nil;
    }];

    imageRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:aIndex], @"imageIndex",
                             imageUrl, @"imageName",
                             nil];
    [self.queue addOperation:imageRequest];
    [self startIndicator:aIndex];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
    
    [self stopIndicator:aIndex];

    NSString *imgName = [request.userInfo objectForKey:@"imageName"];
    NSData *imgData = [request responseData];
	UIImage *aImage = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
    
	if(aImage){
        [[DPAppHelper sharedInstance] saveImageToCache:imgName data:imgData];
        [self loadCachedImage:imgName];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
    
    [self stopIndicator:aIndex];
}


@end
