//
//  XMLParser.m
//  RankingServiceTest
//
//  Created by Damia Ferrer on 16/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Article.h"


@implementation ArticleCache

@synthesize articleList;

-(id)initWithRetrieval{
	if(self = [super init]){
		[self unarchiveArticles];
	}
	return self;
}

-(NSString *)archivePath {
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [docDir stringByAppendingPathComponent:@"articles.dat"];
}

-(void)archiveArticles{
	[NSKeyedArchiver archiveRootObject:articleList toFile:[self archivePath]];
	//RotationAppDelegate* appDelegate = (RotationAppDelegate*)[[UIApplication sharedApplication] delegate];
	//appDelegate.cacheHasChanged = TRUE;
	
}
-(void)unarchiveArticles{
	self.articleList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
	if(self.articleList == nil){
		self.articleList = [[NSMutableArray alloc] init];
	}
}
-(BOOL)articleExists:(NSString *)aArticleId{
	BOOL found = FALSE;
	for (Article* article in articleList) {
		found = found || ([aArticleId compare:article.articleId]==NSOrderedSame);
	}
	return found;
}
-(void)deleteArticle:(NSString *)aArticleId{
	NSUInteger aIndex = -1;
	NSUInteger aCounter = 0;
	for (Article* article in articleList) {
		if ([aArticleId compare:article.articleId]==NSOrderedSame) {
            aIndex=aCounter;
            break;
        }
		aCounter++;
	}
    
	if(aIndex!=-1)
		[articleList removeObjectAtIndex:aIndex];
}
@end


//==============================================================================


@implementation Article

@synthesize articleId,title,url,body,image,publishDate,videofile,videolength,imageData;

- (void)dealloc {
	self.image = nil;
	self.title = nil;
	self.body = nil;
	self.url = nil;
	self.publishDate = nil;
	self.videofile = nil;
	self.videolength = nil;
	self.articleId = nil;
	self.imageData = nil;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
	[encoder encodeObject:self.articleId forKey:encArticleId];
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
	if(self = [super init]) {
		self.articleId = [aDecoder decodeObjectForKey:encArticleId];
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

-(id)initWithValues:(NSString *)aId
              title:(NSString *)aTitle
              image:(NSString *)aImage
               body:(NSString *)aBody
                url:(NSString *)aURL
        publishDate:(NSString *)aPublishDate
          videofile:(NSString *)aVideoFile
        videolength:(NSString *)aVideoLength {
	if(self = [super init]) {
		self.articleId = aId;
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

