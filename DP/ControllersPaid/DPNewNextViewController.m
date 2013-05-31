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

@interface DPNewNextViewController ()

@property (strong, nonatomic) DPCategoryLoader *loaderNew;
@property (strong, nonatomic) DPCategoryLoader *loaderNext;

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
//@property (strong, nonatomic) NSArray *datalist;
//@property (strong, nonatomic) NSMutableArray *imageCache;
@property (strong, nonatomic) NSMutableDictionary *imageRequests;

@property (strong, nonatomic) UIImageView *houseNew;
@property (strong, nonatomic) UIImageView *houseNext;

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
    [self loadData];
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
}

-(void) cleanup {
    if (self.queue) {
        [self.queue cancelAllOperations];
        [self stopIndicator];
        
        for (id op in self.queue.operations)
            if ([op isKindOfClass:[ASIHTTPRequest class]]) {
                [((ASIHTTPRequest *)op) setDidFinishSelector:nil];
                ((ASIHTTPRequest *)op).delegate = nil;
            }
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
        if (self.ctgNew) [self internalLoadImage:self.ctgNew];
        if (self.ctgNext) [self internalLoadImage:self.ctgNext];
//        for (UIView *v in self.houseNext.subviews)
//            v.frame = self.houseNext.bounds;
    }
}

- (UIImageView *) createViewWithFrame:(CGRect)frame {
    UIImageView *result = [[UIImageView alloc] initWithFrame:frame];
    result.contentMode = UIViewContentModeScaleAspectFit;
    result.backgroundColor = [UIColor clearColor];
    
    //result.tag = contentIndex;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleTap:)];
    [result addGestureRecognizer:tapper];
    result.userInteractionEnabled = YES;
    
    return result;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender == nil) return;
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        
        DPDataElement * element = nil;
        UIViewController *vc = nil;
        if (sender.view == self.houseNew) {
            element = self.ctgNew;
            vc = [[DPHtmlContentViewController alloc] initWithCategory:element.Id lang:CURRENT_LANG];
        } else if (sender.view == self.houseNext) {
            element = self.ctgNext;
            vc = [[DPNextHouseViewController alloc] initWithCategory:element.Id];
        }
        
        if (vc) {
            DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
            UINavigationController *nvc = [appdel findNavController];
            [nvc pushViewController: vc animated: YES];
        }
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
    
    [self.loaderNew loadData];
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
    [self internalLoadImage:element];
}

- (void) internalLoadImage:(Category *)element {
    int indx = -1;
    if (element == self.ctgNew)
        indx = 0;
    else if (element == self.ctgNext)
        indx = 1;
    if (indx != -1) {
        NSString *imgName = IS_PORTRAIT ? element.imageUrl : element.imageRollUrl;
        if (![self loadCachedImage:imgName atIndex:indx])
            [self downloadImageUrl:imgName atIndex:indx];
    }
}

//- (NSString *) calcImageName:(NSString *)imgUrl isHighlight:(BOOL)ishighlight {
//    @try {
//        NSLog(@"NEW-NEXT - calcImageName - baseName='%@'", imgUrl);
//        NSArray *parts = [imgUrl componentsSeparatedByString:@"."];
//        if (parts && parts.count == 2) {
//            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
//            NSString *lang = CURRENT_LANG;
//            NSString *fmt = @"%@_%@_%@.%@";
//            
//            NSString *result = [NSString stringWithFormat:fmt,
//                                parts[0], orientation, lang, parts[1]];
//            
////            if (ishighlight) {
////                NSString *high = ishighlight ? @"roll" : @"";
////                
////                result = [NSString stringWithFormat:@"MainMenu/main_menu_%@_%@%@_%@.%@",
////                          parts[0], orientation, lang, parts[1]];
////            }
//            return result;
//        }
//        else
//            return imgUrl;
//    }
//    @catch (NSException* exception) {
//        NSLog(@"Uncaught exception: %@", exception.description);
//        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
//        return imgUrl;
//    }
//}

- (BOOL) loadCachedImage:(NSString *)imgName atIndex:(int)aIndex{
    if (aIndex >= self.view.subviews.count) return NO;
    
    UIImage *img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgName];
    if (img != nil) {
        UIImageView *iv = aIndex == 0 ? self.houseNew : (aIndex == 1 ? self.houseNext : nil);
        [iv setImage:img];
        return YES;
    }
    
    return NO;
}

//==============================================================================
#pragma mark - === busy indication handling  ===

- (void) startIndicator {
    return;
    if(!self.busyIndicator) {
		self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.busyIndicator.frame = CGRectMake((self.view.frame.size.width-25)/2,
                                              (self.view.frame.size.height-25)/2,
                                              25, 25);
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self.view addSubview:self.busyIndicator];
	}
    [self.busyIndicator startAnimating];
}

- (void) stopIndicator {
    return;
    if(self.busyIndicator) {
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        self.busyIndicator = nil;
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
    [self startIndicator];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];

	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
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
    
	//[self stopIndicator];
}


@end
