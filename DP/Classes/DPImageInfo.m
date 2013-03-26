//
//  DPImageInfo.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPImageInfo.h"

@implementation DPImageInfo

@synthesize name, image, tag;

- (id) initWithName:(NSString *)aName image:(UIImage *)aImage {
    if(self = [super init]){
		self.name = aName;
		self.image = aImage;
	}
	return self;
}

@end
