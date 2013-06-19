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
	[encoder encodeObject:[NSNumber numberWithInt: self.hikId] forKey:encCategoryHouseInfoKind];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
		self.lang = [aDecoder decodeObjectForKey:encCategoryLang];
		self.parent = [aDecoder decodeObjectForKey:encCategoryParent];
        self.imageRollUrl = [aDecoder decodeObjectForKey:encCategoryImageRollUrl];
        self.hikId = [[aDecoder decodeObjectForKey:encCategoryHouseInfoKind] intValue];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                 lang:(NSString *)aLang
                title:(NSString *)aTitle
             imageUrl:(NSString *)aImageUrl
         imageRollUrl:(NSString *)aImageRollUrl
               parent:(NSString *)aParent
{
    self = [super initWithValues:aId title:aTitle imageUrl:aImageUrl];
    
	if (self) {
//		self.key = aId;
        self.lang = aLang;
//		self.title = NullIfEmpty(aTitle);
//		self.imageUrl = NullIfEmpty(aImageUrl);
		self.parent = NullIfEmpty(aParent);
        self.imageRollUrl = NullIfEmpty(aImageRollUrl);
        self.hikId = HIKID_UNDEFINED;
	}
    
	return self;
}

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
              title:(NSString *)aTitle
           imageUrl:(NSString *)aImageUrl
       imageRollUrl:(NSString *)aImageRollUrl
             parent:(NSString *)aParent
                hik:(int)ahikid {
    self = [self initWithValues:aId lang:aLang title:aTitle imageUrl:aImageUrl imageRollUrl:aImageRollUrl parent:aParent];
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
    copy.hikId = self.hikId;
    
    return copy;
}

@end
