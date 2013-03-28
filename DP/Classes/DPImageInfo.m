//
//  DPImageInfo.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPImageInfo.h"

@implementation DPImageInfo

@synthesize name, image, tag, displayNname;

- (id) initWithName:(NSString *)aName image:(UIImage *)aImage {
    if(self = [super init]) {
        [self doInitWithName:aName image:aImage];
	}
	return self;
}

- (id) initWithName:(NSString *)aName image:(UIImage *)aImage displayName:(NSString *)aDisplayName {
    if (self = [super init]) {
        [self doInitWithName:aName image:aImage displayName:aDisplayName];
    }
    return self;
}

- (void) doInitWithName:(NSString *)aName image:(UIImage *)aImage {
    self.name = aName;
    self.image = aImage;    
}

- (void) doInitWithName:(NSString *)aName image:(UIImage *)aImage displayName:(NSString *)aDisplayName {
    [self doInitWithName:aName image:aImage];
    self.displayNname = aDisplayName;
}

@end
