//
//  HouseOverviewParser.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "HouseOverviewParser.h"
#import "HouseOverview.h"

@implementation HouseOverviewParser

- (void) dealloc {
    self.currentString = nil;
    self.responseCode = nil;
    self.datalist = nil;
    
    self.hovId = nil;
    self.langcode = nil;
    self.categoryId = nil;
    self.isMaster = nil;
    
    self.videourl = nil;
    self.title = nil;
    self.info = nil;
    self.descr/*iption*/ = nil;
}

/*
 to parse a XML file from path.
 */
- (void)parseXMLFile:(NSString *)data {
	//array for the ranking
	self.datalist = [[NSMutableArray alloc] init];
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
static NSString *kName_elements = @"houseoverviews";
static NSString *kName_element = @"houseoverview";

static NSString *kName_id = @"hovid";
static NSString *kName_categoryid = @"categoryid";
static NSString *kName_langcode = @"langcode";
static NSString *kName_ismaster = @"ismaster";

static NSString *kName_videourl = @"videourl";
static NSString *kName_title = @"title";
static NSString *kName_info = @"info";
static NSString *kName_descr = @"description";
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
	}else if ([elementName isEqualToString:kName_elements]) {
		
	}else if ([elementName isEqualToString:kName_element]) {
		

    }else if ([elementName isEqualToString:kName_id]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_categoryid]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_langcode]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		      
    }else if ([elementName isEqualToString:kName_ismaster]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
        
    }else if ([elementName isEqualToString:kName_videourl]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
        
    }else if ([elementName isEqualToString:kName_title]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
        
	}else if ([elementName isEqualToString:kName_info]) {
		[self.currentString setString:@""];
		self.storingCharacters = YES;
		
	}else if ([elementName isEqualToString:kName_descr]) {
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

-(NSString *) processHtmlField:(NSString *)data {
    if (data) {
        if (data.length == 0)
            data = nil;
        else
            data = [[data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
                        stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    }
    
    return data;
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

	NSLog(@"===>>>>>>>>>>>>>>>>>>-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
	NSLog(@"%@",self.currentString);
	
	NSString *aElementValue = [[NSString alloc] initWithString:
                               [[self.currentString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"'"]
                                stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"]];
    
	if ([elementName isEqualToString:kName_response]) {
		
	}else if ([elementName isEqualToString:kName_responseCode]) {
		self.responseCode=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_elements]) {
		
	}else if ([elementName isEqualToString:kName_element]) {
		HouseOverview *element  = [[HouseOverview alloc] initWithValues:self.hovId
                                                                   lang:self.langcode
                                                               category:[self.categoryId intValue]
                                                               isMaster:[self.isMaster boolValue]
                                                               videoUrl:self.videourl
                                                                  title:[self processHtmlField:self.title]
                                                                   info:[self processHtmlField:self.info]
                                                            description:[self processHtmlField:self.descr]];
//		element.key=self.hovId;
//        element.lang=self.langcode;
//        element.ctgid = [self.categoryId intValue];
//        element.isMaster = [self.isMaster boolValue];
//		element.title = [self processHtmlField:self.title];
//		element.info = [self processHtmlField:self.info];
//		element.description = [self processHtmlField:self.description];
        
		[self.datalist insertObject:element atIndex:index];
		index=index+1;
		element=nil;
        
	}else if ([elementName isEqualToString:kName_id]) {
		self.hovId=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_categoryid]) {
		self.categoryId=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_langcode]) {
		self.langcode=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_ismaster]) {
		self.isMaster=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_videourl]) {
		self.videourl=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_title]) {
		self.title=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_info]) {
		self.info=[[NSString alloc] initWithString: aElementValue];
        
	}else if ([elementName isEqualToString:kName_descr]) {
		self.descr=[[NSString alloc] initWithString: aElementValue];
        
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
	
	for (HouseOverview* elm in self.datalist) {
		NSLog(@"ROW id=%@ lang=%@ ctgid=%d isMaster=%c", elm.key, elm.lang, elm.ctgid, elm.isMaster);
	}
	
}


@end
