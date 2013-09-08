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
#import "DPAppDelegate.h"
#import "UINavContentViewController.h"



@interface DPAppHelper ()

@property (strong, nonatomic) NSDictionary *freeDetails;
@property (strong, nonatomic) NSDictionary *freeCoverFlow;
@property (strong, nonatomic) NSDictionary *paidMainMenu;

@property (strong, nonatomic) Reachability* hostReach;
//@property (strong, nonatomic) Reachability* internetReach;
//@property (strong, nonatomic) Reachability* wifiReach;

@property (strong, nonatomic, readonly, getter = getFavorites) NSMutableDictionary *favorites;

@end

@implementation DPAppHelper


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
        [self configureReachability];
        [self addFreeDetails];
        [self addFreeCoverFlow];
        [self addPaidMainMenu];
        [self createSysSounds];
    }
    
    return self;
}

- (void) createDefaults {
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:CACHING_ENABLED], USE_DATA_CACHING_Key,
            nil];
    
    NSUserDefaults *usrDefaults = [NSUserDefaults standardUserDefaults];
    [usrDefaults registerDefaults:defaults];
    _useCache = [usrDefaults boolForKey:USE_DATA_CACHING_Key];
}

- (void) setCurrentLang:(NSString *)aCurrentLang {
    if (aCurrentLang && ![aCurrentLang isEqualToString:_currentLang]) {
        if ([aCurrentLang isEqualToString:@"en"] ||
            [aCurrentLang isEqualToString:@"el"])
            _currentLang = aCurrentLang;
        else
            _currentLang = @"en";

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isPurchased) {
                DPAppDelegate *del = [UIApplication sharedApplication].delegate;
                UINavContentViewController *main = (UINavContentViewController *)del.controller;
                [main doLocalize];
            }
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:DPN_currentLangChanged object:nil];
        });
    }
}

- (BOOL) calcIsPurchased {
    //return YES;
    
    NSUserDefaults *usrDefaults = [NSUserDefaults standardUserDefaults];
    BOOL productPurchased = [usrDefaults boolForKey:PRODUCT_IDENTIFIER];
    return productPurchased;
}

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
                                              image2Url:nil
                                          image2RollUrl:nil
                                                 parent:pid == -1 ? nil : [NSString stringWithFormat:@"%d", pid]]];
    }
    
    return [NSArray arrayWithArray:res];
}

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

- (NSString *) imageNameToCacheKey:(NSString *)url {
    NSString *sha1 = SHA1Digest(url);
    NSString *ext = [url pathExtension];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", sha1, ext];
    NSString *filepath = getDocumentsFilePath(filename);
    return filepath;
}

- (void) saveImageToCache:(NSString *)url data:(NSData *)imgData {
    NSString *filepath = [self imageNameToCacheKey:url];
    [imgData writeToFile:filepath atomically:YES];
}

- (NSData *) loadImageFromCache:(NSString *)url {
    NSData *result = nil;

    NSString *filepath = [self imageNameToCacheKey:url];    
    result = [NSData dataWithContentsOfFile:filepath];
    
    return result;
}
- (UIImage *) loadUIImageFromCache:(NSString *)url {
    UIImage *result = nil;
    if (!result) {
        NSData *data = [self loadImageFromCache:url];
        if (data)
            result = [UIImage imageWithData:data scale:DEVICE_SCALE];
    }
    return result;
}

- (BOOL) isImageInCache:(NSString *)url {
    NSString *filepath = [self imageNameToCacheKey:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

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
    return article && [self isKeyInFavorites:article.key];
}

- (void) addToFavorites:(Article *)article {
    if (article && ![self isArticleInFavorites:article]) {
        Article *element = [article copy];
        self.favorites[element.key] = element;
    }
    [self playSoundTing];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DPN_FavoritesChangedNotification
                                                            object:nil];
    });
}
- (void) removeFromFavorites:(Article *)article {
    if (article) {
        [self.favorites removeObjectForKey:article.key];
        [self doSaveFavorites:NO];
    }
    [self playSoundPinDrop];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DPN_FavoritesChangedNotification
                                                            object:nil];
    });
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

- (void) createSysSounds {
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"woosh" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_wooshSound);
    
    audioPath = [[NSBundle mainBundle] URLForResource:@"Blood Splattering On Wall-SoundBible.com-508930244" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_bloodSplatOnWallSound);
    
    audioPath = [[NSBundle mainBundle] URLForResource:@"Blood Splatters-SoundBible.com-125814492" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_bloodSplatSound);
    
    audioPath = [[NSBundle mainBundle] URLForResource:@"Magic Wand Noise-SoundBible.com-375928671" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_magicWandSound);
    
//    audioPath = [[NSBundle mainBundle] URLForResource:@"Open_Soda_Can-KP-1219969174" withExtension:@"mp3"];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &openSodaSound);
    audioPath = [[NSBundle mainBundle] URLForResource:@"Open Soda Can Sound" withExtension:@"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_openSodaSound);
    
    audioPath = [[NSBundle mainBundle] URLForResource:@"pin_dropping-Brian_Rocca-2084700791" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_pinDropSound);
    
//    audioPath = [[NSBundle mainBundle] URLForResource:@"Ting-Popup_Pixels-349896185" withExtension:@"mp3"];
//    OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &tingSound);
//    NSLog(@"tingSound status = %ld", status);
    audioPath = [[NSBundle mainBundle] URLForResource:@"Ting_Sound" withExtension:@"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_tingSound);
    
    audioPath = [[NSBundle mainBundle] URLForResource:@"Blood Squirt-SoundBible.com-1808242738" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_bloodSquirtSound);
    
    audioPath = [[NSBundle mainBundle] URLForResource:@"Electrical_Sweep-Sweeper-1760111493" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_electricalSweepSound);
   
    audioPath = [[NSBundle mainBundle] URLForResource:@"Spit_Splat_2-Mike_Koenig-1283100514" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &_spitSplatSound);
}

 

- (void) playSoundWoosh {
    AudioServicesPlaySystemSound(_wooshSound);
}

- (void) playSoundBloodSplatOnWall {
    AudioServicesPlaySystemSound(_bloodSplatOnWallSound);
}

- (void) playSoundBloodSplat {
    AudioServicesPlaySystemSound(_bloodSplatSound);
}

- (void) playSoundMagicWand {
    AudioServicesPlaySystemSound(_magicWandSound);
}

- (void) playSoundOpenSoda {
    AudioServicesPlaySystemSound(_openSodaSound);
}

- (void) playSoundPinDrop {
    AudioServicesPlaySystemSound(_pinDropSound);
}

- (void) playSoundTing {
    AudioServicesPlaySystemSound(_tingSound);
}

- (void) playSoundBloodSquirt {
    AudioServicesPlaySystemSound(_bloodSquirtSound);
}

- (void) playSoundElectricalSweep {
    AudioServicesPlaySystemSound(_electricalSweepSound);
}

- (void) playSoundSpitSplat {
    AudioServicesPlaySystemSound(_spitSplatSound);
}

- (void) dealloc {
    AudioServicesRemoveSystemSoundCompletion(_wooshSound);
    AudioServicesRemoveSystemSoundCompletion(_bloodSplatOnWallSound);
    AudioServicesRemoveSystemSoundCompletion(_bloodSplatSound);
    AudioServicesRemoveSystemSoundCompletion(_magicWandSound);
    AudioServicesRemoveSystemSoundCompletion(_openSodaSound);
    AudioServicesRemoveSystemSoundCompletion(_pinDropSound);
    AudioServicesRemoveSystemSoundCompletion(_tingSound);
    AudioServicesRemoveSystemSoundCompletion(_bloodSquirtSound);
    AudioServicesRemoveSystemSoundCompletion(_electricalSweepSound);
    AudioServicesRemoveSystemSoundCompletion(_spitSplatSound);
    
    
    AudioServicesDisposeSystemSoundID(_wooshSound);
    AudioServicesDisposeSystemSoundID(_bloodSplatOnWallSound);
    AudioServicesDisposeSystemSoundID(_bloodSplatSound);
    AudioServicesDisposeSystemSoundID(_magicWandSound);
    AudioServicesDisposeSystemSoundID(_openSodaSound);
    AudioServicesDisposeSystemSoundID(_pinDropSound);
    AudioServicesDisposeSystemSoundID(_tingSound);
    AudioServicesDisposeSystemSoundID(_bloodSquirtSound);
    AudioServicesDisposeSystemSoundID(_electricalSweepSound);
    AudioServicesDisposeSystemSoundID(_spitSplatSound);
}
@end
