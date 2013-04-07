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

@end


@implementation DPBannersLoader

- (id) initWithController:(UIViewController *)controller group:(int)grpID {
    self = [super initWithController:controller];
    if (self) {
        self.groupID = grpID;
    }
    
    return self;
}

- (NSString *) cacheFileName {
    return [NSString stringWithFormat:@"banners-%d.dat", self.groupID];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    NSURL *ctgUrl = [NSURL URLWithString:BANNERS_URL];
    
    NSDictionary *ctgParams = [NSDictionary
                               dictionaryWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%d", self.groupID], @"group",
                               nil];
    
    ASIFormDataRequest *request = [self
                                   createRequest:ctgUrl
                                   keysAndValues:ctgParams];
    
    return request;
}

- (NSArray *) parseResponse:(NSString *)response {
    BannerParser *parser = [[BannerParser alloc] init];
	[parser parseXMLFile:response];
    NSArray *banners = [NSArray arrayWithArray:parser.banners];
    return banners;
}

@end