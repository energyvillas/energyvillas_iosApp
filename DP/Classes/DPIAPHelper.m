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
        [self requestProducts];
}

- (void) productsRequestCompleted:(NSArray *)products error:(NSError *)error {
    BOOL tryagain = YES;
    if (products != nil && products.count == 1) {
        _product = (SKProduct *)products[0];
        tryagain = NO;
    }
    [super productsRequestCompleted:products error:error];
    
    if (tryagain) {
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [DPIAPHelper loadStore];
        });
    }
}

-(void) buy {
    if (self.product)
        [self buyProduct:self.product];
}

@end
