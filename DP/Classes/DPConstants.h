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

#define IS_IPAD ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))

#define IS_IPHONE_5 ( ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) && (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON ))

#define IS_IPHONE ( ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) && (!IS_IPHONE_5))

#define INTERFACE_ORIENTATION ( (UIInterfaceOrientation) [UIApplication sharedApplication].statusBarOrientation)

#define STATUS_BAR_VISIBLE ((BOOL) ![UIApplication sharedApplication].statusBarHidden)
#define STATUS_BAR_HEIGHT ((CGFloat) ![UIApplication sharedApplication].statusBarFrame.size.height)

// timer intervals
#define AUTO_SCROLL_INTERVAL ((float) 5.0)
#define USER_SCROLL_INTERVAL ((float) 60.0)



// tabBar buttons
#define TAG_TBI_MAIN ((int)1001)
#define TAG_TBI_WHO ((int)1002)
#define TAG_TBI_BUY ((int)1003)
#define TAG_TBI_CALL ((int)1004)
#define TAG_TBI_MORE ((int)1005)

// main menu buttons
#define TAG_MM_SMART ((int)52) //100)
#define TAG_MM_LOFT ((int)101)
#define TAG_MM_FINLAND ((int)102)
#define TAG_MM_ISLAND ((int)55) // 103)
#define TAG_MM_COUNTRY ((int)104)
#define TAG_MM_CONTAINER ((int)105)
#define TAG_MM_VILLAS ((int)106)
#define TAG_MM_EXCLUSIVE ((int)107)
#define TAG_MM_VIDEOS ((int)108)

// main sub menu buttons
#define TAG_MM_ISLAND_SHIFT ((int)100)
#define TAG_MM_ISLAND_AEGEAN ((int)(TAG_MM_ISLAND * TAG_MM_ISLAND_SHIFT) + 00)
#define TAG_MM_ISLAND_CYCLADIC ((int)(TAG_MM_ISLAND * TAG_MM_ISLAND_SHIFT) + 01)
#define TAG_MM_ISLAND_IONIAN ((int)(TAG_MM_ISLAND * TAG_MM_ISLAND_SHIFT) + 02)

// predefined categories IDs
#define CTGID_WHO_WE_ARE ((int)60)

// notifications
UIKIT_EXTERN NSString *const DPN_currentLangChanged;


// bundle id
UIKIT_EXTERN NSString *const PRODUCT_IDENTIFIER;

// web service credentials
UIKIT_EXTERN NSString *const USER_NAME;
UIKIT_EXTERN NSString *const PASSWORD;

// web service URLs
UIKIT_EXTERN NSString *const BANNERS_URL;
UIKIT_EXTERN NSString *const CATEGORIES_URL;
UIKIT_EXTERN NSString *const ARTICLES_URL;


// localization keys
UIKIT_EXTERN NSString *const kbtnOK_Title;

UIKIT_EXTERN NSString *const ktbiMain_Title;
UIKIT_EXTERN NSString *const ktbiWho_Title;
UIKIT_EXTERN NSString *const ktbiBuy_Title;
UIKIT_EXTERN NSString *const ktbiCall_Title;
UIKIT_EXTERN NSString *const ktbiMore_Title;

UIKIT_EXTERN NSString *const kbbiMore_Title;
UIKIT_EXTERN NSString *const kbbiBuy_Title;

UIKIT_EXTERN NSString *const kMENU_TITLE_Fmt;

UIKIT_EXTERN NSString *const kIMAGE_RESET_MENU;

UIKIT_EXTERN NSString *const kERR_TITLE_URL_NOT_FOUND;
UIKIT_EXTERN NSString *const kERR_MSG_DATA_LOAD_FAILED;

UIKIT_EXTERN NSString *const kERR_TITLE_INFO;
UIKIT_EXTERN NSString *const kERR_MSG_NO_DATA_FOUND;

UIKIT_EXTERN NSString *const kERR_TITLE_CONNECTION_FAILED;
UIKIT_EXTERN NSString *const kERR_MSG_TRY_LATER;


// functions
void showAlertMessage(id delegate, NSString *aTitle, NSString *aMessage);

NSString* DPLocalizedString(NSString *key);

NSString* NullIfEmpty(NSString *aString);

