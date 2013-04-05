//
//  DPDataElement.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

#define encElementKey @"ID"
#define encElementTitle @"Title"
#define encElementImageUrl @"Image"


@interface DPDataElement : NSObject <NSCoding>

@property (strong, nonatomic) NSString *key;
@property (readonly, getter = getID) int Id;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageUrl;

//@property (nonatomic, strong) UIImage *imageData;


-(id)initWithValues:(NSString *)aId
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl;

@end
