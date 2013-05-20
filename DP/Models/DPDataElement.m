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
	[super encodeWithCoder:encoder];
	[encoder encodeObject:self.title forKey:encElementTitle];
	[encoder encodeObject:self.imageUrl forKey:encElementImageUrl];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
	if (self) {
		self.title = [aDecoder decodeObjectForKey:encElementTitle];
		self.imageUrl = [aDecoder decodeObjectForKey:encElementImageUrl];
	}
	return self;
}

- (id) initWithValues:(NSString *)aId
                title:(NSString *)aTitle
             imageUrl:(NSString *)aImageUrl
{
    self = [super initWithValues:aId];
    
	if (self) {
		self.title = NullIfEmpty(aTitle);
		self.imageUrl = NullIfEmpty(aImageUrl);
	}
    
	return self;
}

#pragma mark - NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone {
    DPDataElement *copy = [super copyWithZone:zone];
    copy.title = [self.title copy];
    copy.imageUrl = [self.imageUrl copy];
    return copy;
}
@end
