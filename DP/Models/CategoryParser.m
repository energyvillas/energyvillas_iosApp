//
//  CategoryParser.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "CategoryParser.h"
#import "Category.h"

@implementation CategoryParser

/*
 to parse a XML file from path.
 */
- (void)parseXMLFile:(NSString *)data {
	//array for the ranking
	self.categories = [[NSMutableArray alloc] init];
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
static NSString *kName_categories = @"categories";
static NSString *kName_category = @"category";
static NSString *kName_categoryid = @"id";
static NSString *kName_langcode = @"langcode";
static NSString *kName_title = @"description";
static NSString *kName_imageUrl = @"image";
static NSString *kName_imageRollUrl = @"imageroll";
static NSString *kName_parent = @"parentid";
static NSString *kName_kind = @"kind";

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
	}else if ([elementName isEqualToString:kName_categories]) {
		
	}else if ([elementName isEqualToString:kName_category]) {
		
	}else if ([elementName isEqualToString:kName_categoryid]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_langcode]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_title]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_imageUrl]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_imageRollUrl]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_parent]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
        
	}else if ([elementName isEqualToString:kName_kind]) {
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
	}else if ([elementName isEqualToString:kName_categories]) {
		
	}else if ([elementName isEqualToString:kName_category]) {
		Category *category  = [[Category alloc] init];
		category.key = self.ctgId;
        category.lang = self.langcode;
		category.title = self.title;
		category.imageUrl = self.imageUrl;
		category.imageRollUrl = self.imageRollUrl;
		category.parent = self.parent;
        category.hikId = [self.hikind intValue];
		[self.categories insertObject:category atIndex:index];
		index=index+1;
		category=nil;
	
	}else if ([elementName isEqualToString:kName_categoryid]) {
		self.ctgId=[[NSString alloc] initWithString: aElementValue];
        
    }else if ([elementName isEqualToString:kName_langcode]) {
		self.langcode=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_title]) {
		self.title=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_imageUrl]) {
		self.imageUrl=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_imageRollUrl]) {
		self.imageRollUrl=[[NSString alloc] initWithString: aElementValue];
        
    }else if ([elementName isEqualToString:kName_parent]) {
		self.parent=[[NSString alloc] initWithString: aElementValue];
        
    }else if ([elementName isEqualToString:kName_kind]) {
		self.hikind=[[NSString alloc] initWithString: aElementValue];
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
	NSLog(@"lang: %@  title: %@  parent: %@", self.langcode, self.title, self.parent);
	
	for (Category* ctg in self.categories) {
		NSLog(@"ROW id=%@  lang=%@  title=%@  parent=%@", ctg.key, ctg.lang, ctg.title, ctg.parent);
	}
}

@end
