//
//  DPImageInfo.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPImageInfo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;

- (id) initWithName:(NSString *)aName image:(UIImage *)aImage;

@end
