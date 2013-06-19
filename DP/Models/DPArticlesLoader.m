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
#import "DPAppHelper.h"


@interface DPArticlesLoader ()

@property int categoryID;
@property (strong, nonatomic) NSString *lang;
//@property (strong, nonatomic) NSString *plistFile;
//@property (strong, nonatomic) NSArray *localData;

@end


@implementation DPArticlesLoader

- (id) initWithView:(UIView *)indicatorcontainer
           category:(int)ctgID
               lang:(NSString *)aLang {
    self = [self initWithView:indicatorcontainer
                  useInternet:YES
                   useCaching:YES
                     category:ctgID
                         lang:aLang];
    
    return self;

}
//- (id) initWithView:(UIView *)indicatorcontainer
//        useInternet:(BOOL)aUseInternet
//         useCaching:(BOOL)aUseCaching
//           category:(int)ctgID
//               lang:(NSString *)aLang
//      localResource:(NSString *)aplistFile {
//    self = [super initWithView:indicatorcontainer useInternet:aUseInternet useCaching:aUseCaching];
//    if (self) {
//        self.categoryID = ctgID;
//        self.lang = aLang;
//        self.plistFile = aplistFile;
//    }
//    
//    return self;
//}

- (id) initWithView:(UIView *)indicatorcontainer
        useInternet:(BOOL)aUseInternet
         useCaching:(BOOL)aUseCaching
           category:(int)ctgID
               lang:(NSString *)aLang
          /*localData:(NSArray *)localData*/ {
    self = [super initWithView:indicatorcontainer useInternet:aUseInternet useCaching:aUseCaching];
    if (self) {
        self.categoryID = ctgID;
        self.lang = aLang;
//        self.localData = localData;
    }
    
    return self;
}

- (NSString *) cacheFileName {
    NSString *freepaid = IS_APP_FREE ? @"free" : @"paid";
    return [NSString stringWithFormat:@"articles-%@-%@-%d.dat", freepaid, self.lang, self.categoryID];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    NSURL *ctgUrl = [NSURL URLWithString:USE_TEST_SITE ? ARTICLES_URL_TEST : ARTICLES_URL];

    NSDictionary *ctgParams = [NSDictionary
                               dictionaryWithObjectsAndKeys:
                               self.lang, @"lang",
                               [NSString stringWithFormat:@"%d", self.categoryID], @"cid",
                               [NSString stringWithFormat:@"%d", IS_APP_FREE ? 1 : 0], @"forfree",
                               nil];
    
    ASIFormDataRequest *request = [self
                                   createRequest:ctgUrl
                                   keysAndValues:ctgParams];
    
    return request;
}

- (NSArray *) parseResponse:(NSString *)response {
    ArticleParser *parser = [[ArticleParser alloc] init];
	[parser parseXMLFile:response];
    NSArray *articles = [parser.articles sortedArrayWithOptions:NSSortStable
                                                usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                    Article *a1 = obj1;
                                                    Article *a2 = obj2;
                                                    if(a1.orderNo < a2.orderNo)
                                                        return NSOrderedAscending;
                                                    else if(a1.orderNo > a2.orderNo)
                                                        return NSOrderedDescending;
                                                    else
                                                        return NSOrderedSame;
                                                }];
    
    return articles;
}

- (void) dealloc {
    self.lang = nil;
}
@end
