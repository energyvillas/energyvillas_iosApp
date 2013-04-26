//
//  DPDataElement.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPBaseDataElement.h"

#define encElementTitle @"Title"
#define encElementImageUrl @"Image"


@interface DPDataElement : DPBaseDataElement

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageUrl;

//@property (nonatomic, strong) UIImage *imageData;


-(id)initWithValues:(NSString *)aId
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl;

@end
