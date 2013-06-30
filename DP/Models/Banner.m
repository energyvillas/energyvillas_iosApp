//
//  Banner.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "Banner.h"
#import "DPConstants.h"

@implementation Banner


-(void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];

    [encoder encodeObject:self.lang forKey:encBannerLang];
    [encoder encodeObject:[NSNumber numberWithInt: self.orderNo] forKey:encBannerOrderNo];

//	[encoder encodeObject:self.title forKey:encBannerTitle];
//	[encoder encodeObject:self.image forKey:encBannerImage];
//	[encoder encodeObject:self.body forKey:encBannerBody];

    [encoder encodeObject:self.imageUrlLandsape forKey:encBannerImageLandscape];
    [encoder encodeObject:self.url forKey:encBannerURL];
//	[encoder encodeObject:self.publishDate forKey:encBannerPublishDate];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
        
        self.lang = [aDecoder decodeObjectForKey:encBannerLang];
        self.orderNo = [[aDecoder decodeObjectForKey:encBannerOrderNo] intValue];
        
//		self.title = [aDecoder decodeObjectForKey:encBannerTitle];
//		self.image = [aDecoder decodeObjectForKey:encBannerImage];
//		self.body = [aDecoder decodeObjectForKey:encBannerBody];

        self.imageUrlLandsape = [aDecoder decodeObjectForKey:encBannerImageLandscape];
        self.url = [aDecoder decodeObjectForKey:encBannerURL];
//		self.publishDate = [aDecoder decodeObjectForKey:encBannerPublishDate];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                 lang:(NSString *)aLang
              orderNo:(int)aOrderNo
                title:(NSString *)aTitle
             imageUrl:(NSString *)aImageUrl
    imageUrlLandscape:(NSString *)aImageUrlLandscape
//                 body:(NSString *)aBody
                  url:(NSString *)aURL
//          publishDate:(NSString *)aPublishDate
{
    self = [super initWithValues:aId title:aTitle imageUrl:aImageUrl];
    
	if (self) {
//		self.key = aId;
//		self.title = NullIfEmpty(aTitle);
//		self.image = NullIfEmpty(aImage);
		self.lang = NilIfEmpty(aLang);
        self.orderNo = aOrderNo;
        self.imageUrlLandsape = NilIfEmpty(aImageUrlLandscape);
//		self.body = NullIfEmpty(aBody);
//		self.publishDate = NullIfEmpty(aPublishDate);
		self.url = NilIfEmpty(aURL);
	}
    
	return self;
}

- (void) dealloc {
    self.lang = nil;
    self.imageUrlLandsape = nil;
    self.url = nil;
}

#pragma mark - NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone {
    Banner *copy = [super copyWithZone:zone];
    copy.lang = [self.lang copy];

//    copy.body = [self.body copy];
    copy.imageUrlLandsape = [self.imageUrlLandsape copy];
//    copy.publishDate = [self.publishDate copy];
    copy.url = [self.url copy];
    
    return copy;
}

@end
