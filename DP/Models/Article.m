//
//  XMLParser.m
//  RankingServiceTest
//
//  Created by Damia Ferrer on 16/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Article.h"
#import "DPConstants.h"

@implementation Article

//@synthesize title,url,body,image,publishDate,videofile,videolength,imageData;


-(void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];
    
	[encoder encodeObject:self.lang forKey:encArticleLang];
	[encoder encodeObject:[NSNumber numberWithInt:self.category] forKey:encArticleCategory];
    
	[encoder encodeObject:[NSNumber numberWithBool:self.forFree] forKey:encArticleForFree];
	[encoder encodeObject:[NSNumber numberWithInt:self.orderNo] forKey:encArticleOrder];
	[encoder encodeObject:self.imageThumbUrl forKey:encArticleImageThumb];

	[encoder encodeObject:self.body forKey:encArticleBody];
	[encoder encodeObject:self.url forKey:encArticleURL];
	[encoder encodeObject:self.publishDate forKey:encArticlePublishDate];
	[encoder encodeObject:self.videoUrl forKey:encArticleVideoFile];
	[encoder encodeObject:self.videolength forKey:encArticleVideoLength];
//	[encoder encodeObject:self.imageData forKey:encArticleImageData];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {

		self.lang = [aDecoder decodeObjectForKey:encArticleLang];
		self.category = [[aDecoder decodeObjectForKey:encArticleCategory] intValue];

        self.forFree = [[aDecoder decodeObjectForKey:encArticleForFree] boolValue];
        self.orderNo = [[aDecoder decodeObjectForKey:encArticleOrder] intValue];
		self.imageThumbUrl = NullIfEmpty([aDecoder decodeObjectForKey:encArticleImageThumb]);

		self.body = NullIfEmpty([aDecoder decodeObjectForKey:encArticleBody]);
		self.url = NullIfEmpty([aDecoder decodeObjectForKey:encArticleURL]);
		self.publishDate = NullIfEmpty([aDecoder decodeObjectForKey:encArticlePublishDate]);
		self.videoUrl = NullIfEmpty([aDecoder decodeObjectForKey:encArticleVideoFile]);
		self.videolength = [aDecoder decodeObjectForKey:encArticleVideoLength];
//		self.imageData = [aDecoder decodeObjectForKey:encArticleImageData];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                 lang:(NSString *)aLang
             category:(int)aCategory
              orderNo:(int)aOrderNo
              forFree:(BOOL)aForFree
                title:(NSString *)aTitle
             imageUrl:(NSString *)aImageUrl
        imageThumbUrl:(NSString *)aImageThumbUrl
                 body:(NSString *)aBody
                  url:(NSString *)aURL
          publishDate:(NSString *)aPublishDate
             videoUrl:(NSString *)aVideoFile
          videolength:(NSString *)aVideoLength
{
    self = [super initWithValues:aId title:aTitle imageUrl:aImageUrl];
    
	if (self) {
//		self.key = aId;
        self.lang = aLang;
        self.category = aCategory;
        
        self.orderNo = aOrderNo;
        self.forFree = aForFree;
        self.imageThumbUrl = NullIfEmpty(aImageThumbUrl);
        
		self.body = NullIfEmpty(aBody);
		self.publishDate = NullIfEmpty(aPublishDate);
		self.url = NullIfEmpty(aURL);
		self.videoUrl = NullIfEmpty(aVideoFile);
		self.videolength = NullIfEmpty(aVideoLength);
	}
    
	return self;
}

@end

