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



NSString *const FREE_DET_IMGNAME_FMT = @"free_detimage_10%i_%@.jpg";
NSString *const FREE_DET_IMGTITLE_FMT = @"FREE_DET_TITLE_10%i";

@interface DPAppHelper ()

@property (strong, nonatomic) NSDictionary *freeDetails;
@property (strong, nonatomic) NSDictionary *freeBuyContent;
@property (strong, nonatomic) NSDictionary *freeCoverFlow;
@property (strong, nonatomic) NSDictionary *paidMainMenu;
@property (strong, nonatomic) NSArray *categories;

@property (strong, nonatomic) Reachability* hostReach;
//@property (strong, nonatomic) Reachability* internetReach;
//@property (strong, nonatomic) Reachability* wifiReach;

@end

@implementation DPAppHelper {

}

@synthesize connectionRequired = _connectionRequired;
@synthesize hostIsReachable = _hostIsReachable;
@synthesize currentLang = _currentLang;

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
        _connectionRequired = true;
        _hostIsReachable = false;
        [self configureReachability];
        [self loadCategories];
        [self addFreeDetails];
        [self addFreeBuyContent];
        [self addFreeCoverFlow];
        [self addPaidMainMenu];
    }
    
    return self;
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
                                              category:categories == nil ? nil : [NSString stringWithFormat:@"%@", categories[i]]
                                                 title:titles[i]
                                              imageUrl:images[i]
                                                  body:nil
                                                   url:nil
                                           publishDate:nil
                                              videoUrl:videos == nil ? nil : videos[i]
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

- (NSArray *) freeBuyContentFor:(NSString *)lang {
    return [self doGetArticlesFrom:self.freeBuyContent lang:lang];
}

- (void) addFreeCoverFlow{    
    self.freeCoverFlow = [self doGetDictionaryFrom:@"free-CoverFlow.plist"];
}

- (NSArray *) freeCoverFlowFor:(NSString *)lang {
    return [self doGetArticlesFrom:self.freeCoverFlow lang:lang];
}

#pragma -
#pragma CATEGORIES

- (NSArray *) doGetCategoriesFrom:(NSDictionary *)dict lang:(NSString *)lang {
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
                                              category:categories == nil ? nil : [NSString stringWithFormat:@"%@", categories[i]]
                                                 title:titles[i]
                                              imageUrl:images[i]
                                                  body:nil
                                                   url:nil
                                           publishDate:nil
                                              videoUrl:videos == nil ? nil : videos[i]
                                           videolength:nil]];
    }
    
    return [NSArray arrayWithArray:res];
}


// i load it and keep it flat not as tree.
- (void) loadCategories {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"rootCategories.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    
    NSMutableArray *roots = [[NSMutableArray alloc] initWithCapacity:dict.count];
//    NSMutableArray *subs = [[NSMutableArray alloc] initWithCapacity:dict.count];
    
    for (NSString *key in dict.allKeys) {
        NSDictionary *ctg = dict[key];
        NSDictionary *titles = ctg[@"titles"];
        NSDictionary *images = ctg[@"images"];

        id prntno = ctg[@"parent"];
        NSString *prnt = prntno == nil ? nil : [NSString
                                                stringWithFormat:@"%@", prntno];
        
        Category *category = [[Category alloc] initWithValues: key
                                                         lang:@"en"
                                                        title:titles[@"en"]
                                                     imageUrl:images[@"en"]
                                                       parent:prnt];

        category.titles = [NSDictionary dictionaryWithDictionary:titles];
        category.imageUrls = [NSDictionary dictionaryWithDictionary:images];
        
//        if (category.parentId == -1)
            [roots addObject: category];
//        else
//            [subs addObject:category];
    }
    
//    while (subs.count > 0) {
//        Category *sub = subs[0];
//        NSUInteger indx = [roots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//            Category *it = obj;
//            *stop = it.Id == sub.parentId;
//            return it.Id == sub.parentId;
//        }];
//
//        if (indx == NSNotFound ) {
//            [subs removeObjectAtIndex:0];
//            continue;
//        }
//
//        Category *root = (Category *)roots[indx];
//        if (!root.children )
//            root.children = [[NSMutableArray alloc] init];
//
//        [root.children addObject:sub];
//    }
    
    self.categories = roots;
}

- (NSArray *) getSubCategoriesOf:(int)parentid {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (Category *ctg in self.categories)
        if (ctg.parentId == parentid)
            [list addObject:ctg];
    
    return [NSArray arrayWithArray:list];
}

- (void) addPaidMainMenu{
    self.paidMainMenu = [self doGetDictionaryFrom:@"paid-MainMenu.plist"];
}

- (NSArray *) paidArticlesOfCategory:(int)aId lang:(NSString *)lang {
    if (aId == -1) {
        return [self doGetArticlesFrom:self.paidMainMenu lang:lang];
    } else {
        NSDictionary *subs = self.paidMainMenu[@"SubMenus"];
        NSString *menufile = subs[[NSString stringWithFormat:@"%d", aId]];
        
        return [self doGetArticlesFrom:[self doGetDictionaryFrom:menufile] lang:lang];
    }
}


#pragma -
#pragma reachability handling

- (void) configureReachability {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
	self.hostReach = [Reachability reachabilityWithHostName: @"www.designprojectsapps.com"];
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


@end
