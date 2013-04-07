//
//  DPArticlesLoader.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPArticlesLoader.h"
#import "ASIFormDataRequest.h"
#import "DPConstants.h"
#import <CommonCrypto/CommonDigest.h>
#import "Article.h"
#import "ArticleParser.h"


@interface DPArticlesLoader ()

@property int categoryID;
@property (strong, nonatomic) NSString *lang;

@end


@implementation DPArticlesLoader

- (id) initWithView:(UIView *)indicatorcontainer  category:(int)ctgID lang:(NSString *)aLang {
    self = [super initWithView:indicatorcontainer ];
    if (self) {
        self.categoryID = ctgID;
        self.lang = aLang;
    }
    
    return self;
}

- (NSString *) cacheFileName {
    return [NSString stringWithFormat:@"articles-%@-%d.dat", self.lang, self.categoryID];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    NSURL *ctgUrl = [NSURL URLWithString:ARTICLES_URL];

    NSDictionary *ctgParams = [NSDictionary
                               dictionaryWithObjectsAndKeys:
                               self.lang, @"lang",
                               [NSString stringWithFormat:@"%d", self.categoryID], @"cid",
                               nil];
    
    ASIFormDataRequest *request = [self
                                   createRequest:ctgUrl
                                   keysAndValues:ctgParams];
    
    return request;
}

- (NSArray *) parseResponse:(NSString *)response {
    ArticleParser *parser = [[ArticleParser alloc] init];
	[parser parseXMLFile:response];
    NSArray *articles = [NSArray arrayWithArray:parser.articles];
    return articles;
}

@end
