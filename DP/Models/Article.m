//
//  XMLParser.m
//  RankingServiceTest
//
//  Created by Damia Ferrer on 16/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Article.h"

@implementation Article

//@synthesize title,url,body,image,publishDate,videofile,videolength,imageData;


-(void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];
    
	[encoder encodeObject:self.lang forKey:encArticleLang];
	[encoder encodeObject:self.title forKey:encArticleTitle];
	[encoder encodeObject:self.body forKey:encArticleBody];
	[encoder encodeObject:self.image forKey:encArticleImage];
	[encoder encodeObject:self.url forKey:encArticleURL];
	[encoder encodeObject:self.publishDate forKey:encArticlePublishDate];
	[encoder encodeObject:self.videofile forKey:encArticleVideoFile];
	[encoder encodeObject:self.videolength forKey:encArticleVideoLength];
	[encoder encodeObject:self.imageData forKey:encArticleImageData];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {

		self.lang = [aDecoder decodeObjectForKey:encArticleLang];
		self.title = [aDecoder decodeObjectForKey:encArticleTitle];
		self.body = [aDecoder decodeObjectForKey:encArticleBody];
		self.url = [aDecoder decodeObjectForKey:encArticleURL];
		self.image = [aDecoder decodeObjectForKey:encArticleImage];
		self.publishDate = [aDecoder decodeObjectForKey:encArticlePublishDate];
		self.videofile = [aDecoder decodeObjectForKey:encArticleVideoFile];
		self.videolength = [aDecoder decodeObjectForKey:encArticleVideoLength];
		self.imageData = [aDecoder decodeObjectForKey:encArticleImageData];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                 lang:(NSString *)aLang
              title:(NSString *)aTitle
              image:(NSString *)aImage
               body:(NSString *)aBody
                url:(NSString *)aURL
        publishDate:(NSString *)aPublishDate
          videofile:(NSString *)aVideoFile
        videolength:(NSString *)aVideoLength {
    self = [super init];
    
	if (self) {
		self.key = aId;
        self.lang = aLang;
		self.title = aTitle;
		self.image = aImage;
		self.body = aBody;
		self.publishDate = aPublishDate;
		self.url = aURL;
		self.videofile = aVideoFile;
		self.videolength = aVideoLength;
	}
    
	return self;
}

@end

