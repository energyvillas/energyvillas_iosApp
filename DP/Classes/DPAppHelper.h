//
//  DPAppHelper.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPAppHelper : NSObject

@property (readonly) BOOL connectionRequired;
@property (readonly) BOOL hostIsReachable;

@property (strong, nonatomic) NSString *currentLang;

//===========

+ (DPAppHelper *)sharedInstance;

- (NSArray *) freeDetailsFor:(NSString *)lang;
- (NSArray *) freeBuyContentFor:(NSString *)lang;
- (NSArray *) freeCoverFlowFor:(NSString *)lang;
- (NSArray *) paidArticlesOfCategory:(int)aId lang:(NSString *)lang;

@end
