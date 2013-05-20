//
//  HouseOverview.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "HouseOverview.h"
#import "DPConstants.h"

@implementation HouseOverview


-(void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];
    
	[encoder encodeObject:self.lang forKey:encHOVLang];
	[encoder encodeObject:[NSNumber numberWithInt:self.ctgid] forKey:encHOVCategoryId];
	[encoder encodeObject:[NSNumber numberWithBool:self.isMaster] forKey:encHOVIsMaster];
	[encoder encodeObject:self.title forKey:encHOVTitle];
	[encoder encodeObject:self.info forKey:encHOVInfo];
	[encoder encodeObject:self.description forKey:encHOVDescription];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
	if (self) {
		self.lang = [aDecoder decodeObjectForKey:encHOVLang];
		self.ctgid = [[aDecoder decodeObjectForKey:encHOVCategoryId] intValue];
		self.isMaster = [[aDecoder decodeObjectForKey:encHOVIsMaster] boolValue];
		self.title = [aDecoder decodeObjectForKey:encHOVTitle];
		self.info = [aDecoder decodeObjectForKey:encHOVInfo];
		self.description = [aDecoder decodeObjectForKey:encHOVDescription];
    }
    
	return self;
}

-(id)initWithValues:(NSString *)aId
               lang:(NSString *)aLang
           category:(int)cid
           isMaster:(BOOL)aIsMaster
              title:(NSString *)aTitle
               info:(NSString *)aInfo
        description:(NSString *)aDescr
{
    self = [super initWithValues:aId];
    
	if (self) {
		self.lang = NullIfEmpty(aLang);
		self.ctgid = cid;
		self.isMaster = aIsMaster;
		self.title = NullIfEmpty(aTitle);
		self.info = NullIfEmpty(aInfo);
		self.description = NullIfEmpty(aDescr);
	}
    
	return self;
}

#pragma mark - NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone {
    HouseOverview *copy = [super copyWithZone:zone];
    copy.lang = [self.lang copy];
    copy.ctgid = self.ctgid;
    copy.isMaster = self.isMaster;
    copy.title = [self.title copy];
    copy.info = [self.info copy];
    copy.description = [self.description copy];
    
    return copy;
}


@end
