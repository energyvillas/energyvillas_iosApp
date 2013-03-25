//
//  XMLParser.h
//  RankingServiceTest
//
//  Created by Damia Ferrer on 16/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleParser : NSObject <NSXMLParserDelegate> {
	int index;
}

@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, strong) NSMutableArray *articles;
@property (nonatomic)  BOOL storingCharacters;
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *publishDate;
@property (nonatomic, strong) NSString *articlevideo;
@property (nonatomic, strong) NSString *articlevideolength;

- (void)parseXMLFile:(NSString *)pathToFile;
- (void)print;

@end
