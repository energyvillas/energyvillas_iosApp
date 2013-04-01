//
//  DPAppHelper.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPAppHelper : NSObject

@property (strong, nonatomic) NSArray *freeDetails;
@property (strong, nonatomic) NSArray *freeBuyContent;

@property (readonly) BOOL connectionRequired;
@property (readonly) BOOL hostIsReachable;

//===========

+ (DPAppHelper *)sharedInstance;

@end
