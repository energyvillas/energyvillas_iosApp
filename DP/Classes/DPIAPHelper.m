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

@synthesize product = _product;

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

+(void) loadStore {
    DPIAPHelper *iap = [DPIAPHelper sharedInstance];
    if (![iap isPurchased])
        [iap doLoadStore];
}

- (BOOL) isPurchased {
    return [self productPurchased:PRODUCT_IDENTIFIER];
}

-(void) doLoadStore {
    if (self.product == nil)
        [self requestProductsWithCompletionHandler:^(NSArray * products, NSError *error) {
            if (products != nil) {
                _product = (SKProduct *)products[0];
            }
        }];
}

-(void) buy {
    [self buyProduct:self.product];
}

@end
