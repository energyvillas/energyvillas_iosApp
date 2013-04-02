//
//  BannerParser.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BannerParser : NSObject <NSXMLParserDelegate> {
	int index;
}

@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, strong) NSMutableArray *banners;
@property (nonatomic)  BOOL storingCharacters;
@property (nonatomic, strong) NSString *bannerId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *publishDate;

- (void)parseXMLFile:(NSString *)pathToFile;
- (void)print;

@end
