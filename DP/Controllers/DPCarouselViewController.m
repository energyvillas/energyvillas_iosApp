//
//  DPCarouselViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/16/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCarouselViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "Reachability.h"
#import "Article.h"
#import "DPArticlesLoader.h"
#import "DPImageContentViewController.h"
#import "DPVimeoPlayerViewController.h"
#import "DPHtmlContentViewController.h"

@interface DPCarouselViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) DPDataLoader *dataLoader;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) NSMutableArray *imageCache;
@property (strong, nonatomic) AFOpenFlowView *carousel;
@property int carouselCategoryID;

@end

@implementation DPCarouselViewController

@synthesize currentIndex = _currentIndex;

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
	// Do any additional setup after loading the view.
    self.carouselCategoryID = CTGID_CAROUSEL;
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self loadOpenFlow];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) makeCurrentImageAtIndex:(int)indx {
    _currentIndex = indx;
    if (self.currentIndex != -1 && self.carousel)
        [self.carousel setSelectedCover: self.currentIndex];

}

//==============================================================================

- (void) hookToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:DPN_currentLangChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void) onNotified:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:DPN_currentLangChanged]) {
        NSLog (@"Successfully received the ==DPN_currentLangChanged== notification!");
        
        [self doLocalize];
    }
    
    if ([[notification name] isEqualToString:kReachabilityChangedNotification]) {
        NSLog (@"Successfully received the ==kReachabilityChangedNotification== notification!");
        
        [self reachabilityChanged];
    }
}

- (void) doLocalize {
}


- (void) reachabilityChanged {
    [self loadData];
}

- (void) loadData {
    if (self.dataLoader == nil) {
        self.dataLoader = [[DPArticlesLoader alloc] initWithView:self.view
                                                        category:self.carouselCategoryID
                                                            lang:CURRENT_LANG];
        self.dataLoader.delegate = self;
    }
    
    if (self.datalist.count == 0 || self.dataLoader.dataRefreshNeeded)
        [self.dataLoader loadData];
}

//==============================================================================

#pragma mark - START DPDataLoaderDelegate

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist == nil || loader.datalist.count == 0) {
        [self loadLocalData];
    } else {
        self.datalist = self.dataLoader.datalist;
        [self dataLoaded];
    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    [self loadLocalData];
}

-(void) loadLocalData {
    NSArray *list = [[DPAppHelper sharedInstance] freeCoverFlowFor:CURRENT_LANG];
    self.datalist = list;
    [self dataLoaded];
}

-(void) setupImageCache {
    self.imageCache = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.datalist.count; i ++)
        self.imageCache[i] = [NSNull null];
    
}

- (void) dataLoaded {
    NSLog(@"1.carousel loaded %d articles", self.datalist.count);
    [self setupImageCache];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadOpenFlow];
    });
}
#pragma mark END DPDataLoaderDelegate

//==============================================================================

- (void) loadOpenFlow {
    if (self.datalist && self.datalist.count > 0) {
        if (self.carousel) {
            [self.carousel removeFromSuperview];
            self.carousel = nil;
        }
        
        CGRect frm = self.view.frame;
        frm = CGRectMake(0, 0, frm.size.width, frm.size.height);
        AFOpenFlowView *ofv = [[AFOpenFlowView alloc] initWithFrame:frm];
        ofv.viewDelegate = self;
        ofv.dataSource = self;
        
        
        NSLog(@"2.carousel loaded %d articles", self.datalist.count);
        [ofv setNumberOfImages:self.datalist.count];
        
        self.carousel = ofv;
        [self.view addSubview:self.carousel];
        [self makeCurrentImageAtIndex:self.currentIndex];
    }
}

//==============================================================================

#pragma mark START AFOpenFlowViewDelegate

- (void) openFlowView:(AFOpenFlowView *)openFlowView
                click:(int)index {
    
    Article *article = self.datalist[index];
    
    if (article.body != nil) {
        DPHtmlContentViewController *vc = [[DPHtmlContentViewController alloc] initWithHTML:article.body];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (article.videoUrl != nil) {
        NSString *videourl = article.videoUrl;
        DPVimeoPlayerViewController *vimeo = [[DPVimeoPlayerViewController alloc]
                                              initWithUrl:videourl];
        [self.navigationController pushViewController:vimeo animated:YES];
    } else if (article.imageUrl != nil) {
        DPImageContentViewController *vc = [[DPImageContentViewController alloc]
                                            initWithImageName:[self calcImageName:article.imageUrl]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
    _currentIndex = index;
}

//==============================================================================

#pragma mark START AFOpenFlowViewDatasource

- (void) openFlowView:(AFOpenFlowView *)openFlowView
 requestImageForIndex:(int)index {
    NSLog(@"3.carousel requested article at index %d", index);

    Article *article = self.datalist[index];
    NSString *imgName = article.imageThumbUrl ? article.imageThumbUrl : article.imageUrl;
    if (isLocalUrl(imgName)) {
        imgName = [self calcImageName:imgName];
        UIImage *img = [UIImage imageNamed:imgName];
        [openFlowView setImage:img forIndex:index];
    } else {
        // Check if image already exists in cache. If yes retrieve it from there, else go to internet...
        if(self.imageCache[index] != [NSNull null]) {
            UIImage *img = [UIImage imageWithData:self.imageCache[index]];
            [openFlowView setImage:img forIndex:index];
        }else{
            [self downloadImageUrl:imgName atIndex:index];
        }
    }
}

- (NSString *) calcImageName:(NSString *)baseName {
        @try {
            NSArray *parts = [baseName componentsSeparatedByString:@"."];
            if (parts && parts.count == 2) {
                NSString *lang = [DPAppHelper sharedInstance].currentLang;
                NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
                NSString *result = [NSString stringWithFormat:@"Carousel/%@_%@_%@.%@",
                                    parts[0], lang, orientation, parts[1]];
                NSLog(@"4.carousel calimageName base='%@' => calc='%@'", baseName, result);
                return result;
            }
            else
                return baseName;
        }
        @catch (NSException* exception) {
            NSLog(@"Uncaught exception: %@", exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
            return baseName;
        }
}

- (UIImage *) defaultImage {
    return nil; // this should return the missing image replacement
}

#pragma mark - === busy indication handling  ===

- (void) startIndicator {
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
    if(self.busyIndicator) {
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        self.busyIndicator = nil;
    }
}

#pragma mark -
#pragma mark === image downloading handling  ===

- (void) downloadImageUrl:(NSString *)imageUrl atIndex:(int)aIndex {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [imageRequest setDelegate:self];
    [imageRequest setDidFinishSelector:@selector(imageRequestDone:)];
    imageRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:aIndex], @"imageIndex", nil];
    [self.queue addOperation:imageRequest];
    //[self startIndicator];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
    //[self stopIndicator];
	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
	UIImage *aImage = [UIImage imageWithData:[request responseData]];
    
	if(aImage){
		[self.imageCache replaceObjectAtIndex:aIndex withObject:aImage];
        [self.carousel setImage:aImage forIndex:aIndex];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	//[self stopIndicator];
}



@end
