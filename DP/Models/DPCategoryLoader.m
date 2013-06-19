//
//  DPCategoryLoader.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCategoryLoader.h"
#import "DPConstants.h"
#import "Category.h"
#import "CategoryParser.h"
#import "DPDataCache.h"


@interface DPCategoryLoader ()

@property int ctgID;
@property BOOL useDeviceType;
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *plistFile;
@property (strong, nonatomic) NSArray *localData;

@end



@implementation DPCategoryLoader {
}

- (void) dealloc {
    self.lang = nil;
    self.localData = nil;
    self.plistFile = nil;
}

- (id) initWithView:(UIView *)indicatorcontainer
        useInternet:(BOOL)useInternet
         useCaching:(BOOL)useCaching
           category:(int)ctgID
               lang:(NSString *)aLang
      useDeviceType:(BOOL)usedevicetype
      localResource:(NSString *)aplistFile {
    self = [super initWithView:indicatorcontainer useInternet:useInternet useCaching:useCaching];
    if (self) {
        self.useDeviceType = usedevicetype;
        self.ctgID = ctgID;
        self.lang = aLang;
        self.plistFile = aplistFile;
    }
    
    return self;
}

- (id) initWithView:(UIView *)indicatorcontainer
        useInternet:(BOOL)useInternet
         useCaching:(BOOL)useCaching
           category:(int)ctgID
               lang:(NSString *)aLang
      useDeviceType:(BOOL)usedevicetype
          localData:(NSArray *)localData {
    self = [super initWithView:indicatorcontainer useInternet:useInternet useCaching:useCaching];
    if (self) {
        self.useDeviceType = usedevicetype;
        self.ctgID = ctgID;
        self.lang = aLang;
        self.localData = localData;
    }
    
    return self;
}

- (void) loadFromPlist {
    if (self.localData)
        self.datalist = self.localData;
    else  if (_plistFile) {
        self.datalist = [self doGetCategoriesFrom:[self doGetDictionaryFrom:_plistFile]
                                             lang:self.lang
                                           parent:self.ctgID];
    }
}

- (NSDictionary *) doGetDictionaryFrom:(NSString *)aFileName {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:aFileName];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    return dict;
}

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
        [res addObject:[[Category alloc] initWithValues:[NSString stringWithFormat:@"%@", categories[i]]
                                                   lang:lang
                                                  title:titles[i]
                                               imageUrl:images[i]
                                           imageRollUrl:imagerolls == nil ? nil : imagerolls[i]
                                                 parent:pid == -1 ? nil : [NSString stringWithFormat:@"%d", pid]]];
    }
    
    return [NSArray arrayWithArray:res];
}


- (NSString *) cacheFileName {
    NSString *dvt = @"";
    if (self.useDeviceType)
        dvt = [NSString stringWithFormat: @"-%d", getDeviceType()];

    return [NSString stringWithFormat:@"categories-%@-%d%@.dat", self.lang, self.ctgID, dvt];
}

- (DPDataCache *) createDataCache {
    return [[DPDataCache alloc] initWithFile:[self cacheFileName]];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    NSURL *ctgUrl = [NSURL URLWithString:USE_TEST_SITE ? CATEGORIES_URL_TEST : CATEGORIES_URL];
    
    NSMutableDictionary *ctgParams = [NSMutableDictionary
                               dictionaryWithObjectsAndKeys:
                               self.lang, @"lang",
                               [NSString stringWithFormat:@"%d", self.ctgID], @"parentid",
                               nil];
    if (self.useDeviceType)
        ctgParams[@"devicetype"] = [NSString stringWithFormat: @"%d", getDeviceType()];
    
    ASIFormDataRequest *request = [self
                                   createRequest:ctgUrl
                                   keysAndValues:ctgParams];
    
    return request;
}

- (NSArray *) parseResponse:(NSString *)response {
    CategoryParser *parser = [[CategoryParser alloc] init];
	[parser parseXMLFile:response];
    NSArray *categories = [NSArray arrayWithArray:parser.categories];
    return categories;
}

@end
