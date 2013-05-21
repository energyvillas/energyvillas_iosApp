//
//  DPNewNextViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPNewNextViewController.h"
#import "Article.h"
#import "DPArticlesLoader.h"
#import "DPAppHelper.h"
#import "DPConstants.h"
#import "Reachability.h"

@interface DPNewNextViewController ()

@property (strong, nonatomic) DPDataLoader *dataloader;

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) NSMutableArray *imageCache;
@property (strong, nonatomic) NSMutableDictionary *imageRequests;

@property (strong, nonatomic) UIView *houseNew;
@property (strong, nonatomic) UIView *houseNext;

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
    NSLog(@"NEW-NEXT viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self hookToNotifications];
}
-(void) viewDidUnload {
    NSLog(@"NEW-NEXT viewDidUnload");
    [super viewDidUnload];
    [self cleanup];
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"NEW-NEXT viewWillAppear");
    [super viewWillAppear:animated];
    [self loadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    NSLog(@"NEW-NEXT viewWillDisappear");
   [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    [self doLayoutSubViews];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"NEW-NEXT dealloc");
    [self cleanup];
}

-(void) cleanup {
    NSLog(@"NEW-NEXT cleanup");
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
}

//==============================================================================
#pragma mark - notifications

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

- (void) reachabilityChanged {
    NSLog(@"NEW-NEXT reachabilityChanged");
    [self loadData];
}

//==============================================================================
#pragma mark - localization
- (void) doLocalize {
    [self refresh];
}

-(void) refresh {
    [self cleanup];
    [self cleanSubViews];
    [self hookToNotifications];
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
        self.houseNew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        //self.houseNew.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:self.houseNew];
    } else {
        self.houseNew.frame = CGRectMake(0, 0, w, h);
        for (UIView *v in self.houseNew.subviews)
            v.frame = self.houseNew.bounds;
    }
    
    if (self.houseNext == nil) {
        self.houseNext = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        //self.houseNext.backgroundColor = [UIColor magentaColor];
        [self.view addSubview:self.houseNext];
    } else {
        self.houseNext.frame = CGRectMake(x, y, w, h);
        for (UIView *v in self.houseNext.subviews)
            v.frame = self.houseNext.bounds;
    }
}

//==============================================================================
#pragma mark - data handling

-(void) clearDataLoader {
    if (self.dataloader) {
        self.dataloader.delegate = nil;
    }
    self.dataloader = nil;
}

-(void) loadData {
    if (!self.dataloader) {
        self.dataloader = [[DPArticlesLoader alloc] initWithView:self.view
                                                     useInternet:YES
                                                      useCaching:YES
                                                        category:CTGID_NEW_NEXT
                                                            lang:CURRENT_LANG];
        self.dataloader.delegate = self;
    }
    
    NSLog(@"NEW-NEXT loadData");
    [self.dataloader loadData];
}

//==============================================================================
#pragma mark - START DPDataLoaderDelegate

- (void)loadFinished:(DPDataLoader *)loader {
    NSLog(@"NEW-NEXT loadFinished");
    if (loader.datalist == nil || loader.datalist.count == 0) {
        [self loadLocalData];
    } else {
        self.datalist = self.dataloader.datalist;
        [self dataLoaded];
    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    NSLog(@"NEW-NEXT loadFailed");
    [self loadLocalData];
}

-(void) loadLocalData {
    NSLog(@"NEW-NEXT loadLocalData");
    Article *newArticle = [[Article alloc] initWithValues:@"-1002"
                                                     lang:CURRENT_LANG
                                                 category:CTGID_NEW_NEXT
                                                  orderNo:1
                                                  forFree:NO
                                                    title:@"new"
                                                 imageUrl:@"NextModel/new_model.png"
                                            imageThumbUrl:nil
                                                     body:nil
                                                      url:nil
                                              publishDate:nil
                                                 videoUrl:nil
                                              videolength:nil];
    Article *nextArticle = [[Article alloc] initWithValues:@"-1001"
                                                     lang:CURRENT_LANG
                                                 category:CTGID_NEW_NEXT
                                                  orderNo:2
                                                  forFree:NO
                                                    title:@"next"
                                                 imageUrl:@"NextModel/next_model.png"
                                            imageThumbUrl:nil
                                                     body:nil
                                                      url:nil
                                              publishDate:nil
                                                 videoUrl:nil
                                              videolength:nil];
    NSArray *list = [NSArray arrayWithObjects:newArticle, nextArticle, nil];
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
    NSLog(@"NEW-NEXT loaded %d articles", self.datalist.count);
    [self setupImageCache];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadImages];
    });
}

- (void) loadImages {
    [self doLayoutSubViews:NO];
    
    for (int i = 0; i < self.datalist.count; i++) {
        Article *article = self.datalist[i];
        if (isLocalUrl(article.imageUrl)) {
            UIView *v = self.view.subviews[i];
            
            for (UIView *sv in v.subviews)
                [sv removeFromSuperview];
            
            v.contentMode = UIViewContentModeTopRight;
            
            CGRect frm = v.bounds;
            UIImageView *bottom = [[UIImageView alloc] initWithFrame:frm];
            bottom.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *img = [UIImage imageNamed:[self calcImageName:article.imageUrl isHighlight:NO]];
            if (img) {
                [bottom setImage:img];
                [v addSubview:bottom];
            }
            
            UIImageView *top = [[UIImageView alloc] initWithFrame:frm];
            UIImage *overlay = [UIImage imageNamed:@"NextModel/overlay_top.png"];
            if (overlay) {
                [top setImage:overlay];
                [v addSubview:top];
            }            
        } else
            [self downloadImageUrl:article.imageUrl atIndex:i];
    }
}

- (NSString *) calcImageName:(NSString *)imgUrl isHighlight:(BOOL)ishighlight {
    @try {
        NSLog(@"NEW-NEXT - calcImageName - baseName='%@'", imgUrl);
        NSArray *parts = [imgUrl componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            NSString *lang = CURRENT_LANG;
            NSString *fmt = @"%@_%@_%@.%@";
            
            NSString *result = [NSString stringWithFormat:fmt,
                                parts[0], orientation, lang, parts[1]];
            
//            if (ishighlight) {
//                NSString *high = ishighlight ? @"roll" : @"";
//                
//                result = [NSString stringWithFormat:@"MainMenu/main_menu_%@_%@%@_%@.%@",
//                          parts[0], orientation, lang, parts[1]];
//            }
            return result;
        }
        else
            return imgUrl;
    }
    @catch (NSException* exception) {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        return imgUrl;
    }
}

- (void) loadCachedImage:(int)aIndex{
    if (aIndex >= self.view.subviews.count) return;
    if (self.imageCache[aIndex] == [NSNull null]) return;
    
    UIImageView *iv = self.view.subviews[aIndex];
    [iv setImage:self.imageCache[aIndex]];
}

//==============================================================================
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
    imageRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:aIndex], @"imageIndex", nil];
    [self.queue addOperation:imageRequest];
    [self startIndicator];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];
	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
	UIImage *aImage = [UIImage imageWithData:[request responseData] scale:DEVICE_SCALE];
    
	if(aImage){
		[self.imageCache replaceObjectAtIndex:aIndex withObject:aImage];
        //[self.carousel setImage:aImage forIndex:aIndex];
        [self loadCachedImage:aIndex];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	//[self stopIndicator];
}


@end
