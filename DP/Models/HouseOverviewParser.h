//
//  HouseOverviewParser.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HouseOverviewParser : NSObject <NSXMLParserDelegate> {
	int index;
}

@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, strong) NSMutableArray *datalist;
@property (nonatomic)  BOOL storingCharacters;

@property (nonatomic, strong) NSString *hovId;
@property (nonatomic, strong) NSString *langcode;
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, strong) NSString *isMaster;

@property (nonatomic, strong) NSString *videourl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *description;

- (void)parseXMLFile:(NSString *)pathToFile;
- (void)print;

@end
