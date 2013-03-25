//
//  DPDataLoader.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const ARTICLES_URL;
UIKIT_EXTERN NSString *const USER_NAME;
UIKIT_EXTERN NSString *const PASSWORD;

#define CTGID_WHO_WE_ARE ((int)60)

@interface DPDataLoader : NSObject

+(NSString*) digestSHA1:(NSString*)input;

@end
