//
//  UIImage+Retina4.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/11/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UIImage+Retina4.h"
#import <objc/objc-runtime.h>

static Method origImageNamedMethod = nil;

@implementation UIImage (Retina4)

+ (void)initialize {
    if (origImageNamedMethod == nil) {
        origImageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));
        method_exchangeImplementations(origImageNamedMethod,
                                       class_getClassMethod(self, @selector(retina4ImageNamed:)));
    }
}

+ (UIImage *)retina4ImageNamed:(NSString *)imageName {
    NSLog(@"Loading image named => %@", imageName);
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
            NSRange dot = [imageName rangeOfString:@"."];
            if (dot.location != NSNotFound) {
                [imageNameMutable insertString:@"-568h@2x" atIndex:dot.location];
            } else {
                [imageNameMutable appendString:@"-568h@2x"];
            }
        }
    }
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@""];
    if (imagePath) {
        return [UIImage retina4ImageNamed:imageNameMutable];
    } else {
        return [UIImage retina4ImageNamed:imageName];
    }
    return nil;
}

@end
