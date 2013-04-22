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
#import "AsyncImageView.h"
#import "FXImageView.h"

@interface DPCarouselViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) DPDataLoader *dataLoader;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) NSMutableArray *imageCache;
@property (strong, nonatomic) NSMutableDictionary *imageRequests;
//@property (strong, nonatomic) AFOpenFlowView *carousel;

@property (strong, nonatomic) UIView *lblContainer;
@property (strong, nonatomic) UILabel *lblCounter;
@property (strong, nonatomic) UILabel *lblTitle;

@property int carouselCategoryID;

@property (strong, nonatomic) iCarousel *icarousel;

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
    [self hookToNotifications];
    self.carouselCategoryID = CTGID_CAROUSEL;
    [self loadData];
}

-(void) clearDataLoader {
    if (self.dataLoader) {
        self.dataLoader.delegate = nil;
    }
    self.dataLoader = nil;
}

-(void) viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}
-(void) cleanup {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self clearDataLoader];
    [self clearCarousel];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //[self loadOpenFlow];
    [self loadCarousel];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self cleanup];
}
-(void) makeCurrentImageAtIndex:(int)indx {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.currentIndex != -1 && self.icarousel)
//            [self.icarousel setCurrentItemIndex:indx];
//    });
    _currentIndex = indx;
    if (self.currentIndex != -1 && self.icarousel)
        [self.icarousel setCurrentItemIndex:self.currentIndex];
//    if (self.currentIndex != -1 && self.carousel)
//        [self.carousel setSelectedCover: self.currentIndex];
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
#pragma mark - Info Labels

-(void) clearLabels {
    if (self.lblContainer!=nil) {
        [self.lblCounter removeFromSuperview];
        [self.lblTitle removeFromSuperview];
        [self.lblContainer removeFromSuperview];
        self.lblCounter = nil;
        self.lblTitle = nil;
        self.lblContainer = nil;
    }
}
-(void) setupLabels {
    [self clearLabels];
    CGRect frm = CGRectMake(0, 0, 50, 20);
    self.lblCounter = [[UILabel alloc] initWithFrame:frm];
    self.lblCounter.backgroundColor = [UIColor whiteColor];
    self.lblCounter.textAlignment = UITextAlignmentRight;
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectOffset(frm, 52, 0)];
    self.lblTitle.backgroundColor = [UIColor whiteColor];
    self.lblTitle.textAlignment = UITextAlignmentCenter;
    
    self.lblContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    [self.view addSubview:self.lblContainer];
    [self.lblContainer addSubview:self.lblCounter];
    [self.lblContainer addSubview:self.lblTitle];
}

-(void) updateLabels {
    if ((!self.icarousel) || (!self.datalist) || (self.datalist.count == 0))
        return;
    
    if ((self.currentIndex == -1) || (!self.datalist) || (self.datalist.count == 0))
        return;
    
    self.lblCounter.text = [NSString stringWithFormat:@"%d/%d",
                            self.icarousel.currentItemIndex + 1,
                            self.datalist.count];
    
    [self.lblCounter sizeToFit];
    
    CGRect counterfrm = CGRectMake(0, 0, 50, self.lblCounter.frame.size.height);
    self.lblCounter.frame = counterfrm;
    
    if (self.icarousel.currentItemIndex >= self.datalist.count) {
        self.lblTitle.text = @"";
        [self.lblTitle sizeToFit];
    } else {
    NSString *title = [self.datalist[self.icarousel.currentItemIndex] title];
        self.lblTitle.text = title;
        [self.lblTitle sizeToFit];
    }
    CGRect titlefrm = CGRectMake(counterfrm.size.width + 1, 0,
                                 self.lblTitle.frame.size.width + 6,
                                 self.lblTitle.frame.size.height);     
    self.lblTitle.frame = titlefrm;
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
    if (self.imageCache == nil) {
        self.imageCache = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.datalist.count; i ++)
            self.imageCache[i] = [NSNull null];
        
        self.imageRequests = [[NSMutableDictionary alloc] init];
    }
}

- (void) dataLoaded {
    NSLog(@"1.carousel loaded %d articles", self.datalist.count);
    [self setupImageCache];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self loadOpenFlow];
        [self loadCarousel];
    });
}
#pragma mark END DPDataLoaderDelegate

//==============================================================================

-(void) clearCarousel {
    if (self.icarousel) {
        [self.icarousel removeFromSuperview];
        self.icarousel.dataSource = nil;
        self.icarousel.delegate = nil;
        self.icarousel = nil;
    }
}
-(void) loadCarousel {
    if (self.datalist && self.datalist.count > 0) {
        [self clearCarousel];
        
        CGRect frm = self.view.frame;
        frm = CGRectMake(0, 0, frm.size.width, frm.size.height);
        iCarousel *ofv = [[iCarousel alloc] initWithFrame:frm];
        ofv.delegate = self;
        ofv.dataSource = self;
        ofv.type = iCarouselTypeCoverFlow2;
        
        
        NSLog(@"2.carousel loaded %d articles", self.datalist.count);
//        [ofv setNumberOfImages:self.datalist.count];
        
        self.icarousel = ofv;
        [self.view addSubview:self.icarousel];
        [self makeCurrentImageAtIndex:self.currentIndex];
        [self setupLabels];
        [self updateLabels];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionVisibleItems: {
            return value;
        }
        case iCarouselOptionShowBackfaces: {
            return NO;
        }
        case iCarouselOptionTilt:
        {
            return 0.7527f;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.973f;//1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return self.datalist.count;
}
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    _currentIndex = carousel.currentItemIndex;
    NSLog(@"######################set _curIndex to '%d'", _currentIndex);
    [self updateLabels];
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index == carousel.currentItemIndex)
        [self articleAtIndexTapped:index];
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
//    //create new view if no view is available for recycling
//    if (view == nil)
//    {
//        view = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)] autorelease];
//        view.contentMode = UIViewContentModeScaleAspectFit;
//    }
//    
//    //cancel any previously loading images for this view
//    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:view];
//    
//    //set image URL. AsyncImageView class will then dynamically load the image
//    ((AsyncImageView *)view).imageURL = [items objectAtIndex:index];
//
//    return view;
    
    //=======
    NSLog(@"3.carousel requested article at index %d", index);
    
    Article *article = self.datalist[index];
    NSString *imgName = article.imageThumbUrl ? article.imageThumbUrl : article.imageUrl;
    if (isLocalUrl(imgName)) {
        imgName = [self calcImageName:imgName];
        UIImage *img = [UIImage imageNamed:imgName];
        CGRect frm = CGRectMake(0, 0, img.size.width, img.size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frm];
        
//        FXImageView *imageView = [[FXImageView alloc] initWithFrame:frm];
//        imageView.contentMode = UIViewContentModeCenter;
//        imageView.asynchronous = YES;
//        imageView.reflectionScale = 0.5f;
//        imageView.reflectionAlpha = 0.35f;
//        imageView.reflectionGap = 10.0f;
//        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
//        imageView.shadowBlur = 5.0f;

////        imageView.cornerRadius = 10.0f;
//        imageView.layer.doubleSided = NO;
        imageView.image = img;
        return imageView;
    } else {
        // Check if image already exists in cache. If yes retrieve it from there, else go to internet...
//        AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectInset(self.icarousel.bounds, -30, -10)];
//        aiv.contentMode = UIViewContentModeCenter;
//
//        //set image URL. AsyncImageView class will then dynamically load the image
//        aiv.imageURL = [NSURL URLWithString:imgName];
//        return aiv;

        if(self.imageCache[index] != [NSNull null]) {
            UIImage *img = self.imageCache[index];//[UIImage imageWithData:self.imageCache[index]];
            
            CGRect frm = CGRectMake(0, 0, img.size.width, img.size.height);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frm];
            imageView.image = img;
            return imageView;
            //[openFlowView setImage:img forIndex:index];
        }else{
            [self downloadImageUrl:imgName atIndex:index];
            return nil;
        }
    }

}

////==============================================================================
//
//- (void) loadOpenFlow {
//    if (self.datalist && self.datalist.count > 0) {
//        if (self.carousel) {
//            [self.carousel removeFromSuperview];
//            self.carousel = nil;
//        }
//        
//        CGRect frm = self.view.frame;
//        frm = CGRectMake(0, 0, frm.size.width, frm.size.height);
//        AFOpenFlowView *ofv = [[AFOpenFlowView alloc] initWithFrame:frm];
//        ofv.viewDelegate = self;
//        ofv.dataSource = self;
//        
//        
//        NSLog(@"2.carousel loaded %d articles", self.datalist.count);
//        [ofv setNumberOfImages:self.datalist.count];
//        
//        self.carousel = ofv;
//        [self.view addSubview:self.carousel];
//        [self makeCurrentImageAtIndex:self.currentIndex];
//    }
//}
//
////==============================================================================
//
//#pragma mark START AFOpenFlowViewDelegate
//
//- (void) openFlowView:(AFOpenFlowView *)openFlowView
//                click:(int)index {
//    [self articleAtIndexTapped:index];
//}

-(void) articleAtIndexTapped:(int)index {
    Article *article = self.datalist[index];
    
    if (article.body != nil) {
        DPHtmlContentViewController *vc = [[DPHtmlContentViewController alloc] initWithHTML:article.body];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (article.videoUrl != nil && article.videoUrl.length > 0) {
        NSString *videourl = article.videoUrl;
        DPVimeoPlayerViewController *vimeo = [[DPVimeoPlayerViewController alloc]
                                              initWithUrl:videourl];
        [self.navigationController pushViewController:vimeo animated:YES];
    } else if (article.imageUrl != nil) {
        DPImageContentViewController *vc = nil;
        if (isLocalUrl(article.imageUrl))
            vc = [[DPImageContentViewController alloc] initWithImageName:[self calcImageName:article.imageUrl]];
        else
            vc = [[DPImageContentViewController alloc] initWithArticle:article];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
//    _currentIndex = index;
//}
//
////==============================================================================
//
//#pragma mark START AFOpenFlowViewDatasource
//
//- (void) openFlowView:(AFOpenFlowView *)openFlowView
// requestImageForIndex:(int)index {
//    NSLog(@"3.carousel requested article at index %d", index);
//
//    Article *article = self.datalist[index];
//    NSString *imgName = article.imageThumbUrl ? article.imageThumbUrl : article.imageUrl;
//    if (isLocalUrl(imgName)) {
//        imgName = [self calcImageName:imgName];
//        UIImage *img = [UIImage imageNamed:imgName];
//        [openFlowView setImage:img forIndex:index];
//    } else {
//        // Check if image already exists in cache. If yes retrieve it from there, else go to internet...
//        if(self.imageCache[index] != [NSNull null]) {
//            UIImage *img = [UIImage imageWithData:self.imageCache[index]];
//            [openFlowView setImage:img forIndex:index];
//        }else{
//            [self downloadImageUrl:imgName atIndex:index];
//        }
//    }
//}

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

//- (UIImage *) defaultImage {
//    return nil; // this should return the missing image replacement
//}
//
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
    
    if ([self.imageRequests objectForKey:imageUrl])
        return;

    [self.imageRequests setObject:imageUrl forKey:imageUrl];
    
    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [imageRequest setDelegate:self];
    [imageRequest setDidFinishSelector:@selector(imageRequestDone:)];
    imageRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:aIndex], @"imageIndex", nil];
    [self.queue addOperation:imageRequest];
    [self startIndicator];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];
	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
	UIImage *aImage = [UIImage imageWithData:[request responseData]];
    
	if(aImage){
		[self.imageCache replaceObjectAtIndex:aIndex withObject:aImage];
        //[self.carousel setImage:aImage forIndex:aIndex];
        [self.icarousel reloadItemAtIndex:aIndex animated:YES];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	//[self stopIndicator];
}



@end
