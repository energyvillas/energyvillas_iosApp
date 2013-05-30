//
//  UIImage+Retina4.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/11/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UIImage+Retina4.h"
//#import <objc/objc-runtime.h> // this works on simulator but NOT on device...
#import <objc/runtime.h> // this works on both the simulator and the device

//static Method origImageNamedMethod = nil;

@implementation UIImage (Retina4)

//+ (void)initialize {
//    if (origImageNamedMethod == nil) {
//        origImageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));
//        method_exchangeImplementations(origImageNamedMethod,
//                                       class_getClassMethod(self, @selector(retina4ImageNamed:)));
//    }
//}
//
//+ (UIImage *)retina4ImageNamed:(NSString *)imageName {
//    NSLog(@"Loading image named => %@", imageName);
//    NSMutableString *imageNameMutable = [imageName mutableCopy];
//    NSRange retinaAtSymbol = [imageName rangeOfString:@"@"];
//    if (retinaAtSymbol.location != NSNotFound) {
//        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
//    } else {
//        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//        if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
//            NSRange dot = [imageName rangeOfString:@"."];
//            if (dot.location != NSNotFound) {
//                [imageNameMutable insertString:@"-568h@2x" atIndex:dot.location];
//            } else {
//                [imageNameMutable appendString:@"-568h@2x"];
//            }
//        }
//    }
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@""];
//    if (imagePath) {
//        UIImage *res = [UIImage retina4ImageNamed:imageNameMutable];
//        return res;
//    } else {
//        UIImage *res = [UIImage retina4ImageNamed:imageName];
//        return res;
//    }
//    return nil;
//}


//==============================================================================

+ (void)load {
    if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
         ([UIScreen mainScreen].bounds.size.height > 480.0f)) {
        method_exchangeImplementations(class_getClassMethod(self, @selector(imageNamed:)),
                                       class_getClassMethod(self, @selector(imageNamedH568:)));
    }
}

+ (UIImage *)imageNamedH568:(NSString *)imageName {
    NSLog(@"=568h=Loading image named => %@", imageName);
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
        //Remove the @2x to load with the correct scale 2.0
        [imageNameMutable replaceOccurrencesOfString:@"-568h@2x" withString:@"-568h" options:NSBackwardsSearch range:NSMakeRange(0, [imageNameMutable length])];
    }
    
    UIImage *res = nil;
    
    if (imagePath) {
        res = [UIImage imageNamedH568:imageNameMutable];
        if (res)
            NSLog(@"A-B:Loaded image A: name = '%@', scale = %.2f, size = (%.2f, %.2f)",
                  imageNameMutable, res.scale, res.size.width, res.size.height);
    }
    if (!res) {
        res = [UIImage imageNamedH568:imageName];
        if (res)
            NSLog(@"A-B:Loaded image B: name = '%@', scale = %.2f, size = (%.2f, %.2f)",
                  imageName, res.scale, res.size.width, res.size.height);
    }
    return res;
}


//+ (UIImage *)imageNamedH568:(NSString *)imageName {
//    
//    NSMutableString *imageNameMutable = [imageName mutableCopy];
//    
//    //Delete png extension
//    NSRange extension = [imageName rangeOfString:@".png" options:NSBackwardsSearch | NSAnchoredSearch];
//    if (extension.location != NSNotFound) {
//        [imageNameMutable deleteCharactersInRange:extension];
//    }
//    
//    //Look for @2x to introduce -568h string
//    NSRange retinaAtSymbol = [imageName rangeOfString:@"@2x"];
//    if (retinaAtSymbol.location != NSNotFound) {
//        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
//    } else {
//        [imageNameMutable appendString:@"-568h@2x"];
//    }
//    
//    //Check if the image exists and load the new 568 if so or the original name if not
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@"png"];
//    if (imagePath) {
//        //Remove the @2x to load with the correct scale 2.0
//        [imageNameMutable replaceOccurrencesOfString:@"@2x" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, [imageNameMutable length])];
//        UIImage *res = [UIImage imageNamedH568:imageNameMutable];
//        return res;
//    } else {
//        UIImage *res = [UIImage imageNamedH568:imageName];
//        return res;
//    }
//}

@end
