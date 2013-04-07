//
//  Category.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataElement.h"

#define encCategoryLang @"Lang"
//#define encCategoryTitle @"Title"
//#define encCategoryImageUrl @"Image"
#define encCategoryParent @"Parent"


@interface Category : DPDataElement

@property (strong, nonatomic) NSString *lang;
//@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSDictionary *titles;
@property (nonatomic, strong) NSDictionary *imageUrls;
@property (nonatomic, strong) NSString *parent;
@property (readonly, getter = getParentID) int parentId;
@property (strong, nonatomic) NSMutableArray *children;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
             parent:(NSString *)aParent;


@end