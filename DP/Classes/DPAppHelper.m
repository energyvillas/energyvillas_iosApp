//
//  DPAppHelper.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPConstants.h"
#import "DPAppHelper.h"
#import "DPImageInfo.h"
#import "Reachability.h"
#import "Article.h"
#import "Category.h"



@interface DPAppHelper ()

@property (strong, nonatomic) NSDictionary *freeDetails;
@property (strong, nonatomic) NSDictionary *freeBuyContent;
@property (strong, nonatomic) NSDictionary *freeCoverFlow;
@property (strong, nonatomic) NSDictionary *paidMainMenu;
//@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableDictionary *imageCache;
@property (strong, nonatomic) NSMutableDictionary *imageDataCache;

@property (strong, nonatomic) Reachability* hostReach;
//@property (strong, nonatomic) Reachability* internetReach;
//@property (strong, nonatomic) Reachability* wifiReach;

@property (strong, nonatomic, readonly, getter = getFavorites) NSMutableDictionary *favorites;

@end

@implementation DPAppHelper {

}



@synthesize connectionRequired = _connectionRequired;
@synthesize hostIsReachable = _hostIsReachable;
@synthesize currentLang = _currentLang;
//@synthesize isPurchased = _isPurchased;
@synthesize useCache = _useCache;
@synthesize favorites = _favorites;


+ (DPAppHelper *)sharedInstance {
    static dispatch_once_t once;
    static DPAppHelper * sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self createDefaults];
        _connectionRequired = true;
        _hostIsReachable = false;
//        _isPurchased = [self calcIsPurchased];
        [self configureReachability];
//        [self loadCategories];
        [self addFreeDetails];
        [self addFreeBuyContent];
        [self addFreeCoverFlow];
        [self addPaidMainMenu];
    }
    
    return self;
}

- (void) createDefaults {
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:CACHING_ENABLED], USE_DATA_CACHING,
            nil];
    
    NSUserDefaults *usrDefaults = [NSUserDefaults standardUserDefaults];
    [usrDefaults registerDefaults:defaults];
    _useCache = [usrDefaults boolForKey:USE_DATA_CACHING];
}

- (void) setCurrentLang:(NSString *)aCurrentLang {
    if (aCurrentLang && ![aCurrentLang isEqualToString:_currentLang]) {
        if ([aCurrentLang isEqualToString:@"en"] ||
            [aCurrentLang isEqualToString:@"el"])
            _currentLang = aCurrentLang;
        else
            _currentLang = @"en";

        [[NSNotificationCenter defaultCenter]
         postNotificationName:DPN_currentLangChanged object:nil];        
    }
}

- (BOOL) calcIsPurchased {
    //return YES;
    
    NSUserDefaults *usrDefaults = [NSUserDefaults standardUserDefaults];
    BOOL productPurchased = [usrDefaults boolForKey:PRODUCT_IDENTIFIER];
    return productPurchased;
}

#define FREE_BUY_CNT ((int) 3)

- (NSDictionary *) doGetDictionaryFrom:(NSString *)aFileName {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:aFileName];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    return dict;
}

- (NSArray *) doGetArticlesFrom:(NSDictionary *)dict lang:(NSString *)lang {
    NSDictionary *lfd = [dict objectForKey:lang];
    if (!lfd) {
        lang = @"en";
        lfd = [dict objectForKey:lang];
    }
    
    NSArray *categories = [dict objectForKey:@"Categories"];
    NSArray *titles = [lfd objectForKey:@"Titles"];
    NSArray *images = [lfd objectForKey:@"Images"];
    NSArray *videos = [lfd objectForKey:@"Videos"];
    
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for (int i=0; i<titles.count; i++) {
        [res addObject:[[Article alloc] initWithValues:[NSString stringWithFormat:@"%d", i]
                                                  lang:lang
                                              category:categories == nil ? -1 : [categories[i] intValue]
                                               orderNo:0
                                               forFree:NO
                                                 title:titles[i]
                                              imageUrl:images[i]
                                         imageThumbUrl:images[i]
                                                  body:nil
                                                   url:nil
                                           publishDate:nil
                                              videoUrl:videos == nil ? nil : videos[i]
                                           videolength:nil]];
    }
    
    return [NSArray arrayWithArray:res];
}

- (NSArray *) doGetCarouselArticlesFrom:(NSDictionary *)dict lang:(NSString *)lang {    
    NSArray *titles = [[dict objectForKey:@"Titles"]  objectForKey:lang];
    NSArray *images = [dict objectForKey:@"Images"];
    NSArray *thumbs = [dict objectForKey:@"Thumbs"];
    NSArray *videos = [dict objectForKey:@"Videos"];
    
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for (int i=0; i<titles.count; i++) {
        NSString *title = titles[i];
        NSString *imgurl = images[i];
        NSString *thumburl = thumbs[i];
        NSString *vidurl = videos[i];
        
        [res addObject:[[Article alloc] initWithValues:[NSString stringWithFormat:@"%d", i]
                                                  lang:lang
                                              category:-1
                                               orderNo:i
                                               forFree:YES
                                                 title:title
                                              imageUrl:imgurl
                                         imageThumbUrl:thumburl
                                                  body:nil
                                                   url:nil
                                           publishDate:nil
                                              videoUrl:vidurl
                                           videolength:nil]];
    }
    
    return [NSArray arrayWithArray:res];
}

- (NSArray *) doGetBuyArticlesFrom:(NSDictionary *)dict category:(int)ctgid lang:(NSString *)lang {
    NSString *strctgid = [NSString stringWithFormat:@"%d", ctgid];

    NSDictionary *categories = [dict objectForKey:@"Categories"];
    NSDictionary *ctgDict = [categories objectForKey:strctgid];
    NSArray *titles = [[ctgDict objectForKey:@"Titles"] objectForKey:lang];
    NSArray *images = [ctgDict objectForKey:@"Images"];
    NSArray *videos = [ctgDict objectForKey:@"Videos"];
    
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for (int i=0; i<titles.count; i++) {
        NSString *title = titles[i];
        NSString *imgurl = images != nil && images.count > i ? images[i] : nil;
        NSString *vidurl = videos != nil && videos.count > i ? videos[i] : nil;
        
        [res addObject:[[Article alloc] initWithValues:[NSString stringWithFormat:@"%d", i]
                                                  lang:lang
                                              category:ctgid
                                               orderNo:i
                                               forFree:YES
                                                 title:title
                                              imageUrl:imgurl
                                         imageThumbUrl:nil
                                                  body:nil
                                                   url:nil
                                           publishDate:nil
                                              videoUrl:vidurl
                                           videolength:nil]];
    }
    
    return [NSArray arrayWithArray:res];
}

- (void) addFreeDetails {
    self.freeDetails = [self doGetDictionaryFrom:@"free-details.plist"];
}

- (NSArray *) freeDetailsFor:(NSString *)lang {
    return [self doGetArticlesFrom:self.freeDetails lang:lang];
}

- (void) addFreeBuyContent{    
    self.freeBuyContent = [self doGetDictionaryFrom:@"free-Buy.plist"];
}

- (NSArray *) freeBuyContentFor:(int)ctgid lang:(NSString *)lang {
    return [self doGetBuyArticlesFrom:self.freeBuyContent category:ctgid lang:lang];
}

- (void) addFreeCoverFlow{    
    self.freeCoverFlow = [self doGetDictionaryFrom:@"free-CoverFlow.plist"];
}

- (NSArray *) freeCoverFlowFor:(NSString *)lang {
    return [self doGetCarouselArticlesFrom:self.freeCoverFlow lang:lang];
}

#pragma -
#pragma CATEGORIES

- (NSArray *) doGetCategoriesFrom:(NSDictionary *)dict lang:(NSString *)lang parent:(int)pid{
    NSDictionary *lfd = [dict objectForKey:lang];
    if (!lfd) {
        lang = @"en";
        lfd = [dict objectForKey:lang];
    }
    
    NSArray *categories = [dict objectForKey:@"Categories"];
    NSArray *titles = [lfd objectForKey:@"Titles"];
    NSArray *images = [lfd objectForKey:@"Images"];
    NSArray *imagerolls = [lfd objectForKey:@"ImageRolls"];
    
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for (int i=0; i<categories.count; i++) {
        NSString *imgname = images[i];
        [res addObject:[[Category alloc] initWithValues:[NSString stringWithFormat:@"%@", categories[i]]
                                                   lang:lang
                                                  title:titles[i]
                                               imageUrl:imgname
                                           imageRollUrl:imagerolls == nil ? nil : imagerolls[i]
                                                 parent:pid == -1 ? nil : [NSString stringWithFormat:@"%d", pid]]];
    }
    
    return [NSArray arrayWithArray:res];
}


//// i load it and keep it flat not as tree.
//- (void) loadCategories {
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSString *finalPath = [path stringByAppendingPathComponent:@"rootCategories.plist"];
//    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
//    
//    
//    NSMutableArray *roots = [[NSMutableArray alloc] initWithCapacity:dict.count];
////    NSMutableArray *subs = [[NSMutableArray alloc] initWithCapacity:dict.count];
//    
//    for (NSString *key in dict.allKeys) {
//        NSDictionary *ctg = dict[key];
//        NSDictionary *titles = ctg[@"titles"];
//        NSDictionary *images = ctg[@"images"];
//
//        id prntno = ctg[@"parent"];
//        NSString *prnt = prntno == nil ? nil : [NSString
//                                                stringWithFormat:@"%@", prntno];
//        
//        Category *category = [[Category alloc] initWithValues: key
//                                                         lang:@"en"
//                                                        title:titles[@"en"]
//                                                     imageUrl:images[@"en"]
//                                                       parent:prnt];
//
//        category.titles = [NSDictionary dictionaryWithDictionary:titles];
//        category.imageUrls = [NSDictionary dictionaryWithDictionary:images];
//        
////        if (category.parentId == -1)
//            [roots addObject: category];
////        else
////            [subs addObject:category];
//    }
//    
////    while (subs.count > 0) {
////        Category *sub = subs[0];
////        NSUInteger indx = [roots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
////            Category *it = obj;
////            *stop = it.Id == sub.parentId;
////            return it.Id == sub.parentId;
////        }];
////
////        if (indx == NSNotFound ) {
////            [subs removeObjectAtIndex:0];
////            continue;
////        }
////
////        Category *root = (Category *)roots[indx];
////        if (!root.children )
////            root.children = [[NSMutableArray alloc] init];
////
////        [root.children addObject:sub];
////    }
//    
//    self.categories = roots;
//}

//- (NSArray *) getSubCategoriesOf:(int)parentid {
//    NSMutableArray *list = [[NSMutableArray alloc] init];
//    for (Category *ctg in self.categories)
//        if (ctg.parentId == parentid)
//            [list addObject:ctg];
//    
//    return [NSArray arrayWithArray:list];
//}

- (void) addPaidMainMenu{
    self.paidMainMenu = [self doGetDictionaryFrom:@"paid-MainMenu.plist"];
}

- (NSArray *) paidMenuOfCategory:(int)aId lang:(NSString *)lang {
    if (aId == -1) {
        return [self doGetCategoriesFrom:self.paidMainMenu lang:lang parent:-1];
    } else {
        NSDictionary *subs = self.paidMainMenu[@"SubMenus"];
        NSString *menufile = subs[[NSString stringWithFormat:@"%d", aId]];
        
        return [self doGetCategoriesFrom:[self doGetDictionaryFrom:menufile]
                                    lang:lang
                                  parent:aId];
    }
}

#pragma mark -
#pragma mark transient image cache handling

- (void) saveImageToCache:(NSString *)url data:(NSData *)imgData {
//    if (!self.imageCache)
//        self.imageCache = [[NSMutableDictionary alloc] init];
//    if (!self.imageDataCache)
//        self.imageDataCache = [[NSMutableDictionary alloc] init];
//    
//    self.imageDataCache[url] = imgData;
//    UIImage *img = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
//    self.imageCache[url] = img;
    
    NSString *sha1 = SHA1Digest(url);
    NSLog(@"SHA1 = '%@'", sha1);
    NSString *ext = [url pathExtension];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", sha1, ext];
    NSString *filepath = getDocumentsFilePath(filename);
    [imgData writeToFile:filepath atomically:YES];
}

- (NSData *) loadImageFromCache:(NSString *)url {
    NSData *result = nil;
//    if (self.imageDataCache) {
//        result = self.imageDataCache[url];
//    }

    NSString *sha1 = SHA1Digest(url);
    NSLog(@"SHA1 = '%@'", sha1);
    NSString *ext = [url pathExtension];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", sha1, ext];
    NSString *filepath = getDocumentsFilePath(filename);
    
    result = [NSData dataWithContentsOfFile:filepath];
    
    return result;
}
- (UIImage *) loadUIImageFromCache:(NSString *)url {
    UIImage *result = nil;
//    if (self.imageCache) {
//        result = self.imageCache[url];
//    }
    if (!result) {
        NSData *data = [self loadImageFromCache:url];
        if (data)
            result = [UIImage imageWithData:data scale:DEVICE_SCALE];
    }
    return result;
}
//- (void) loadUIImageFromCache:(NSString *)url
//                    completed:(void (^)(NSString *url, UIImage *img))onCompleted {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UIImage *result = nil;
//        if (self.imageCache) {
//            result = self.imageCache[url];
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            onCompleted(url, result);
//        });
//    });
//}

#pragma mark -
#pragma mark reachability handling

- (void) configureReachability {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
	self.hostReach = [Reachability reachabilityWithHostName: USE_TEST_SITE ? BASE_HOST_NAME_TEST : BASE_HOST_NAME];
	[self.hostReach startNotifier];
	[self updateWithReachability: self.hostReach];
	
//    self.internetReach = [Reachability reachabilityForInternetConnection];
//	[self.internetReach startNotifier];
//	[self updateWithReachability: self.internetReach];
//    
//    self.wifiReach = [Reachability reachabilityForLocalWiFi];
//	[self.wifiReach startNotifier];
//	[self updateWithReachability: self.wifiReach];
}

- (void) reachabilityChanged: (NSNotification* )note {
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateWithReachability: curReach];
}

- (void) updateWithReachability: (Reachability*) curReach {
    if(curReach == self.hostReach)
	{
        _hostIsReachable = [curReach currentReachabilityStatus] != NotReachable;
        _connectionRequired = [curReach connectionRequired];
    }
    
//	if(curReach == self.internetReach)
//	{
//		[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
//	}
    
//	if(curReach == self.wifiReach)
//	{
//		[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
//	}
}

#pragma mark - favorites handling

- (NSMutableDictionary *) getFavorites {
    if (!_favorites)
        _favorites = [self doLoadFavorites];
    
    if (!_favorites)
        _favorites = [[NSMutableDictionary alloc] init];
    
    return _favorites;
}

- (NSString *) favoritesFileName {
    return getDocumentsFilePath(@"ev-favorites.dict");
}

- (BOOL) isKeyInFavorites:(NSString *)key {
    return self.favorites[key] != nil;
}

- (BOOL) isArticleInFavorites:(Article *)article {
    return [self isKeyInFavorites:article.key];
}

- (void) addToFavorites:(Article *)article {
    if (![self isArticleInFavorites:article]) {
        Article *element = [article copy];
        self.favorites[element.key] = element;
    }
}
- (void) removeFromFavorites:(Article *)article {
    [self.favorites removeObjectForKey:article.key];
    [self doSaveFavorites:NO];
}

- (NSMutableDictionary *) doLoadFavorites {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self favoritesFileName]];
}

- (void) saveFavorites {
    [self doSaveFavorites:YES];
}
- (void) doSaveFavorites:(BOOL)clear {
    [NSKeyedArchiver archiveRootObject:self.favorites toFile:[self favoritesFileName]];
//    [self.favorites writeToFile:[self favoritesFileName] atomically:YES];
    if (clear)
        _favorites = nil;
}

- (NSDictionary *) favoriteArticles {
    return [NSDictionary dictionaryWithDictionary:self.favorites];
}


@end
