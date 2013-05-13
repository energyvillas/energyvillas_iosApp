//
//  XMLParser.h
//  RankingServiceTest
//
//  Created by Damia Ferrer on 16/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataElement.h"

#define encArticleOrder @"orderno"
#define encArticleForFree @"forfree"
#define encArticleImageThumb @"imagethumb"

#define encArticleLang @"Lang"
#define encArticleCategory @"Category"
#define encArticleBody @"Body"
#define encArticleURL @"URL"
#define encArticlePublishDate @"PublishDate"
#define encArticleVideoFile @"VideoFile"
#define encArticleVideoLength @"VideoLength"


@interface Article: DPDataElement 
    
@property (strong, nonatomic) NSString *lang;
@property (nonatomic) int category;

@property (nonatomic) int orderNo;
@property (nonatomic) BOOL forFree;
@property (nonatomic, strong) NSString *imageThumbUrl;

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *publishDate;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videolength;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *imageThumb;


-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
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
        videolength:(NSString *)aVideoLength;
@end
