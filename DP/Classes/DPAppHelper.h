//
//  DPAppHelper.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"

@interface DPAppHelper : NSObject

@property (readonly, nonatomic) BOOL connectionRequired;
@property (readonly, nonatomic) BOOL hostIsReachable;

@property (nonatomic, readonly) BOOL useCache;
@property (nonatomic, readonly, getter = calcIsPurchased) BOOL isPurchased;
@property (strong, nonatomic) NSString *currentLang;

@property (strong, nonatomic) NSString *imageTitle2Share;
@property (strong, nonatomic) NSString *imageUrl2Share;


//===========

+ (DPAppHelper *)sharedInstance;

- (NSArray *) freeDetailsFor:(NSString *)lang;
- (NSArray *) freeBuyContentFor:(int)ctgid lang:(NSString *)lang;
- (NSArray *) freeCoverFlowFor:(NSString *)lang;
- (NSArray *) paidMenuOfCategory:(int)aId lang:(NSString *)lang;
//- (NSArray *) getSubCategoriesOf:(int)parentid;

- (void) saveImageToCache:(NSString *)url data:(NSData *)imgData;
- (NSData *) loadImageFromCache:(NSString *)url;
- (UIImage *) loadUIImageFromCache:(NSString *)url;

#pragma mark - favorites handling
- (BOOL) isArticleInFavorites:(Article *)article;
- (void) addToFavorites:(Article *)article;
- (void) removeFromFavorites:(Article *)article;

- (void) saveFavorites;
- (NSDictionary *) favoriteArticles;
@end
