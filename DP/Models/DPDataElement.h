//
//  DPDataElement.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

#define encElementKey @"ID"

@interface DPDataElement : NSObject <NSCoding>

@property (strong, nonatomic) NSString *key;
@property (readonly, getter = getID) int Id;

@end
