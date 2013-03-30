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

//===========

+ (DPAppHelper *)sharedInstance;

@end
