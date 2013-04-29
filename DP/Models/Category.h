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
#define encCategoryImageRollUrl @"ImageRoll"
#define encCategoryParent @"Parent"
#define encCategoryHouseInfoKind @"HIKKind"

@interface Category : DPDataElement

@property (strong, nonatomic) NSString *lang;
@property (nonatomic, strong) NSString *parent;
@property (readonly, getter = getParentID) int parentId;
@property (nonatomic, strong) NSString *imageRollUrl;
@property int hikId;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
       imageRollUrl:(NSString *)aImageRollUrl
             parent:(NSString *)aParent;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
       imageRollUrl:(NSString *)aImageRollUrl
             parent:(NSString *)aParent
                hik:(int)ahikid;


@end