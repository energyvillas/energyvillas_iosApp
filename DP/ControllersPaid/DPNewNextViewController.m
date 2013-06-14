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

@property (strong, nonatomic) UIView *loadingImageNew;
@property (strong, nonatomic) UIView *loadingImageNext;

@property (strong, nonatomic) Category *ctgNew;
@property (strong, nonatomic) Category *ctgNext;

@end

@implementation DPNewNextViewController

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
}

-(void) cleanup {
    if (self.queue) {
        [self stopIndicator:0];
        [self stopIndicator:1];
        
        for (id op in self.queue.operations)
            if ([op isKindOfClass:[ASIHTTPRequest class]]) {
                [((ASIHTTPRequest *)op) clearDelegatesAndCancel];
                [((ASIHTTPRequest *)op) setDidFinishSelector:nil];
                ((ASIHTTPRequest *)op).delegate = nil;
            }

        [self.queue cancelAllOperations];
    }
    
    self.queue = nil;
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
//    [self cleanSubViews];
    
    if (self.houseNew == nil) {
        self.houseNew = [self createViewWithFrame:CGRectMake(0, 0, w, h)];
        [self.view addSubview:self.houseNew];
    } else {
        self.houseNew.frame = CGRectMake(0, 0, w, h);
//        for (UIView *v in self.houseNew.subviews)
//            v.frame = self.houseNew.bounds;
    }
    
    if (self.houseNext == nil) {
        self.houseNext = [self createViewWithFrame:CGRectMake(x, y, w, h)];
        [self.view addSubview:self.houseNext];
    } else {
        self.houseNext.frame = CGRectMake(x, y, w, h);
//        for (UIView *v in self.houseNext.subviews)
//            v.frame = self.houseNext.bounds;
    }
    
//    if (self.ctgNew)
        [self internalLoadImage:self.ctgNew index:0];
//    if (self.ctgNext)
        [self internalLoadImage:self.ctgNext index:1];
}

- (UIButton *) createViewWithFrame:(CGRect)frame {
    DPButton *result = [DPButton buttonWithType:UIButtonTypeCustom]; //[[UIImageView alloc] initWithFrame:frame];
    result.extraLayerColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    result.showExtraLayerOnHighlight = YES;
    result.frame = frame;
    result.contentMode = UIViewContentModeScaleAspectFit;
    result.backgroundColor = [UIColor clearColor];

//    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
//                                      initWithTarget:self action:@selector(handleTap:)];
//    [result addGestureRecognizer:tapper];
//    result.userInteractionEnabled = YES;
    [result addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return result;
}

- (void)handleTap:(id)sender {
    if (sender == nil) return;
    // handling code
    
    //Category * element = nil;
    UIViewController *vc = nil;
    if (sender == self.houseNew) {
        //element = self.ctgNew;
        vc = [[DPCTGViewController alloc] initWithCategory:self.ctgNew.Id
                                               // fromParent:self.ctgNew.parentId
                                             useDeviceType:YES];//[[DPHtmlContentViewController alloc] initWithCategory:element.Id lang:CURRENT_LANG];
    } else if (sender == self.houseNext) {
        //element = self.ctgNext;
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
    
    if (self.ctgNew == nil || self.loaderNew.dataRefreshNeeded)
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
            self.ctgNew = loader.datalist[0];
            [self dataLoaded:self.ctgNew];
        } else if (loader == self.loaderNext) {
            self.ctgNext = loader.datalist[0];
            [self dataLoaded:self.ctgNext];
        }
    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    // ok .. no data found???//[self loadLocalData];
}

-(void) setupImageCache {
    if (self.imageRequests == nil) 
        self.imageRequests = [[NSMutableDictionary alloc] init];
}

- (void) dataLoaded:(Category *)ctg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadImage:ctg];
    });
}

- (void) loadImage:(Category *)element {
    [self doLayoutSubViews:NO];
    [self internalLoadImage:element index:-1];
}

- (void) internalLoadImage:(Category *)element index:(int)index {
    int indx = element == nil ? index : -1;
    if (element) {
        if (element == self.ctgNew)
            indx = 0;
        else if (element == self.ctgNext)
            indx = 1;
    }
    
    if (indx != -1) {
        NSString *imgName = IS_PORTRAIT ? element.imageUrl : element.imageRollUrl;
        if (![self loadCachedImage:imgName atIndex:indx]) {
            [self downloadImageUrl:imgName atIndex:indx];
        }
    }
}

- (BOOL) loadCachedImage:(NSString *)imgName atIndex:(int)aIndex{
    if (aIndex >= self.view.subviews.count) return NO;
    
    UIImage *img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgName];

    if (aIndex == 0) {
        if (self.loadingImageNew)
            [self.loadingImageNew removeFromSuperview];
        
        if (img != nil) {
            [self.houseNew setImage:img forState:UIControlStateNormal];
            return YES;
        }
        
        self.loadingImageNew = createImageViewLoadingSized(CGRectInset(self.houseNew.bounds, 1, 1),
                                                           CGSizeMake(40.0f, 40.0f));
        [self.houseNew addSubview:self.loadingImageNew];
    } else if (aIndex == 1) {
        if (self.loadingImageNext)
            [self.loadingImageNext removeFromSuperview];

        if (img != nil) {
            [self.houseNext setImage:img forState:UIControlStateNormal];
            return YES;
        }

        self.loadingImageNext = createImageViewLoadingSized(CGRectInset(self.houseNext.bounds, 1, 1),
                                                            CGSizeMake(40.0f, 40.0f));
        [self.houseNext addSubview:self.loadingImageNext];
    }
    
    return NO;
}

//==============================================================================
#pragma mark - === busy indication handling  ===

- (UIActivityIndicatorView *) makeIndicatorForView:(UIView *)container {
    UIActivityIndicatorView *busyIndicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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
    [imageRequest setDelegate:self];
    [imageRequest setDidFinishSelector:@selector(imageRequestDone:)];
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
        [self loadCachedImage:imgName atIndex:aIndex];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
    
    [self stopIndicator:aIndex];
}


@end
