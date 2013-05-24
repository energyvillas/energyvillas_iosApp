//
//  DPBannersLoader.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPBannersLoader.h"
#import "ASIFormDataRequest.h"
#import "DPConstants.h"
#import <CommonCrypto/CommonDigest.h>
#import "Banner.h"
#import "BannerParser.h"


@interface DPBannersLoader ()

@property int groupID;
@property (strong, nonatomic) NSString *lang;

@end


@implementation DPBannersLoader

- (id) initWithView:(UIView *)indicatorcontainer
              group:(int)grpID
               lang:(NSString *)aLang {
    self = [super initWithView:indicatorcontainer useInternet:YES useCaching:YES];
    if (self) {
        self.groupID = grpID;
        self.lang = aLang;
    }
    
    return self;
}

- (NSString *) cacheFileName {
    return [NSString stringWithFormat:@"banners-%@-%d.dat", self.lang, self.groupID];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    NSURL *ctgUrl = [NSURL URLWithString:USE_TEST_SITE ? BANNERS_URL_TEST : BANNERS_URL];
    
    NSDictionary *ctgParams = [NSDictionary
                               dictionaryWithObjectsAndKeys:
                               self.lang, @"lang",
                               [NSString stringWithFormat:@"%d", self.groupID], @"group",
                               [NSString stringWithFormat: @"%d", getDeviceType()], @"devicetype",
                               nil];
    
    ASIFormDataRequest *request = [self
                                   createRequest:ctgUrl
                                   keysAndValues:ctgParams];
    
    return request;
}

- (NSArray *) parseResponse:(NSString *)response {
    BannerParser *parser = [[BannerParser alloc] init];
	[parser parseXMLFile:response];
    NSArray *banners = [parser.banners sortedArrayWithOptions:NSSortStable
                                              usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                  Banner *a1 = obj1;
                                                  Banner *a2 = obj2;
                                                  if(a1.orderNo < a2.orderNo)
                                                      return NSOrderedAscending;
                                                  else if(a1.orderNo > a2.orderNo)
                                                      return NSOrderedDescending;
                                                  else
                                                      return NSOrderedSame;
                                              }];
    
    return banners;
}

@end