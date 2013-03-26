//
//  DPConstants.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

/*
FOUNDATION_EXPORT NSString *const MyFirstConstant;
FOUNDATION_EXPORT NSString *const MySecondConstant;
*/

#define IS_PHONE ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone))

#define IS_PAD ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))

#define IS_IPHONE_5 ( IS_PHONE && fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

// timer intervals
#define AUTO_SCROLL_INTERVAL ((float) 3.0)


// tabBar buttons
#define TAG_TBI_MAIN ((int)1001)
#define TAG_TBI_WHO ((int)1002)
#define TAG_TBI_BUY ((int)1003)
#define TAG_TBI_CALL ((int)1004)
#define TAG_TBI_MORE ((int)1005)

// main menu buttons
#define TAG_MM_SMART ((int)100)
#define TAG_MM_LOFT ((int)101)
#define TAG_MM_FINLAND ((int)102)
#define TAG_MM_ISLAND ((int)103)
#define TAG_MM_COUNTRY ((int)104)
#define TAG_MM_CONTAINER ((int)105)
#define TAG_MM_VILLAS ((int)106)
#define TAG_MM_EXCLUSIVE ((int)107)
#define TAG_MM_VIDEOS ((int)108)

// main sub menu buttons
#define TAG_MM_ISLAND_AEGEAN ((int)200)
#define TAG_MM_ISLAND_CYCLADIC ((int)201)
#define TAG_MM_ISLAND_IONIAN ((int)202)

// predefined categories IDs
#define CTGID_WHO_WE_ARE ((int)60)

// bundle id
UIKIT_EXTERN NSString *const PRODUCT_IDENTIFIER;

// web service credentials
UIKIT_EXTERN NSString *const USER_NAME;
UIKIT_EXTERN NSString *const PASSWORD;

// web service URLs
UIKIT_EXTERN NSString *const ARTICLES_URL;


// localization keys
UIKIT_EXTERN NSString *const ktbiMain_Title;
UIKIT_EXTERN NSString *const ktbiWho_Title;
UIKIT_EXTERN NSString *const ktbiBuy_Title;
UIKIT_EXTERN NSString *const ktbiCall_Title;
UIKIT_EXTERN NSString *const ktbiMore_Title;

UIKIT_EXTERN NSString *const kbbiMore_Title;
UIKIT_EXTERN NSString *const kbbiBuy_Title;

UIKIT_EXTERN NSString *const MENU_TITLE_Fmt;

UIKIT_EXTERN NSString *const kIMAGE_RESET_MENU;
