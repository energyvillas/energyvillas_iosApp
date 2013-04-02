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
	[encoder encodeObject:self.category forKey:encArticleCategory];
	[encoder encodeObject:self.title forKey:encArticleTitle];
	[encoder encodeObject:self.body forKey:encArticleBody];
	[encoder encodeObject:self.imageUrl forKey:encArticleImage];
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
		self.category = [aDecoder decodeObjectForKey:encArticleCategory];
		self.title = [aDecoder decodeObjectForKey:encArticleTitle];
		self.body = [aDecoder decodeObjectForKey:encArticleBody];
		self.url = [aDecoder decodeObjectForKey:encArticleURL];
		self.imageUrl = [aDecoder decodeObjectForKey:encArticleImage];
		self.publishDate = [aDecoder decodeObjectForKey:encArticlePublishDate];
		self.videoUrl = [aDecoder decodeObjectForKey:encArticleVideoFile];
		self.videolength = [aDecoder decodeObjectForKey:encArticleVideoLength];
//		self.imageData = [aDecoder decodeObjectForKey:encArticleImageData];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                 lang:(NSString *)aLang
             category:(NSString*)aCategory
              title:(NSString *)aTitle
              imageUrl:(NSString *)aImage
               body:(NSString *)aBody
                url:(NSString *)aURL
        publishDate:(NSString *)aPublishDate
          videoUrl:(NSString *)aVideoFile
        videolength:(NSString *)aVideoLength {
    self = [super init];
    
	if (self) {
		self.key = aId;
        self.lang = aLang;
        self.category = NullIfEmpty(aCategory);
        self.title = NullIfEmpty(aTitle);
		self.imageUrl = NullIfEmpty(aImage);
		self.body = NullIfEmpty(aBody);
		self.publishDate = NullIfEmpty(aPublishDate);
		self.url = NullIfEmpty(aURL);
		self.videoUrl = NullIfEmpty(aVideoFile);
		self.videolength = NullIfEmpty(aVideoLength);
	}
    
	return self;
}

@end

