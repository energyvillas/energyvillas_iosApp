//
//  XMLParser.m
//  RankingServiceTest
//
//  Created by Damia Ferrer on 16/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleParser.h"
#import "Article.h"
//#import "RotationAppDelegate.h"


@implementation ArticleParser

/*
 to parse a XML file from path. 
 */
- (void)parseXMLFile:(NSString *)data {
	//array for the ranking
	self.articles = [[NSMutableArray alloc] init];
	index = 0;

	self.currentString = [NSMutableString string];
	self.storingCharacters = YES;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[data dataUsingEncoding: NSUTF8StringEncoding]];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
	self.currentString = nil;
}

#pragma mark NSXMLParser Parsing Callbacks

// Constants for the XML element names that will be considered during the parse. 
// Declaring these as static constants reduces the number of objects created during the run
// and is less prone to programmer error.
static NSString *kName_response = @"response";
static NSString *kName_responseCode = @"responseCode";
static NSString *kName_articles = @"articles";
static NSString *kName_article = @"article";

static NSString *kName_articleid = @"articleid";
static NSString *kName_categoryid = @"categoryid";
static NSString *kName_langcode = @"langcode";

static NSString *kName_orderno = @"orderno";
static NSString *kName_forfree = @"forfree";
static NSString *kName_imagethumburl = @"imagethumb";

static NSString *kName_title = @"title";
static NSString *kName_url = @"url";
static NSString *kName_image = @"image";
static NSString *kName_body = @"body";
static NSString *kName_publishDate = @"publishDate";
static NSString *kName_videourl = @"videourl";
static NSString *kName_videolength = @"videolength";
/*
 Sent by a parser object to its delegate when it encounters a start tag for a given element.
 Parameters
 parser: A parser object.
 elementName: A string that is the name of an element (in its start tag).
 namespaceURI: If namespace processing is turned on, contains the URI for the current namespace as a string object.
 qualifiedName: If namespace processing is turned on, contains the qualified name for the current namespace as a string object..
 attributeDict: A dictionary that contains any attributes associated with the element. Keys are the names of attributes, and values are attribute values.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	if ([elementName isEqualToString:kName_response]) {
		
	}else if ([elementName isEqualToString:kName_responseCode]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
	}else if ([elementName isEqualToString:kName_articles]) {
		
	}else if ([elementName isEqualToString:kName_article]) {
		
	}else if ([elementName isEqualToString:kName_title]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_url]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_articleid]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_categoryid]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_langcode]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
        

	}else if ([elementName isEqualToString:kName_forfree]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_orderno]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_imagethumburl]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
    
    
    
    }else if ([elementName isEqualToString:kName_image]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;

	}else if ([elementName isEqualToString:kName_publishDate]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;

	}else if ([elementName isEqualToString:kName_body]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_videourl]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_videolength]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
	}
}

/*
 Sent by a parser object to provide its delegate with a string representing all or part of the characters of the current element.
 Parameters
 parser: A parser object.
 string: A string representing the complete or partial textual content of the current element.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (self.storingCharacters) [self.currentString appendString:string];
}


/*
 Sent by a parser object to its delegate when it encounters an end tag for a specific element.
 
 Parameters
 parser: A parser object.
 elementName: A string that is the name of an element (in its end tag).
 namespaceURI: If namespace processing is turned on, contains the URI for the current namespace as a string object.
 qName: If namespace processing is turned on, contains the qualified name for the current namespace as a string object.
 */
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
	NSString *aElementValue = [[NSString alloc] initWithString: 
												[[self.currentString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"'"] 
												 stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"]];

	if ([elementName isEqualToString:kName_response]) {
		
	}else if ([elementName isEqualToString:kName_responseCode]) {
		self.responseCode=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_articles]) {
		
	}else if ([elementName isEqualToString:kName_article]) {
        NSString *clearedbody = nil;
        if (self.body && self.body.length > 0) 
            clearedbody = [[self.body stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
                                     stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            

        Article *article  = [[Article alloc] initWithValues:self.articleId
                                                       lang:self.langcode
                                                   category:[self.categoryId intValue]
                                                    orderNo:[self.orderNo intValue]
                                                    forFree:[self.forFree boolValue]
                                                      title:self.title
                                                   imageUrl:self.image
                                              imageThumbUrl:self.imageThumbUrl
                                                       body:clearedbody
                                                        url:self.url
                                                publishDate:self.publishDate
                                                   videoUrl:self.articlevideo
                                                videolength:self.articlevideolength];
        
//		Article *article  = [[Article alloc] init];
//		article.key=self.articleId;
//        article.lang=self.langcode;
//        article.category = [self.categoryId intValue];
//        article.forFree = [self.forFree boolValue];
//        article.orderNo = [self.orderNo intValue];
//        article.imageThumbUrl = self.imageThumbUrl;
//        
//		article.title = self.title;
//        article.body = clearedbody;
//
//		article.imageUrl = self.image;
//		article.url = self.url;
//		article.publishDate = self.publishDate;
//		article.videoUrl = self.articlevideo;
//		article.videolength = self.articlevideolength;
		
        [self.articles insertObject:article atIndex:index];
		index=index+1;
		article=nil;
        
	}else if ([elementName isEqualToString:kName_title]) {
		self.title=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_image]) {
		self.image=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_url]) {
		self.url=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_body]) {
		self.body=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_publishDate]) {
		self.publishDate=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_articleid]) {
		self.articleId=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_categoryid]) {
		self.categoryId=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_langcode]) {
		self.langcode=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_videourl]) {
		self.articlevideo=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_videolength]) {
		self.articlevideolength=[[NSString alloc] initWithString: aElementValue];

	
	}else if ([elementName isEqualToString:kName_forfree]) {
		self.forFree=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_orderno]) {
		self.orderNo=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_imagethumburl]) {
		self.imageThumbUrl=[[NSString alloc] initWithString: aElementValue];

    }

	self.storingCharacters = NO;
	aElementValue = nil;
}

/*
 Sent by a parser object to its delegate when it encounters a fatal error.
 Parameters
 parser: A parser object.
 parseError: An NSError object describing the parsing error that occurred.
 */
- (void)parser:(NSXMLParser *)parser
parseErrorOccurred:(NSError *)parseError {
	NSString *error=[NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", 
					 [parseError code],
					 [[parser parserError] localizedDescription], 
					 [parser lineNumber],
					 [parser columnNumber]];
	
	NSLog(@"%@",error);
}

-(void) print{
	NSLog(@"responseCode: %@",self.responseCode);
	NSLog(@"title: %@",self.title);
	NSLog(@"url: %@",self.url);
	
	for (Article* article in self.articles) {
		NSLog(@"ROW id=%@ lang=%@ title=%@ image=%@ url=%@", article.key, article.lang, article.title, article.imageUrl, article.url);
	}
	
}


@end
