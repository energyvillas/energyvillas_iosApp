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
#define encCategoryImage2Url @"Image2"
#define encCategoryImage2RollUrl @"Image2Roll"
#define encCategoryParent @"Parent"
#define encCategoryHouseInfoKind @"HIKKind"

@interface Category : DPDataElement

@property (strong, nonatomic) NSString *lang;
@property (nonatomic, strong) NSString *parent;
@property (readonly, getter = getParentID) int parentId;
@property (nonatomic, strong) NSString *imageRollUrl;
@property (nonatomic, strong) NSString *image2Url;
@property (nonatomic, strong) NSString *image2RollUrl;
@property int hikId;

-(void)encodeWithCoder:(NSCoder *)encoder;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
       imageRollUrl:(NSString *)aImageRollUrl
          image2Url:(NSString *)aImage2Url
      image2RollUrl:(NSString *)aImage2RollUrl
             parent:(NSString *)aParent;

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
       imageRollUrl:(NSString *)aImageRollUrl
          image2Url:(NSString *)aImage2Url
      image2RollUrl:(NSString *)aImage2RollUrl
             parent:(NSString *)aParent
                hik:(int)ahikid;


@end