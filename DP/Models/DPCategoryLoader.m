//
//  DPCategoryLoader.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCategoryLoader.h"
#import "DPConstants.h"
#import "CategoryParser.h"


@interface DPCategoryLoader ()

@property int ctgID;
@property (strong, nonatomic) NSString *lang;

@end



@implementation DPCategoryLoader

- (id) initWithController:(UIViewController *)controller
                 category:(int)ctgID
                     lang:(NSString *)aLang {
    self = [super initWithController:controller];
    if (self) {
        self.ctgID = ctgID;
        self.lang = aLang;
    }
    
    return self;
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
