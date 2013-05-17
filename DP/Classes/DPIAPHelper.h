//
//  DPIAPHelper.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "IAPHelper.h"

@interface DPIAPHelper : IAPHelper

@property (strong, nonatomic, readonly) SKProduct *product;

+ (DPIAPHelper *)sharedInstance;
+ (void) loadStore;
- (void) buy;
@end
