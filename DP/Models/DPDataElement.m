//
//  DPDataElement.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataElement.h"
#import "DPConstants.h"


@implementation DPDataElement

-(void)encodeWithCoder:(NSCoder *)encoder{
	[encoder encodeObject:self.key forKey:encElementKey];
	[encoder encodeObject:self.title forKey:encElementTitle];
	[encoder encodeObject:self.imageUrl forKey:encElementImageUrl];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super init]) {
		self.key = [aDecoder decodeObjectForKey:encElementKey];
		self.title = [aDecoder decodeObjectForKey:encElementTitle];
		self.imageUrl = [aDecoder decodeObjectForKey:encElementImageUrl];
	}
	return self;
}

- (id) initWithValues:(NSString *)aId
                title:(NSString *)aTitle
             imageUrl:(NSString *)aImageUrl
{
    self = [super init];
    
	if (self) {
        self.key = aId;
		self.title = NullIfEmpty(aTitle);
		self.imageUrl = NullIfEmpty(aImageUrl);
	}
    
	return self;
}


-(int) getID {
    if (!self.key)
        return -1;
    
    return self.key.intValue;
}

@end
