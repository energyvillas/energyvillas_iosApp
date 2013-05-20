//
//  DPBaseDataElement.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

#define encElementKey @"ID"

@interface DPBaseDataElement : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) NSString *key;
@property (readonly, getter = getID) int Id;

-(id)initWithValues:(NSString *)aId;


@end
