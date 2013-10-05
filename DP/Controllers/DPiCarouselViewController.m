//
//  DPiCarouselViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 8/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPiCarouselViewController.h"
#import "Article.h"
#import "DPArticlesLoader.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "FXImageView.h"
#import "Reachability.h"
#import "DPImageContentViewController.h"
#import "DPVimeoPlayerViewController.h"
#import "DPHtmlContentViewController.h"


#define BUSY_IND_VIEW_TAG ((int)314159)

@interface DPiCarouselViewController ()

@property (strong, nonatomic) NSString *displayinglang;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) DPArticlesLoader *dataLoader;
@property (strong, nonatomic) NSArray *datalist;
//@property (strong, nonatomic) NSMutableArray *datalistPaths;
@property (strong, nonatomic) UIImage *loadingImage;
@property (strong, nonatomic) NSMutableDictionary *imageRequests;

@property (strong, nonatomic) UIView *lblFixedContainer;
@property (strong, nonatomic) UIView *lblContainer;
@property (strong, nonatomic) UIButton *btnAdd2Favs;
@property (strong, nonatomic) UILabel *lblCounter;
@property (strong, nonatomic) UILabel *lblTitle;


@property (strong, nonatomic) iCarousel *icarousel;

@end

@implementation DPiCarouselViewController{
    BOOL showSocials;
}


@synthesize currentIndex = _currentIndex;
@synthesize carouselCategoryID = _carouselCategoryID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithCtg:(int)ctgid currentIndex:(int)currIndx showSocials:(BOOL)aShowSocials {
    self = [super init];
    if (self) {
        _carouselCategoryID = ctgid;
        showSocials = aShowSocials;
        _currentIndex = currIndx;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self hookToNotifications];
    [self loadData:NO];
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

- (void) clearQueueAndOperations {
    if (self.queue) {
//        [self stopIndicator];
        
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
}

-(void) cleanup {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearQueueAndOperations];
    
    [self clearDataLoader];
    
    [self clearCarousel];
    
    self.busyIndicator = nil;
    self.dataLoader = nil;
    self.datalist = nil;
//    self.datalistPaths = nil;
    self.loadingImage = nil;
    self.imageRequests = nil;
    
    self.lblFixedContainer = nil;
    self.lblContainer = nil;
    self.btnAdd2Favs = nil;
    self.lblCounter = nil;
    self.lblTitle = nil;
    
    self.icarousel = nil;
    self.displayinglang = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    int ci = _currentIndex;
    //    if (self.datalist && self.datalist.count > 0) {
    //        [self setupLabels];
    //        [self updateLabels];
    //    }
    //    _currentIndex = ci;
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    if ([self dataLoadNeeded])
        [self loadData:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self clearCarousel];
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
    _currentIndex = indx;
    if (self.currentIndex != -1 && self.icarousel) {
        //[self.icarousel setCurrentItemIndex:self.currentIndex];
        [self.icarousel scrollToItemAtIndex:indx animated:NO];
    }
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
        [self doLocalize];
    }
    
    if ([[notification name] isEqualToString:kReachabilityChangedNotification]) {
        [self reachabilityChanged];
    }
}

- (void) doLocalize {
    [self reloadData];
}


- (void) reachabilityChanged {
    [self loadData:NO];
}

- (BOOL) dataLoadNeeded {
    BOOL shouldLoad = (self.datalist == nil ||
                       self.datalist.count == 0 ||
                       (self.dataLoader != nil && ![self.dataLoader.lang isEqualToString:CURRENT_LANG]) ||
                       (self.dataLoader != nil && self.dataLoader.dataRefreshNeeded));
    
    return shouldLoad;
}

- (void) reloadData {
    [self loadData:YES];
}

- (void) loadData:(BOOL)force {
    if (force || (self.dataLoader != nil && ![self.dataLoader.lang isEqualToString:CURRENT_LANG])) {
        [self clearQueueAndOperations];
        [self clearDataLoader];
        self.datalist = nil;
    }
    
    if (self.dataLoader == nil) {
        self.dataLoader = [[DPArticlesLoader alloc] initWithView:self.view
                                                        category:self.carouselCategoryID
                                                            lang:CURRENT_LANG];
        self.dataLoader.delegate = self;
    }
    
    if (force || [self dataLoadNeeded])
        [self.dataLoader loadData];
    else 
        [self dataLoaded];
}

//==============================================================================
#pragma mark - Info Labels

-(void) clearLabels {
    if (self.lblContainer!=nil) {
        [self.btnAdd2Favs removeFromSuperview];
        [self.btnAdd2Favs removeTarget:self
                                action:@selector(addToFavs:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self.lblCounter removeFromSuperview];
        [self.lblTitle removeFromSuperview];
        [self.lblContainer removeFromSuperview];
        [self.lblFixedContainer removeFromSuperview];
        
        self.lblCounter = nil;
        self.lblTitle = nil;
        self.btnAdd2Favs = nil;
        self.lblContainer = nil;
        self.lblFixedContainer = nil;
    }
}

#define IPHONES_FONT_SIZE ((CGFloat) 17.0f)
#define IPHONES_FAV_SIZE_WIDTH ((CGFloat) 31.0f)//30.0f)
#define IPHONES_FAV_SIZE_HEIGHT ((CGFloat) 21.0f)
#define IPHONES_COUNTER_WIDTH ((CGFloat) 48.0f)

#define IPADS_FONT_SIZE ((CGFloat) 32.0f)
#define IPADS_FAV_SIZE_WIDTH ((CGFloat) 44.0f)//48.0f)
#define IPADS_FAV_SIZE_HEIGHT ((CGFloat) 34.0f)
#define IPADS_COUNTER_WIDTH ((CGFloat) 86.0f)


-(void) setupLabels {
    [self clearLabels];
    //    if (showSocials)
    CGSize favSize = CGSizeMake(!showSocials ? 0.0f : (IS_IPAD ? IPADS_FAV_SIZE_WIDTH : IPHONES_FAV_SIZE_WIDTH),
                                IS_IPAD ? IPADS_FAV_SIZE_HEIGHT : IPHONES_FAV_SIZE_HEIGHT);
    CGRect frmbtn = CGRectMake(0, 0, favSize.width, favSize.height);
    CGFloat favbtnOfs = showSocials ? 2.0f : 0.0f;
    if (showSocials) {
        self.btnAdd2Favs = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnAdd2Favs.frame = frmbtn;
        self.btnAdd2Favs.contentMode = UIViewContentModeCenter;
        [self.btnAdd2Favs setImageEdgeInsets:UIEdgeInsetsMake(-4, 0, -4, 0)];
        self.btnAdd2Favs.backgroundColor = [UIColor whiteColor];
        [self.btnAdd2Favs setImage:[UIImage imageNamed:NAVBAR_FAV_IMG]
                          forState:UIControlStateNormal];
        [self.btnAdd2Favs setImage:[UIImage imageNamed:NAVBAR_FAV_SEL_IMG]
                          forState:UIControlStateSelected];
        
        [self.btnAdd2Favs addTarget:self
                             action:@selector(addToFavs:)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    CGRect frmcntr = CGRectOffset(frmbtn, frmbtn.size.width + favbtnOfs, 0);
    frmcntr.size.width = 0;
    self.lblCounter = [[UILabel alloc] initWithFrame: frmcntr];
    self.lblCounter.font = [UIFont systemFontOfSize: IS_IPAD ? IPADS_FONT_SIZE : IPHONES_FONT_SIZE];
    self.lblCounter.backgroundColor = [UIColor whiteColor];
    self.lblCounter.textAlignment = UITextAlignmentRight;
    
    CGRect frmtitle = CGRectOffset(frmcntr, frmcntr.size.width + 2, 0);
    frmtitle.size.width = 0;
    self.lblTitle = [[UILabel alloc] initWithFrame:frmtitle];
    self.lblTitle.font = [UIFont systemFontOfSize:IS_IPAD ? IPADS_FONT_SIZE : IPHONES_FONT_SIZE];
    self.lblTitle.backgroundColor = [UIColor whiteColor];
    self.lblTitle.textAlignment = UITextAlignmentCenter;
    
    CGRect frm = CGRectUnion(frmbtn, frmtitle);
    self.lblContainer = [[UIView alloc] initWithFrame:frm];
    self.lblContainer.backgroundColor = [UIColor blackColor];
    
    if (showSocials)
        [self.lblContainer addSubview:self.btnAdd2Favs];
    
    [self.lblContainer addSubview:self.lblCounter];
    [self.lblContainer addSubview:self.lblTitle];
    
    self.lblFixedContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                      self.view.bounds.size.width,
                                                                      self.lblContainer.bounds.size.height)];
    self.lblFixedContainer.backgroundColor = [UIColor clearColor];
    self.lblFixedContainer.autoresizingMask = UIViewAutoresizingNone;
    
    [self.lblFixedContainer addSubview:self.lblContainer];
    [self.view addSubview:self.lblFixedContainer];
}

- (void) addToFavs:(id)sender {
    if ((!self.icarousel) || (!self.datalist) || (self.datalist.count == 0))
        return;
    
    if ((self.currentIndex == -1) || (!self.datalist) || (self.datalist.count == 0))
        return;
    
    Article *article = self.datalist[self.icarousel.currentItemIndex];
    if (article) {
        [self toggleInFavorites:article];
        [self fixFavsButton:article];
    }
}

- (BOOL) isInFavorites:(Article *)article {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    BOOL infavs = [apphelper isArticleInFavorites:article];
    return infavs;
}

- (void) toggleInFavorites:(Article *)article {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    BOOL infavs = [self isInFavorites:article];
    if (infavs)
        [apphelper removeFromFavorites:article];
    else
        [apphelper addToFavorites:article];
}

- (void) fixFavsButton:(Article *)article {
    //    NSString *favImgName = [self isInFavorites:article] ? NAVBAR_FAV_SEL_IMG : NAVBAR_FAV_IMG;
    //    [self.btnAdd2Favs setImage:[UIImage imageNamed:favImgName]
    //                      forState:UIControlStateNormal];
    [self.btnAdd2Favs setSelected:[self isInFavorites:article]];
}

-(void) updateLabels {
    if ((!self.icarousel) || (!self.datalist) || (self.datalist.count == 0))
        return;
    
    if ((self.currentIndex == -1) || (!self.datalist) || (self.datalist.count == 0))
        return;
    
    
    Article *article = self.datalist[self.icarousel.currentItemIndex];
    
    [self fixFavsButton:article];
    
    self.lblCounter.text = [NSString stringWithFormat:@"%d/%d",
                            self.icarousel.currentItemIndex + 1,
                            self.datalist.count];
    
    [self.lblCounter sizeToFit];
    
    CGFloat counterfrmOfsX = self.btnAdd2Favs == nil ? 0.0f : self.btnAdd2Favs.frame.size.width + 2.0f;
    CGRect counterfrm = CGRectMake(0, 0,
                                   IS_IPAD ? IPADS_COUNTER_WIDTH : IPHONES_COUNTER_WIDTH,
                                   self.lblCounter.frame.size.height);
    counterfrm = CGRectOffset(counterfrm, counterfrmOfsX, 0);
    self.lblCounter.frame = counterfrm;
    
    if (self.btnAdd2Favs) {
        CGRect r = self.btnAdd2Favs.frame;
        self.btnAdd2Favs.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width, counterfrm.size.height);
    }
    
    self.lblTitle.frame = CGRectZero;
    if (self.icarousel.currentItemIndex >= self.datalist.count) {
        self.lblTitle.text = @"";
        [self.lblTitle sizeToFit];
    } else {
        NSString *title = [article title];
        if (title) {
            self.lblTitle.text = title;
            [self.lblTitle sizeToFit];
        }
    }
    
    if (!CGSizeEqualToSize(self.lblTitle.frame.size, CGSizeZero)) {
        CGRect titlefrm = CGRectMake(0, 0,
                                     self.lblTitle.frame.size.width + 6,
                                     self.lblTitle.frame.size.height);
        
        titlefrm = CGRectOffset(titlefrm, counterfrm.origin.x + counterfrm.size.width + 2, 0);
        self.lblTitle.frame = titlefrm;
    }
    
    if (self.btnAdd2Favs)
        self.lblContainer.frame = CGRectUnion(CGRectUnion(self.btnAdd2Favs.frame, counterfrm), self.lblTitle.frame);
    else
        self.lblContainer.frame = CGRectUnion(counterfrm, self.lblTitle.frame);
}
//==============================================================================

#pragma mark - START DPDataLoaderDelegate

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist == nil || loader.datalist.count == 0) {
        [self loadLocalData];
    } else {
        self.datalist = self.dataLoader.datalist;        
    }
//    [self preparePathsList];
    [self dataLoaded];
}

//- (void) preparePathsList {
//    self.datalistPaths = [NSMutableArray array];
//    
//    for (Article *article in self.datalist) {
//        NSString *filepath = nil;
//        NSString *imgName = article.imageThumbUrl ? article.imageThumbUrl : article.imageUrl;
//        if (isLocalUrl(imgName)) {
//            filepath = [self calcImageName:imgName];
//        } else {
//            filepath = [[DPAppHelper sharedInstance] imageNameToCacheKey:imgName];
//        }
//        
//        [self.datalistPaths addObject:filepath];
//    }
//}

- (void)loadFailed:(DPDataLoader *)loader {
    [self loadLocalData];
    [self dataLoaded];
}

-(void) loadLocalData {
    if (self.carouselCategoryID == CTGID_CAROUSEL || self.carouselCategoryID == CTGID_CAROUSEL_MORE) {
        NSArray *list = [[DPAppHelper sharedInstance] freeCoverFlowFor:CURRENT_LANG];
        self.datalist = list;
    }
}

-(void) setupImageCache {
    //    if (self.imageCache == nil) {
    //        self.imageCache = [[NSMutableArray alloc] init];
    //        for (int i = 0; i < self.datalist.count; i ++)
    //            self.imageCache[i] = [NSNull null];
    //    }
    
    if (self.imageRequests == nil)
        self.imageRequests = [[NSMutableDictionary alloc] init];
}

- (void) dataLoaded {
#ifdef LOG_CAROUSEL
    NSLog(@"1.carousel loaded %d articles", self.datalist.count);
#endif
    [self clearQueueAndOperations];
    [self setupImageCache];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self loadOpenFlow];
        [self clearCarousel];
        [self loadCarousel];
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
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
    //    if (self.datalist && self.datalist.count > 0 && [self dataLoadNeeded]) {
    //        [self clearCarousel];
    //    }
    
    int currindx = self.currentIndex;

    self.loadingImage = [self ensureImageLoadingFileExists];
    
    if (self.icarousel) {
        self.icarousel.frame = self.view.bounds;
        [self.icarousel reloadData];
    } else {
        if (!self.icarousel && self.datalist && self.datalist.count > 0) {
#ifdef LOG_CAROUSEL
            NSLog(@"2.carousel loaded %d articles", self.datalist.count);
#endif
            CGRect frm = self.view.frame;
            frm = CGRectMake(0, 0, frm.size.width, frm.size.height);
            self.icarousel = [[iCarousel alloc] initWithFrame:frm];
            
            self.icarousel.delegate = self;
            self.icarousel.dataSource = self;
            
            //        self.icarousel.scrollSpeed = 2.0f;
            //        self.icarousel.decelerationRate = 0.99f;
            //CGFloat scrspeed = self.icarousel.scrollSpeed;
            switch (self.carouselCategoryID) {
                case CTGID_CAROUSEL: {
                    self.icarousel.type = iCarouselTypeCoverFlow2;
                    //self.icarousel.scrollSpeed = IS_IPAD ? 0.7f : 0.7f;
                    break;
                }
                case CTGID_CAROUSEL_MORE: {
                    self.icarousel.type = iCarouselTypeLinear;
                    //self.icarousel.scrollSpeed = 0.35f;
                    break;
                }
                default: {
                    self.icarousel.type = iCarouselTypeCoverFlow2;
                    //self.icarousel.scrollSpeed = scrspeed * 0.7f;//0.35f;
                    break;
                }
            }
            
            [self.view addSubview:self.icarousel];
            
            //        [self setupLabels];
            //        //[self updateLabels];
            //
            //        [self makeCurrentImageAtIndex:self.currentIndex];
        }
    }
    
    [self setupLabels];
    
    [self makeCurrentImageAtIndex:currindx];
    [self updateLabels];
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
            return value;//self.datalist ? (self.datalist.count / 2.0f) : value;
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
            switch (self.carouselCategoryID) {
                case CTGID_CAROUSEL: return value * 1.973f;
                case CTGID_CAROUSEL_MORE: return value * 1.1f;
                default: return value * 1.973f;
                    //                default: return value;
            }
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
    //    _currentIndex = carousel.currentItemIndex;
    //#ifdef LOG_CAROUSEL
    //    NSLog(@"######################set _curIndex to '%d'", _currentIndex);
    //#endif
    //    [self updateLabels];
}

- (void) carouselDidScroll:(iCarousel *)carousel {
    _currentIndex = carousel.currentItemIndex;
    [self updateLabels];
#ifdef LOG_CAROUSEL
    NSLog(@"######################set _curIndex to '%d'", _currentIndex);
#endif
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index == carousel.currentItemIndex && (!carousel.isScrolling))
        [self articleAtIndexTapped:index];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
#ifdef LOG_CAROUSEL
    NSLog(@"3.carousel requested article at index %d", index);
#endif
    
    if (view == nil) {
        view = [self createImageView:nil];
    }
    FXImageView *imgview = (FXImageView *)view;
    
//    if (self.datalistPaths[index] == [NSNull null]) {
//        
//    } else {
//        NSString *imgfilepath = self.datalistPaths[index];
////        [imgview setImageWithContentsOfFile:imgfilepath];
//        [imgview setImage:[UIImage imageNamed:imgfilepath]];
////        [imgview setProcessedImage:[UIImage imageNamed:imgfilepath]];
//    }
    
    imgview.processedImage = self.loadingImage;
    [self attachBusyIndicatorToView:imgview];
    
    Article *article = self.datalist[index];
    NSString *imgName = article.imageThumbUrl ? article.imageThumbUrl : article.imageUrl;
    if (isLocalUrl(imgName)) {
        imgName = [self calcImageName:imgName];
        [imgview setImageWithContentsOfFile:imgName];
        [self indicatorAtView:imgview isBusy:NO];
    } else {
        // Check if image already exists in cache . If yes retrieve it from there, else go to internet...
        NSString *filepath = [[DPAppHelper sharedInstance] imageNameToCacheKey:imgName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
            [imgview setImageWithContentsOfFile:filepath];
            [self indicatorAtView:imgview isBusy:NO];
        } else {
//            [self ensureImageLoadingFileExists];
            [self downloadImageUrl:imgName atIndex:index];
//            [imgview setImageWithContentsOfFile:[self imageLoadingFilePath]];
//            [self attachBusyIndicatorToView:imgview];
            [self indicatorAtView:view isBusy:YES];
        }
    }
    
    return view;
}

-(UIImage *) captureView:(UIView *)scrView {
    CGRect rect = [scrView bounds];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, DEVICE_SCALE);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [scrView.layer renderInContext:context];
        UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return capturedImage;
}

-(CGSize) calcImageLoadingSize {
    // define image aspect and the fact we have BIG images
    CGSize szImageProto = CGSizeMake(3600.0f, 2400.0f);
    CGRect frm = [self calcFittingFrame:szImageProto];
    return frm.size;
}

-(NSString *) imageLoadingFilePath {
    CGSize sz = [self calcImageLoadingSize];
    NSString *filename = [NSString stringWithFormat: @"captured_img_loading_d%i_w%.0f_h%.0f.png", getDeviceType(), sz.width, sz.height];
    NSString *filepath = getDocumentsFilePath(filename);
    return filepath;
}

-(UIImage *) ensureImageLoadingFileExists {
    UIImage *img = nil;
    NSString *filepath = [self imageLoadingFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        CGRect frm = {0, 0, [self calcImageLoadingSize]};
        
        UIView *v = [[UIView alloc] initWithFrame:frm];
        v.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f]; //[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
        v.layer.cornerRadius = IS_IPAD ? 8.0f : 4.0f;
        v.layer.borderWidth = IS_IPAD ? 4.0f : 2.0;
        v.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.75f].CGColor;
        
        
        /////
        CGRect imgfrm = CGRectMake(0, 0,
                                   MIN(frm.size.width, IS_IPAD ? LOADING_IMG_MAX_WIDTH_IPAD : LOADING_IMG_MAX_WIDTH_IPHONE),
                                   MIN(frm.size.height, IS_IPAD ? LOADING_IMG_MAX_HEIGHT_IPAD : LOADING_IMG_MAX_HEIGHT_IPHONE));
        UIImageView *iv = [[UIImageView alloc] initWithFrame:imgfrm];
        iv.contentMode = UIViewContentModeScaleAspectFit;//Center;
        iv.image = [UIImage imageNamed:@"loading.png"];//img;
        
        iv.center = v.center;
        [v addSubview:iv];
        
        img = [self captureView:v];
        [UIImagePNGRepresentation(img) writeToFile:filepath atomically:YES];
    }

    if (img == nil) {
        NSData *imgdata = [NSData dataWithContentsOfFile:filepath];
        if (imgdata)
            img = [UIImage imageWithData:imgdata scale:DEVICE_SCALE];
    }
    
    return img;
}

- (void) indicatorAtView:(UIView *)view isBusy:(BOOL)isBusy {
    id sub = [view viewWithTag:BUSY_IND_VIEW_TAG];
    if (sub != nil && [sub isKindOfClass:[UIActivityIndicatorView class]]) {
        UIActivityIndicatorView *bi = sub;
        if (isBusy)
            [bi startAnimating];
        else
            [bi stopAnimating];
    }
}

- (void) attachBusyIndicatorToView:(UIView *)view {
    id sub = [view viewWithTag:BUSY_IND_VIEW_TAG];
    if (sub == nil) {
        UIActivityIndicatorView *bi = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle: IS_IPAD ? UIActivityIndicatorViewStyleWhiteLarge: UIActivityIndicatorViewStyleWhite];
        bi.hidesWhenStopped = TRUE;
        bi.tag = BUSY_IND_VIEW_TAG;
        bi.center = view.center;
        
        [view addSubview:bi];
        [bi startAnimating];
    }
}

//-(UIView *) createImageViewLoading  {
//    // define image aspect and the fact we have BIG images
//    CGSize szImageProto = CGSizeMake(3600.0f, 2400.0f);
//    CGRect frm = [self calcFittingFrame:szImageProto];
//    
//    UIView *v = [[UIView alloc] initWithFrame:frm];
//    v.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f]; //[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
//    v.layer.cornerRadius = IS_IPAD ? 8.0f : 4.0f;
//    v.layer.borderWidth = IS_IPAD ? 4.0f : 2.0;
//    v.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.75f].CGColor;
//    
//    
//    /////
//    CGRect imgfrm = CGRectMake(0, 0,
//                               MIN(frm.size.width, IS_IPAD ? LOADING_IMG_MAX_WIDTH_IPAD : LOADING_IMG_MAX_WIDTH_IPHONE),
//                               MIN(frm.size.height, IS_IPAD ? LOADING_IMG_MAX_HEIGHT_IPAD : LOADING_IMG_MAX_HEIGHT_IPHONE));
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:imgfrm];
//    iv.contentMode = UIViewContentModeScaleAspectFit;//Center;
//    iv.image = [UIImage imageNamed:@"loading.png"];//img;
//    
//    iv.center = v.center;
//    [v addSubview:iv];
//
//    /////
//    NSString *filepath = [self imageLoadingFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
//        UIImage *vci = [self captureView:v];
//        [UIImagePNGRepresentation(vci) writeToFile:filepath atomically:YES];
//    }
//    //////
//    
//    //////
//    UIActivityIndicatorView *bi = [[UIActivityIndicatorView alloc]
//                                   initWithActivityIndicatorStyle: IS_IPAD ? UIActivityIndicatorViewStyleWhiteLarge: UIActivityIndicatorViewStyleWhite];
//    bi.hidesWhenStopped = TRUE;
//    
//    bi.center = v.center;
//    
//    [v addSubview:bi];
//    [bi startAnimating];
//    
//    return v;
//}

-(CGRect) calcFittingFrame:(CGSize)szImage {
    CGRect frm = CGRectMake(0, 0, szImage.width, szImage.height);
    CGSize szCarousel = self.view.bounds.size; szCarousel.width = 0.8f * szCarousel.width;
//    CGSize szCarousel = self.icarousel.frame.size; szCarousel.width = 0.8f * szCarousel.width;
    if (szCarousel.width < szImage.width || szCarousel.height < szImage.height)
    {
        CGFloat ir = szImage.width / szImage.height;
        CGFloat cr = szCarousel.width / szCarousel.height;
        if (ir < cr)  { //  image is taller than carousel
            // we should fix image height to be equal to carousel height
            // and calc image width according to aspect and new height
            frm = CGRectMake(0, 0, szCarousel.height * ir, szCarousel.height);
        } else { // image is wider or same aspect ratio to that of carousel
            // we should fix image width to be equal to carousel width * 0.8
            // and calc image height according to aspect and new width
            frm = CGRectMake(0, 0, szCarousel.width, szCarousel.width / ir);
        }
    }
    
    return frm;
}

-(UIImageView *) createImageView:(UIImage *)image {
    CGSize szImageProto = CGSizeMake(3600.0f, 2400.0f);
    CGRect frm = [self calcFittingFrame:szImageProto];//image.size];
    return [self doCreateImageView:image frame:frm];
}


-(UIImageView *) doCreateImageView:(UIImage *)image frame:(CGRect)frame{
    return [self doCreateImageView:image frame:frame contentMode:UIViewContentModeScaleAspectFit];
}
-(UIImageView *) doCreateImageView:(UIImage *)image frame:(CGRect)frame contentMode:(UIViewContentMode)aContentMode{
    UIImageView *result = [self doCreateImageViewWithFrame:frame contentMode:aContentMode withReflection:YES];
    //result.image = image;
    return result;
}
-(UIImageView *) doCreateImageViewWithFrame:(CGRect)frame contentMode:(UIViewContentMode)aContentMode withReflection:(BOOL)addrefrection {
    FXImageView *imageView = [[FXImageView alloc] initWithFrame:frame];
    imageView.contentMode = aContentMode;
    imageView.asynchronous = YES;
    if (addrefrection) {
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.35f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
    }
    return imageView;
}

-(void) articleAtIndexTapped:(int)index {
    [self showArticleAtIndex:index animated:YES];
}

-(void) showArticleAtIndex:(int)index animated:(BOOL)animated{
    Article *article = self.datalist[index];
    
    if (article.body != nil) {
        DPHtmlContentViewController *vc = [[DPHtmlContentViewController alloc] initWithHTML:article.body];
        vc.navigatorDelegate = self;
        [self.navigationController pushViewController:vc animated:animated];
    } else if (article.videoUrl != nil && article.videoUrl.length > 0) {
        NSString *videourl = article.videoUrl;
        [DPVimeoPlayerViewController clsPlayVideoUrl:videourl];
    } else if (article.imageUrl != nil) {
        DPImageContentViewController *vc = nil;
        if (isLocalUrl(article.imageUrl))
            vc = [[DPImageContentViewController alloc] initWithImageName:[self calcImageName:article.imageUrl]];
        else
            vc = [[DPImageContentViewController alloc] initWithArticle:article showSocials:showSocials];
        
        vc.navigatorDelegate = self;
        [self.navigationController pushViewController:vc animated:animated];
    }
}

- (NSString *) calcImageName:(NSString *)baseName {
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *lang = [DPAppHelper sharedInstance].currentLang;
            NSString *result = [NSString stringWithFormat:@"Carousel/%@_%@.%@",
                                parts[0], lang, parts[1]];
#ifdef LOG_CAROUSEL
            NSLog(@"4.carousel calimageName base='%@' => calc='%@'", baseName, result);
#endif
            return result;
        }
        else
            return baseName;
    }
    @catch (NSException* exception) {
        return baseName;
    }
}

#pragma mark - === busy indication handling  ===

//- (void) startIndicator {
//    return;
//    if(!self.busyIndicator) {
//		self.busyIndicator = [[UIActivityIndicatorView alloc]
//                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//		self.busyIndicator.frame = CGRectMake((self.view.frame.size.width-25)/2,
//                                              (self.view.frame.size.height-25)/2,
//                                              25, 25);
//		self.busyIndicator.hidesWhenStopped = TRUE;
//        [self.view addSubview:self.busyIndicator];
//	}
//    [self.busyIndicator startAnimating];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view bringSubviewToFront:self.busyIndicator];
//    });
//}
//
//- (void) stopIndicator {
//    return;
//    if(self.busyIndicator) {
//        [self.busyIndicator stopAnimating];
//        [self.busyIndicator removeFromSuperview];
//        self.busyIndicator = nil;
//    }
//}

#pragma mark -
#pragma mark === image downloading handling  ===

- (void) downloadImageUrl:(NSString *)imageUrl atIndex:(int)aIndex {
    if ([self.imageRequests objectForKey:imageUrl])
        return;
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    

#ifdef LOG_CAROUSEL
    NSLog(@"will request image from url : ####'%@'####", imageUrl);
#endif
    [self.imageRequests setObject:imageUrl forKey:imageUrl];
    
    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    //[imageRequest setDelegate:self];
    //[imageRequest setDidFinishSelector:@selector(imageRequestDone:)];
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
//    [self startIndicator];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
//    [self stopIndicator];
	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
    NSString *imgName = [request.userInfo objectForKey:@"imageName"];
    NSData *imgData = [request responseData];
	UIImage *aImage = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
    
	if(aImage){
        //		[self.imageCache replaceObjectAtIndex:aIndex withObject:aImage];
        [[DPAppHelper sharedInstance] saveImageToCache:imgName data:imgData];
        //[self.carousel setImage:aImage forIndex:aIndex];
        [self.icarousel reloadItemAtIndex:aIndex animated:NO];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
//	[self stopIndicator];
}

#pragma mark - DPNavigatorDelegate methods
-(void) next {
    int nxt = self.currentItemIndex + 1;
    if (nxt < self.datalist.count) {
        [self.navigationController popViewControllerAnimated:NO];
        [self makeCurrentImageAtIndex:nxt];
        [self showArticleAtIndex:nxt animated:NO];
    }
}
-(void) prev {
    int prv = self.currentItemIndex - 1;
    if (prv >= 0) {
        [self.navigationController popViewControllerAnimated:NO];
        [self makeCurrentImageAtIndex:prv];
        [self showArticleAtIndex:prv animated:NO];
    }
}

- (int) currentItemIndex {
    if (self.icarousel && [self itemsCount] > 0)
        return self.currentIndex; // self.icarousel.currentItemIndex;
    
    return -1;
}

- (int) itemsCount {
    if (self.datalist)
        return self.datalist.count;
    
    return 0;
}
@end
