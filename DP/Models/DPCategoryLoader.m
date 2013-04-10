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
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *plistFile;
@property (strong, nonatomic) NSArray *localData;

@end



@implementation DPCategoryLoader {
}

- (id) initWithView:(UIView *)indicatorcontainer
         useCaching:(BOOL)useCaching
           category:(int)ctgID
               lang:(NSString *)aLang
      localResource:(NSString *)aplistFile {
    self = [super initWithView:indicatorcontainer useCaching:useCaching];
    if (self) {
        self.ctgID = ctgID;
        self.lang = aLang;
        self.plistFile = aplistFile;
    }
    
    return self;
}

- (id) initWithView:(UIView *)indicatorcontainer
         useCaching:(BOOL)useCaching
           category:(int)ctgID
               lang:(NSString *)aLang
          localData:(NSArray *)localData {
    self = [super initWithView:indicatorcontainer useCaching:useCaching];
    if (self) {
        self.ctgID = ctgID;
        self.lang = aLang;
        self.localData = localData;
    }
    
    return self;
}



- (BOOL) useInternetForLoading {
    return self.ctgID != -1;
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
    
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for (int i=0; i<categories.count; i++) {
        [res addObject:[[Category alloc] initWithValues:[NSString stringWithFormat:@"%@", categories[i]]
                                                   lang:lang
                                                  title:titles[i]
                                               imageUrl:images[i]
                                                 parent:pid == -1 ? nil : [NSString stringWithFormat:@"%d", pid]]];
    }
    
    return [NSArray arrayWithArray:res];
}


- (NSString *) cacheFileName {
    return [NSString stringWithFormat:@"categories-%@-%d.dat", self.lang, self.ctgID];
}

- (DPDataCache *) createDataCache {
    return [[DPDataCache alloc] initWithFile:[self cacheFileName]];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    NSURL *ctgUrl = [NSURL URLWithString:CATEGORIES_URL];
    
    NSDictionary *ctgParams = [NSDictionary
                               dictionaryWithObjectsAndKeys:
                               self.lang, @"lang",
                               [NSString stringWithFormat:@"%d", self.ctgID], @"parentid",
                               nil];
    
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
