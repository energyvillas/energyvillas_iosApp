//
//  DPDataElement.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataElement.h"

@implementation DPDataElement

-(void)encodeWithCoder:(NSCoder *)encoder{
	[encoder encodeObject:self.key forKey:encElementKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super init]) {
		self.key = [aDecoder decodeObjectForKey:encElementKey];
	}
	return self;
}

-(int) getID {
    if (!self.key)
        return -1;
    
    return self.key.intValue;
}

@end
