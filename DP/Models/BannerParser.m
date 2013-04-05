//
//  BannerParser.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "BannerParser.h"
#import "Banner.h"

@implementation BannerParser


/*
 to parse a XML file from path.
 */
- (void)parseXMLFile:(NSString *)data {
	//array for the ranking
	self.banners = [[NSMutableArray alloc] init];
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
static NSString *kName_banners = @"articles";
static NSString *kName_banner = @"article";
static NSString *kName_bannerid = @"articleid";
static NSString *kName_title = @"title";
static NSString *kName_url = @"url";
static NSString *kName_image = @"image";
static NSString *kName_body = @"body";
static NSString *kName_publishDate = @"publishDate";

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
	}else if ([elementName isEqualToString:kName_banners]) {
		
	}else if ([elementName isEqualToString:kName_banner]) {
		
	}else if ([elementName isEqualToString:kName_title]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_url]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_bannerid]) {
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
	}else if ([elementName isEqualToString:kName_banners]) {
		
	}else if ([elementName isEqualToString:kName_banner]) {
		Banner *banner  = [[Banner alloc] init];
		banner.key=self.bannerId;
		banner.title = self.title;
		banner.body = self.body;
		banner.imageUrl = self.image;
		banner.url = self.url;
		banner.publishDate = self.publishDate;
		[self.banners insertObject:banner atIndex:index];
		index=index+1;
		banner=nil;
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
	}else if ([elementName isEqualToString:kName_bannerid]) {
		self.bannerId=[[NSString alloc] initWithString: aElementValue];
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
	
	for (Banner* banner in self.banners) {
		NSLog(@"ROW id=%@ title=%@ image=%@ url=%@", banner.key, banner.title, banner.imageUrl, banner.url);
	}
	
}

@end
