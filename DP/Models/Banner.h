//
//  Banner.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataElement.h"
#import "DPDataCache.h"

#define encBannerTitle @"Title"
#define encBannerImage @"Image"
#define encBannerBody @"Body"
#define encBannerURL @"URL"
#define encBannerPublishDate @"PublishDate"


@interface Banner : DPDataElement

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *publishDate;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
              title:(NSString *)aTitle
              image:(NSString *)aImage
               body:(NSString *)Body
                url:(NSString *)aURL
        publishDate:(NSString *)aPublishDate;

@end
