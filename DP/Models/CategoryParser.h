//
//  CategoryParser.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryParser : NSObject<NSXMLParserDelegate> {
	int index;
}

@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic)  BOOL storingCharacters;
@property (nonatomic, strong) NSString *ctgId;
@property (nonatomic, strong) NSString *langcode;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *imageRollUrl;
@property (nonatomic, strong) NSString *image2Url;
@property (nonatomic, strong) NSString *image2RollUrl;
@property (nonatomic, strong) NSString *parent;
@property (nonatomic, strong) NSString *hikind;

- (void)parseXMLFile:(NSString *)pathToFile;
- (void)print;

@end
