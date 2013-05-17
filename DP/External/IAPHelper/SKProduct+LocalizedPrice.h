//
//  SKProduct+LocalizedPrice.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/16/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end