//
//  DPAppHelper.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPAppHelper : NSObject

@property (readonly, nonatomic) BOOL connectionRequired;
@property (readonly, nonatomic) BOOL hostIsReachable;

@property (nonatomic, readonly) BOOL useCache;
@property (strong, nonatomic) NSString *currentLang;


//===========

+ (DPAppHelper *)sharedInstance;

- (NSArray *) freeDetailsFor:(NSString *)lang;
- (NSArray *) freeBuyContentFor:(int)ctgid lang:(NSString *)lang;
- (NSArray *) freeCoverFlowFor:(NSString *)lang;
- (NSArray *) paidMenuOfCategory:(int)aId lang:(NSString *)lang;
- (NSArray *) getSubCategoriesOf:(int)parentid;

- (void) saveImageToCache:(NSString *)url data:(NSData *)imgData;
- (NSData *) loadImageFromCache:(NSString *)url;
@end
