//
//  HouseOverviewLoader.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "HouseOverviewLoader.h"
#import "HouseOverviewParser.h"
#import "DPConstants.h"

@interface HouseOverviewLoader ()

@property (nonatomic) int categoryid;
@property (strong, nonatomic) NSString *lang;

@end

@implementation HouseOverviewLoader

- (void) dealloc {
    self.lang = nil;
}

- (id) initWithView:(UIView *)indicatorcontainer
               lang:(NSString *)aLang
           category:(int)ctgid{
    self = [super initWithView:indicatorcontainer useInternet:YES useCaching:YES];
    if (self) {
        self.categoryid = ctgid;
        self.lang = aLang;
    }
    
    return self;
}

- (NSString *) cacheFileName {
    return [NSString stringWithFormat:@"houseoverview-%@-%d.dat", self.lang, self.categoryid];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    NSURL *targetUrl = [NSURL URLWithString:USE_TEST_SITE ? HOUSE_OVERVIEW_URL_TEST : HOUSE_OVERVIEW_URL];
    
    NSDictionary *params = [NSDictionary
                               dictionaryWithObjectsAndKeys:
                               self.lang, @"lang",
                               [NSString stringWithFormat:@"%d", self.categoryid], @"cid",
                               nil];
    
    ASIFormDataRequest *request = [self
                                   createRequest:targetUrl
                                   keysAndValues:params];
    
    return request;
}

- (NSArray *) parseResponse:(NSString *)response {
    HouseOverviewParser *parser = [[HouseOverviewParser alloc] init];
	[parser parseXMLFile:response];
    NSArray *list = [NSArray arrayWithArray:parser.datalist];
    return list;
}

@end
