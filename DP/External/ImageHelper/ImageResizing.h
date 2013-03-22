//
//  ImageResizing.h
//  NewsIt
//
//  Created by Konstantinos Manos on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define deg2rad (3.1415926/180.0)

@interface UIImage (Resize)
- (UIImage*)scaleToSize:(CGSize)size;

@end
