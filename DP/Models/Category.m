//
//  Category.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "Category.h"
#import "DPConstants.h"

@implementation Category

- (int) getParentID {
   if (!self.parent)
       return -1;
    
    return self.parent.intValue;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];
    
	[encoder encodeObject:self.lang forKey:encCategoryLang];
	[encoder encodeObject:self.parent forKey:encCategoryParent];
    [encoder encodeObject:self.imageRollUrl forKey:encCategoryImageRollUrl];
    [encoder encodeObject:self.image2Url forKey:encCategoryImage2Url];
    [encoder encodeObject:self.image2RollUrl forKey:encCategoryImage2RollUrl];
	[encoder encodeObject:[NSNumber numberWithInt: self.hikId] forKey:encCategoryHouseInfoKind];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
		self.lang = [aDecoder decodeObjectForKey:encCategoryLang];
		self.parent = [aDecoder decodeObjectForKey:encCategoryParent];
        self.imageRollUrl = [aDecoder decodeObjectForKey:encCategoryImageRollUrl];
        self.image2Url = [aDecoder decodeObjectForKey:encCategoryImage2Url];
        self.image2RollUrl = [aDecoder decodeObjectForKey:encCategoryImage2RollUrl];
        self.hikId = [[aDecoder decodeObjectForKey:encCategoryHouseInfoKind] intValue];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                 lang:(NSString *)aLang
                title:(NSString *)aTitle
             imageUrl:(NSString *)aImageUrl
         imageRollUrl:(NSString *)aImageRollUrl
            image2Url:(NSString *)aImage2Url
        image2RollUrl:(NSString *)aImage2RollUrl
               parent:(NSString *)aParent
{
    self = [super initWithValues:aId title:aTitle imageUrl:aImageUrl];
    
	if (self) {
//		self.key = aId;
        self.lang = aLang;
//		self.title = NullIfEmpty(aTitle);
//		self.imageUrl = NullIfEmpty(aImageUrl);
		self.parent = NilIfEmpty(aParent);
        self.imageRollUrl = NilIfEmpty(aImageRollUrl);
        self.image2Url = NilIfEmpty(aImage2Url);
        self.image2RollUrl = NilIfEmpty(aImage2RollUrl);
        self.hikId = HIKID_UNDEFINED;
	}
    
	return self;
}

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
       imageRollUrl:(NSString *)aImageRollUrl
          image2Url:(NSString *)aImage2Url
      image2RollUrl:(NSString *)aImage2RollUrl
             parent:(NSString *)aParent
                hik:(int)ahikid {
    self = [self initWithValues:aId lang:aLang
                          title:aTitle
                       imageUrl:aImageUrl
                   imageRollUrl:aImageRollUrl
                      image2Url:aImage2Url
                  image2RollUrl:aImage2RollUrl
                         parent:aParent];
    if (self) {
        self.hikId = ahikid;
    }
    
    return self;
}

- (void) dealloc {
    self.lang = nil;
    self.parent = nil;
    self.imageRollUrl = nil;
}

#pragma mark - NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone {
    Category *copy = [super copyWithZone:zone];
    copy.lang = [self.lang copy];
    copy.parent = [self.parent copy];
    copy.imageRollUrl = [self.imageRollUrl copy];
    copy.image2Url = [self.image2Url copy];
    copy.image2RollUrl = [self.image2RollUrl copy];
    copy.hikId = self.hikId;
    
    return copy;
}

@end
