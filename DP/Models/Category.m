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
//	[encoder encodeObject:self.title forKey:encCategoryTitle];
//	[encoder encodeObject:self.imageUrl forKey:encCategoryImageUrl];
	[encoder encodeObject:self.parent forKey:encCategoryParent];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
        
		self.lang = [aDecoder decodeObjectForKey:encCategoryLang];
//		self.title = [aDecoder decodeObjectForKey:encCategoryTitle];
//		self.imageUrl = [aDecoder decodeObjectForKey:encCategoryImageUrl];
		self.parent = [aDecoder decodeObjectForKey:encCategoryParent];
	}
    
	return self;
}

- (id) initWithValues:(NSString *)aId
                 lang:(NSString *)aLang
                title:(NSString *)aTitle
             imageUrl:(NSString *)aImageUrl
                parent:(NSString *)aParent
{
    self = [super initWithValues:aId title:aTitle imageUrl:aImageUrl];
    
	if (self) {
//		self.key = aId;
        self.lang = aLang;
//		self.title = NullIfEmpty(aTitle);
//		self.imageUrl = NullIfEmpty(aImageUrl);
		self.parent = NullIfEmpty(aParent);
	}
    
	return self;
}
@end
