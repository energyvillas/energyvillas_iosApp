//
//  main.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DPAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([DPAppDelegate class]));
        int retVal = -1;
        @try {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([DPAppDelegate class]));
        }
        @catch (NSException* exception) {
            NSLog(@"Uncaught exception: %@", exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        }
        return retVal;
    }
}
