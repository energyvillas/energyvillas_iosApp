//
//  XMLParser.h
//  RankingServiceTest
//
//  Created by Damia Ferrer on 16/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataElement.h"
#import "DPDataCache.h"

#define encArticleLang @"Lang"
#define encArticleCategory @"Category"
#define encArticleTitle @"Title"
#define encArticleImage @"Image"
#define encArticleBody @"Body"
#define encArticleURL @"URL"
#define encArticlePublishDate @"PublishDate"
#define encArticleVideoFile @"VideoFile"
#define encArticleVideoLength @"VideoLength"
//#define encArticleImageData @"ImageData"


@interface Article: DPDataElement 
    
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *category;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *publishDate;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videolength;
//@property (nonatomic, strong) NSData *imageData;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aCang
           category:(NSString*)aCategory
              title:(NSString *)aTitle
              imageUrl:(NSString *)aImageUrl
               body:(NSString *)aBody
                url:(NSString *)aURL
        publishDate:(NSString *)aPublishDate
          videoUrl:(NSString *)aVideoFile
        videolength:(NSString *)aVideoLength;
@end
