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
#import "UIImage+FX.h"

@interface DPCarouselViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) DPDataLoader *dataLoader;
@property (strong, nonatomic) NSArray *datalist;
//@property (strong, nonatomic) NSMutableArray *imageCache;
@property (strong, nonatomic) NSMutableDictionary *imageRequests;
//@property (strong, nonatomic) AFOpenFlowView *carousel;

@property (strong, nonatomic) UIView *lblContainer;
@property (strong, nonatomic) UIButton *btnAdd2Favs;
@property (strong, nonatomic) UILabel *lblCounter;
@property (strong, nonatomic) UILabel *lblTitle;


@property (strong, nonatomic) iCarousel *icarousel;

@end

@implementation DPCarouselViewController

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

-(id) initWithCtg:(int)ctgid {
    self = [super init];
    if (self)
        _carouselCategoryID = ctgid;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self hookToNotifications];
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
    if (self.datalist && self.datalist.count > 0) {
        [self setupLabels];
        [self updateLabels];
    }
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
#define IPHONES_FAV_SIZE_WIDTH ((CGFloat) 30.0f)
#define IPHONES_FAV_SIZE_HEIGHT ((CGFloat) 20.0f)
#define IPHONES_COUNTER_WIDTH ((CGFloat) 48.0f)

#define IPADS_FONT_SIZE ((CGFloat) 32.0f)
#define IPADS_FAV_SIZE_WIDTH ((CGFloat) 48.0f)
#define IPADS_FAV_SIZE_HEIGHT ((CGFloat) 34.0f)
#define IPADS_COUNTER_WIDTH ((CGFloat) 86.0f)


-(void) setupLabels {
    [self clearLabels];
    CGSize favSize = CGSizeMake(IS_IPAD ? IPADS_FAV_SIZE_WIDTH : IPHONES_FAV_SIZE_WIDTH,
                                IS_IPAD ? IPADS_FAV_SIZE_HEIGHT : IPHONES_FAV_SIZE_HEIGHT);
    CGRect frmbtn = CGRectMake(0, 0, favSize.width, favSize.height);
    
    self.btnAdd2Favs = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAdd2Favs.frame = frmbtn;
    self.btnAdd2Favs.contentMode = UIViewContentModeCenter;
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
    NSString *favImgName = [self isInFavorites:article] ? NAVBAR_FAV_SEL_IMG : NAVBAR_FAV_IMG;
    [self.btnAdd2Favs setImage:[UIImage imageNamed:favImgName]
                      forState:UIControlStateNormal];
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
    
    CGRect counterfrm = CGRectMake(0, 0,
                                   IS_IPAD ? IPADS_COUNTER_WIDTH : IPHONES_COUNTER_WIDTH,
                                   self.lblCounter.frame.size.height);
    counterfrm = CGRectOffset(counterfrm, self.btnAdd2Favs.frame.size.width + 2, 0);
    self.lblCounter.frame = counterfrm;
    
    if (self.icarousel.currentItemIndex >= self.datalist.count) {
        self.lblTitle.text = @"";
        [self.lblTitle sizeToFit];
    } else {
        NSString *title = [article title];
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
    if (self.carouselCategoryID == CTGID_CAROUSEL) {
        NSArray *list = [[DPAppHelper sharedInstance] freeCoverFlowFor:CURRENT_LANG];
        self.datalist = list;
    }
    [self dataLoaded];
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
        
        NSLog(@"2.carousel loaded %d articles", self.datalist.count);
        
        CGRect frm = self.view.frame;
        frm = CGRectMake(0, 0, frm.size.width, frm.size.height);
        self.icarousel = [[iCarousel alloc] initWithFrame:frm];
        
        self.icarousel.delegate = self;
        self.icarousel.dataSource = self;
        
        CGFloat scrspeed = self.icarousel.scrollSpeed;
        switch (self.carouselCategoryID) {
            case CTGID_CAROUSEL: {
                self.icarousel.type = iCarouselTypeCoverFlow2;
                self.icarousel.scrollSpeed = IS_IPAD ? 0.35f : 0.25f;
                break;
            }
            case CTGID_CAROUSEL_MORE: {
                self.icarousel.type = iCarouselTypeLinear;
                self.icarousel.scrollSpeed = 0.35f;
                break;
            }
            default: {
                self.icarousel.type = iCarouselTypeCoverFlow2;
                self.icarousel.scrollSpeed = scrspeed * 0.7f;//0.35f;
                break;
            }
        }

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
            switch (self.carouselCategoryID) {
                case CTGID_CAROUSEL: return value * 1.973f;
                case CTGID_CAROUSEL_MORE: return value * 1.1f;
                default: return value * 1.973f;
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
    //create new view if no view is available for recycling
//    if (view == nil)
//    {
//        view = [self doCreateImageViewWithFrame:[self calcFittingFrame:self.icarousel.frame.size]
//                                    contentMode:UIViewContentModeScaleAspectFit
//                                 withReflection:YES];
//    }
//    
//    UIImageView *imgView = nil;
//    if ([view isKindOfClass:[UIImageView class]])
//        imgView = (UIImageView *)view;
//    
//    Article *article = self.datalist[index];
//    NSString *imgName = article.imageThumbUrl ? article.imageThumbUrl : article.imageUrl;
//    if (isLocalUrl(imgName)) {
//        imgName = [self calcImageName:imgName];
//        UIImage *img = [UIImage imageNamed:imgName];
//        if (imgView)
//            imgView.image = img;
//        else
//            return [self createImageView:img];
//    } else {
//        // Check if image already exists in cache. If yes retrieve it from there, else go to internet...
//        
//        UIImage *img = article.imageThumbUrl ? article.imageThumb : article.image;
//        if (img == nil) {
//            img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgName];
//            if (img) {
//                if (article.imageThumbUrl)
//                    article.imageThumb = img;
//                else
//                    article.image = img;
//            }
//        }
//        if (img != nil) {
//            if (imgView)
//                imgView.image = img;
//            else
//                return [self createImageView:img];
//        } else {
//            [self downloadImageUrl:imgName atIndex:index];
//            return [self createImageViewLoading];
//        }
//    }
//    
//    return view;
    
    //=======
    NSLog(@"3.carousel requested article at index %d", index);
    
    Article *article = self.datalist[index];
    NSString *imgName = article.imageThumbUrl ? article.imageThumbUrl : article.imageUrl;
    if (isLocalUrl(imgName)) {
        imgName = [self calcImageName:imgName];
        UIImage *img = [UIImage imageNamed:imgName];
        
        return [self createImageView:img];
    } else {
        // Check if image already exists in cache. If yes retrieve it from there, else go to internet...
        UIImage *img = article.imageThumbUrl ? article.imageThumb : article.image;
        if (img == nil) {
            img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgName];
            if (img != nil) {
                if (article.imageThumbUrl)
                    article.imageThumb = img;
                else
                    article.image = img;
            }
        }
        if (img != nil) {
            return  [self createImageView:img];
        } else {
            [self downloadImageUrl:imgName atIndex:index];
            return [self createImageViewLoading];
        }
    }
}

-(UIView *) createImageViewLoading  {
    CGSize szCarousel = self.icarousel.frame.size;
    szCarousel.width = 0.8f * szCarousel.width;
    szCarousel.height = szCarousel.height * 0.4f;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%@.png", CURRENT_LANG]];
    CGSize imgSize = img.size;
    img = [img imageScaledToFitSize:szCarousel];
    imgSize = img.size;
    
    CGSize loadingImgSize = CGSizeMake(3600.0f, 2400.0f);
    CGRect frm = [self calcFittingFrame:loadingImgSize];//]self.icarousel.frame.size];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectOffset(frm, 0.0f, -10.0f)];
    iv.contentMode = UIViewContentModeCenter;
    iv.image = img;
    
    UIView *v = [[UIView alloc] initWithFrame:frm];
    v.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f]; //[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    v.layer.cornerRadius = IS_IPAD ? 8.0f : 4.0f;
    v.layer.borderWidth = IS_IPAD ? 4.0f : 2.0;
    v.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.75f].CGColor;
    
    frm = v.bounds;
    UIActivityIndicatorView *bi = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle: IS_IPAD ? UIActivityIndicatorViewStyleWhiteLarge: UIActivityIndicatorViewStyleWhite];
    bi.frame = CGRectOffset(CGRectMake((frm.size.width-25)/2,
                                       (frm.size.height-25)/2,
                                       25, 25),
                            0, IS_IPAD ? 110 : IS_IPHONE ? 40 : 55);
    bi.hidesWhenStopped = TRUE;
    [v addSubview:iv];
    [v addSubview:bi];
    [bi startAnimating];

    return v;
}

-(CGRect) calcFittingFrame:(CGSize)szImage {
    CGRect frm;
    CGSize szCarousel = self.icarousel.frame.size; szCarousel.width = 0.8f * szCarousel.width;
    if (szCarousel.width > szImage.width && szCarousel.height > szImage.height)
        frm = CGRectMake(0, 0, szImage.width, szImage.height);
    else {
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
    CGRect frm = [self calcFittingFrame:image.size];
    return [self doCreateImageView:image frame:frm];
}


-(UIImageView *) doCreateImageView:(UIImage *)image frame:(CGRect)frame{
    return [self doCreateImageView:image frame:frame contentMode:UIViewContentModeScaleAspectFit];
}
-(UIImageView *) doCreateImageView:(UIImage *)image frame:(CGRect)frame contentMode:(UIViewContentMode)aContentMode{
    UIImageView *result = [self doCreateImageViewWithFrame:frame contentMode:aContentMode withReflection:YES];
    result.image = image;
    return result;
}
-(UIImageView *) doCreateImageViewWithFrame:(CGRect)frame contentMode:(UIViewContentMode)aContentMode withReflection:(BOOL)addrefrection {
    FXImageView *imageView = [[FXImageView alloc] initWithFrame:frame];
    imageView.contentMode = aContentMode;
    imageView.asynchronous = NO;
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

- (NSString *) calcImageName:(NSString *)baseName {
        @try {
            NSArray *parts = [baseName componentsSeparatedByString:@"."];
            if (parts && parts.count == 2) {
                NSString *lang = [DPAppHelper sharedInstance].currentLang;
//                NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
//                NSString *result = [NSString stringWithFormat:@"Carousel/%@_%@_%@.%@",
//                                    parts[0], lang, orientation, parts[1]];
                
                NSString *result = [NSString stringWithFormat:@"Carousel/%@_%@.%@",
                                    parts[0], lang, parts[1]];
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

#pragma mark -
#pragma mark === image downloading handling  ===

- (void) downloadImageUrl:(NSString *)imageUrl atIndex:(int)aIndex {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    if ([self.imageRequests objectForKey:imageUrl])
        return;

    NSLog(@"will request image from url : ####'%@'####", imageUrl);
    
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
//		[self.imageCache replaceObjectAtIndex:aIndex withObject:aImage];
        [[DPAppHelper sharedInstance] saveImageToCache:imgName data:imgData];
        //[self.carousel setImage:aImage forIndex:aIndex];
        [self.icarousel reloadItemAtIndex:aIndex animated:YES];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	//[self stopIndicator];
}



@end
