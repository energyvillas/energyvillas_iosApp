//
//  DPIAPHelper.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "IAPHelper.h"

UIKIT_EXTERN NSString *const PRODUCT_IDENTIFIER;

@interface DPIAPHelper : IAPHelper

+ (DPIAPHelper *)sharedInstance;

@end
