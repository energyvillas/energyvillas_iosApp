//
//  DPAppHelper.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Article.h"

@interface DPAppHelper : NSObject

@property (readonly, nonatomic) BOOL connectionRequired;
@property (readonly, nonatomic) BOOL hostIsReachable;

@property (nonatomic, readonly) BOOL useCache;
@property (nonatomic, readonly, getter = calcIsPurchased) BOOL isPurchased;
@property (strong, nonatomic) NSString *currentLang;

@property (strong, nonatomic) NSString *imageTitle2Share;
@property (strong, nonatomic) NSString *imageUrl2Share;

@property (readonly, nonatomic) SystemSoundID wooshSound;
@property (readonly, nonatomic) SystemSoundID bloodSplatOnWallSound;
@property (readonly, nonatomic) SystemSoundID bloodSplatSound;
@property (readonly, nonatomic) SystemSoundID magicWandSound;
@property (readonly, nonatomic) SystemSoundID openSodaSound;
@property (readonly, nonatomic) SystemSoundID pinDropSound;
@property (readonly, nonatomic) SystemSoundID tingSound;
@property (readonly, nonatomic) SystemSoundID bloodSquirtSound;
@property (readonly, nonatomic) SystemSoundID electricalSweepSound;
@property (readonly, nonatomic) SystemSoundID spitSplatSound;



//===========

+ (DPAppHelper *)sharedInstance;

- (NSArray *) freeDetailsFor:(NSString *)lang;
//- (NSArray *) freeBuyContentFor:(int)ctgid lang:(NSString *)lang;
- (NSArray *) freeCoverFlowFor:(NSString *)lang;
- (NSArray *) paidMenuOfCategory:(int)aId lang:(NSString *)lang;
//- (NSArray *) getSubCategoriesOf:(int)parentid;

- (NSString *) imageNameToCacheKey:(NSString *)url;
- (void) saveImageToCache:(NSString *)url data:(NSData *)imgData;
- (NSData *) loadImageFromCache:(NSString *)url;
- (UIImage *) loadUIImageFromCache:(NSString *)url;
- (BOOL) isImageInCache:(NSString *)url;

#pragma mark - favorites handling
- (BOOL) isArticleInFavorites:(Article *)article;
- (void) addToFavorites:(Article *)article;
- (void) removeFromFavorites:(Article *)article;

- (void) saveFavorites;
- (NSDictionary *) favoriteArticles;

// sounds
- (void) playSoundWoosh;
- (void) playSoundBloodSplatOnWall;
- (void) playSoundBloodSplat;
- (void) playSoundMagicWand;
- (void) playSoundOpenSoda;
- (void) playSoundPinDrop;
- (void) playSoundTing;
- (void) playSoundBloodSquirt;
- (void) playSoundElectricalSweep;
- (void) playSoundSpitSplat;

@end
