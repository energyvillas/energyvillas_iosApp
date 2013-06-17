//
//  DPCTGViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 6/6/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCTGViewController.h"

#import "Category.h"
#import "DPCategoryLoader.h"

#import "DPAppHelper.h"
#import "DPConstants.h"

//==============================================================================

@interface DPCTGViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) DPDataLoader *dataLoader;
@property (strong, nonatomic) Category *category;

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) ASIHTTPRequest *request;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;

@property (nonatomic, readonly) int parentId;
@property (nonatomic, readonly) int categoryId;

@end

//==============================================================================

@implementation DPCTGViewController {
    BOOL useDeviceType;
}

@synthesize categoryId = _categoryId;
@synthesize parentId = _parentId;

//==============================================================================
#pragma mark - Constructors

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCategory:(int)ctgID fromParent:(int)pid useDeviceType:(BOOL)usedevicetype{
    self = [super init];
    if (self) {
        _parentId = pid;
        _categoryId = ctgID;
        useDeviceType = usedevicetype;
    }
    return self;
}

- (id) initWithCategory:(int)ctgID useDeviceType:(BOOL)usedevicetype {
    self = [super init];
    if (self) {
        _parentId = ctgID;
        _categoryId = -1;
        useDeviceType = usedevicetype;
    }
    return self;
}

//==============================================================================
#pragma mark - memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cleanupQueueAndRequest {
    if (self.request) {
        [self.request clearDelegatesAndCancel];
        [self.request setDidFailSelector:nil];
        [self.request setDidFinishSelector:nil];
        self.request.delegate = nil;
    }
    self.request = nil;
    
    if (self.queue) {
        for (id op in self.queue.operations)
            if ([op isKindOfClass:[ASIHTTPRequest class]]) {
                [((ASIHTTPRequest *)op) clearDelegatesAndCancel];
                [((ASIHTTPRequest *)op) setDidFailSelector:nil];
                [((ASIHTTPRequest *)op) setDidFinishSelector:nil];
                ((ASIHTTPRequest *)op).delegate = nil;
            }

        [self.queue cancelAllOperations];
    }
    
    self.queue = nil;
    
}
- (void) doCleanup {
    [self cleanupQueueAndRequest];
    
    [self clearDataLoader];

    [self.busyIndicator stopAnimating];
    self.busyIndicator = nil;
    
    while (self.imageView.subviews.count)
        [self.imageView.subviews[0] removeFromSuperview];

    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
}

- (void) dealloc {
    [self doCleanup];
}

//==============================================================================
#pragma mark - view loading/unloading

- (void) doSetup {
    [self doCleanup];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.imageView];
    
    self.busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: IS_IPAD ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleWhite];
    [self.busyIndicator stopAnimating];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self doSetup];
}

-(void)viewDidUnload {
    [self doCleanup];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//==============================================================================
#pragma mark - localization

- (void) doLocalize {
    [super doLocalize];
    if ((!self.category) || (![self.category.lang isEqualToString:CURRENT_LANG])) {
        [self cleanupQueueAndRequest];
        [self clearDataLoader];
        self.category = nil;
        [self loadData];
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
    }
}

//==============================================================================
#pragma mark - view layout

- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE && (!IS_IPAD) && [self showNavBar];
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    
    self.scrollView.frame = CGRectMake(0, top, w, h);
    self.imageView.frame = self.scrollView.bounds;
    [self doAddLoadingImage];

    [self doLoadCategoryImage];
}

- (void) doAddLoadingImage {
    self.imageView.image = nil;
    while (self.imageView.subviews.count)
        [self.imageView.subviews[0] removeFromSuperview];
    [self.imageView addSubview:createImageViewLoading(self.scrollView.bounds, NO, NO)];
    self.busyIndicator.center = self.imageView.center;
    [self.imageView addSubview:self.busyIndicator];
}
- (void) doLoadCategoryImage {
    if (self.category == nil) return;
    
    if (self.category) {
        NSString *imgName = IS_PORTRAIT ? self.category.imageUrl : self.category.imageRollUrl;
        
        if (isLocalUrl(imgName)) {
            [self doInitImageView:[UIImage imageNamed:self.category.imageUrl]];
        } else {
            UIImage *img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgName];
            if (img) {
                [self doInitImageView:img];
            } else {
                [self downloadImageUrl:imgName];
            }
        }
    }
}

- (void) doInitImageView:(UIImage *)img {
    while (self.imageView.subviews.count)
        [self.imageView.subviews[0] removeFromSuperview];
    
    CGSize imgSize = img.size;
    self.imageView.frame = CGRectMake(0, 0, imgSize.width, imgSize.height);
    self.imageView.image = img;
    self.imageView.contentMode = UIViewContentModeTopLeft;
    self.scrollView.contentSize = img.size;
}

//==============================================================================
#pragma mark - data loading

- (void) reachabilityChanged {
    [super reachabilityChanged];
    [self loadData];
}

- (void) loadData {
    if (![[DPAppHelper sharedInstance] hostIsReachable]) {
        showAlertMessage(nil,
                         DPLocalizedString(kERR_TITLE_CONNECTION_FAILED),
                         DPLocalizedString(kERR_MSG_TRY_LATER));
        
        return;
    }
    
    if (self.dataLoader == nil) {
        self.dataLoader = [[DPCategoryLoader alloc] initWithView:nil//self.imageView
                                                     useInternet:YES
                                                      useCaching:YES
                                                        category:self.parentId
                                                            lang:CURRENT_LANG
                                                   useDeviceType:useDeviceType
                                                       localData:nil];
        self.dataLoader.delegate = self;
    }
    
    if (self.category == nil || self.dataLoader.dataRefreshNeeded) {
        [self.busyIndicator startAnimating];
        [self.dataLoader loadData];
    }
}

-(void) clearDataLoader {
    if (self.dataLoader) {
        self.dataLoader.delegate = nil;
    }
    self.dataLoader = nil;
}

//==============================================================================
#pragma mark - dataloaderdelegate methods

- (void)loadFinished:(DPDataLoader *)loader {
    [self.busyIndicator stopAnimating];
    if (loader.datalist.count == 0) {
        showAlertMessage(nil,
                         DPLocalizedString(kERR_TITLE_INFO),
                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    } else {
        // find the category
        if (self.categoryId == -1)
            self.category = loader.datalist[0];
        else {
            for (Category *ctg in loader.datalist)
                if (ctg.Id == self.categoryId) {
                    self.category = ctg;
                    break;
                }
            
            [self categoryLoaded];
        }
    }
}

- (void) categoryLoaded {
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
}

- (void)loadFailed:(DPDataLoader *)loader {
    [self.busyIndicator stopAnimating];
    
    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
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
//        [self.request setDidFailSelector:@selector(imageRequestFailed:)];
        
        __block ASIHTTPRequest *r = self.request;
        __block id this = self;
        [self.request setCompletionBlock:^{ [this imageRequestDone:r]; }];
        [self.request setFailedBlock:^{ [this imageRequestFailed:r]; }];

        self.request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 imageUrl, @"imageName",
                                 nil];
        [self.queue addOperation:self.request];
        
        [self.busyIndicator startAnimating];
    }
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
    [self.busyIndicator stopAnimating];

    NSString *imgName = [request.userInfo objectForKey:@"imageName"];
    NSData *imgData = [request responseData];
	UIImage *aImage = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
    
    [[DPAppHelper sharedInstance] saveImageToCache:imgName data:imgData];
    
    [self doInitImageView:aImage];
    [self cleanupQueueAndRequest];
}

- (void) imageRequestFailed:(ASIHTTPRequest *)request {
    [self.busyIndicator stopAnimating];

	NSLog(@"Request Failed: %@", [request error]);
        
    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
    [self cleanupQueueAndRequest];
}

//==============================================================================
#pragma mark - nav bar button selection

//- (BOOL) showNavBar {
//    [super showNavBar];
//}
- (BOOL) showNavBarLanguages {
    return YES;
}
//- (BOOL) showNavBarAddToFav {
//    return NO;
//}
//- (BOOL) showNavBarSocial {
//    return NO;
//}
- (BOOL) showNavBarInfo {
    return NO;//[DPAppHelper sharedInstance].isPurchased;
}
//- (BOOL) showNavBarNavigator {
//    return self.navigatorDelegate != nil;
//}

//==============================================================================

@end
