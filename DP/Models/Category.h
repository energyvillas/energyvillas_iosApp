//
//  Category.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataElement.h"
#import "DPDataCache.h"

#define encCategoryLang @"Lang"
#define encCategoryTitle @"Title"
#define encCategoryParent @"Parent"


@interface Category : DPDataElement

@property (strong, nonatomic) NSString *lang;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *parent;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
             parent:(NSString *)aParent;


@end