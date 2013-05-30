//
//  HouseOverview.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPBaseDataElement.h"

#define encHOVLang @"Lang"
#define encHOVCategoryId @"CtgId"
#define encHOVIsMaster @"IsMaster"
#define encHOVVideoUrl @"VideoUrl"
#define encHOVTitle @"Title"
#define encHOVInfo @"Info"
#define encHOVDescription @"Description"


@interface HouseOverview : DPBaseDataElement

@property (nonatomic, strong) NSString *lang;
@property (nonatomic) int ctgid;
@property (nonatomic) BOOL isMaster;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *description;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
           category:(int)cid
           isMaster:(BOOL)aIsMaster
           videoUrl:(NSString *)aVideoUrl
              title:(NSString *)aTitle
               info:(NSString *)aInfo
        description:(NSString *)aDescr;

@end
