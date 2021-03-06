//
//  DPBaseDataElement.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPBaseDataElement.h"
#import "DPConstants.h"

@implementation DPBaseDataElement

-(void)encodeWithCoder:(NSCoder *)encoder{
	[encoder encodeObject:self.key forKey:encElementKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super init]) {
		self.key = [aDecoder decodeObjectForKey:encElementKey];
	}
	return self;
}

- (id) initWithValues:(NSString *)aId
{
    self = [super init];
    
	if (self) {
        self.key = aId;
	}
    
	return self;
}

-(void)dealloc {
    self.key = nil;
}

-(int) getID {
    if (!self.key)
        return -1;
    
    return self.key.intValue;
}

#pragma mark - NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone {
    DPBaseDataElement *copy = [[[self class] alloc] init];
    copy.key = [self.key copy];
    
    return copy;
}

@end
