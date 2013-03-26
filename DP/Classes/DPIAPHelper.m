//
//  DPIAPHelper.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPIAPHelper.h"
#import "DPConstants.h"


@implementation DPIAPHelper

+ (DPIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static DPIAPHelper * sharedInstance;
    
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      PRODUCT_IDENTIFIER,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    
    return sharedInstance;
}

@end
