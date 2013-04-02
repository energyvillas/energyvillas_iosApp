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
    
	[encoder encodeObject:self.title forKey:encBannerTitle];
	[encoder encodeObject:self.body forKey:encBannerBody];
	[encoder encodeObject:self.image forKey:encBannerImage];
	[encoder encodeObject:self.url forKey:encBannerURL];
	[encoder encodeObject:self.publishDate forKey:encBannerPublishDate];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
        
		self.title = [aDecoder decodeObjectForKey:encBannerTitle];
		self.body = [aDecoder decodeObjectForKey:encBannerBody];
		self.url = [aDecoder decodeObjectForKey:encBannerURL];
		self.image = [aDecoder decodeObjectForKey:encBannerImage];
		self.publishDate = [aDecoder decodeObjectForKey:encBannerPublishDate];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                title:(NSString *)aTitle
                image:(NSString *)aImage
                 body:(NSString *)aBody
                  url:(NSString *)aURL
          publishDate:(NSString *)aPublishDate
{
    self = [super init];
    
	if (self) {
		self.key = aId;
		self.title = NullIfEmpty(aTitle);
		self.image = NullIfEmpty(aImage);
		self.body = NullIfEmpty(aBody);
		self.publishDate = NullIfEmpty(aPublishDate);
		self.url = NullIfEmpty(aURL);
	}
    
	return self;
}

@end
