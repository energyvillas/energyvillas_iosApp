//
//  Banner.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataElement.h"

//#define encBannerTitle @"Title"
//#define encBannerImage @"Image"
//#define encBannerBody @"Body"
#define encBannerURL @"URL"
#define encBannerPublishDate @"PublishDate"

#define encBannerLang @"Lang"
#define encBannerOrderNo @"OrderNo"
#define encBannerImageLandscape @"ImageLandScape"


@interface Banner : DPDataElement

//@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *lang;
@property (nonatomic) int orderNo;
//@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *imageUrlLandsape;
@property (nonatomic, strong) NSString *url;
//@property (nonatomic, strong) NSString *publishDate;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
            orderNo:(int)aOrderNo
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
  imageUrlLandscape:(NSString *)aImageUrlLandscape
//               body:(NSString *)Body
                url:(NSString *)aURL
//        publishDate:(NSString *)aPublishDate
;

@end
