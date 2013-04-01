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

//#define encArticleId @"ID"
#define encArticleLang @"Lang"
#define encArticleTitle @"Title"
#define encArticleImage @"Image"
#define encArticleBody @"Body"
#define encArticleURL @"URL"
#define encArticlePublishDate @"PublishDate"
#define encArticleVideoFile @"VideoFile"
#define encArticleVideoLength @"VideoLength"
#define encArticleImageData @"ImageData"


@interface Article: DPDataElement 
    
//@property (nonatomic, strong) NSString *articleId;
@property (strong, nonatomic) NSString *lang;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *publishDate;
@property (nonatomic, strong) NSString *videofile;
@property (nonatomic, strong) NSString *videolength;
@property (nonatomic, strong) NSData *imageData;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)lang
              title:(NSString *)aTitle
              image:(NSString *)aImage
               body:(NSString *)Body
                url:(NSString *)aURL
        publishDate:(NSString *)aPublishDate
          videofile:(NSString *)aVideoFile
        videolength:(NSString *)aVideoLength;
@end


//==============================================================================




