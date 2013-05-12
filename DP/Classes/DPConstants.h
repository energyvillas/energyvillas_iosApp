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

#define USE_TEST_SITE ((BOOL)NO)

#define IS_IPAD ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))

#define IS_IPHONE_5 ( ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) && (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON ))

#define IS_IPHONE ( ((BOOL)([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) && (!IS_IPHONE_5))

#define DEVICE_SCALE ((CGFloat)[UIScreen mainScreen].scale)

#define IS_RETINA ((BOOL)(abs([UIScreen mainScreen].scale - 2.0) < DBL_EPSILON))

#define INTERFACE_ORIENTATION ( (UIInterfaceOrientation) [UIApplication sharedApplication].statusBarOrientation)

#define IS_PORTRAIT ((BOOL)UIInterfaceOrientationIsPortrait(INTERFACE_ORIENTATION))
#define IS_LANDSCAPE ((BOOL)UIInterfaceOrientationIsLandscape(INTERFACE_ORIENTATION))

#define STATUS_BAR_VISIBLE ((BOOL) ![UIApplication sharedApplication].statusBarHidden)
#define STATUS_BAR_HEIGHT ((CGFloat) ![UIApplication sharedApplication].statusBarFrame.size.height)


#define CURRENT_LANG ((NSString *)[DPAppHelper sharedInstance].currentLang)
#define IS_APP_PURCHASED ((BOOL)[DPAppHelper sharedInstance].isPurchased)
#define IS_APP_FREE ((BOOL)![DPAppHelper sharedInstance].isPurchased)


// for scrollable views
#define PAGE_CONTROL_HEIGHT ((int)16)

// timer intervals
#define AUTO_SCROLL_INTERVAL ((float) 3.0)
#define USER_SCROLL_INTERVAL ((float) 60.0)

// social button tags
#define SOCIAL_ACT_FACEBOOK ((int)1)
#define SOCIAL_ACT_TWITTER ((int)2)
#define SOCIAL_ACT_LINKEDIN ((int)3)
#define SOCIAL_ACT_EMAIL ((int)4)
#define SOCIAL_ACT_FAVS ((int)5)
#define SOCIAL_ACT_OTHER ((int)6)

//navbar items
#define TAG_NBI_LANG_EN ((int)101)
#define TAG_NBI_LANG_EL ((int)102)
#define TAG_NBI_BACK ((int)103)
#define TAG_NBI_ADD_FAV ((int)104)
#define TAG_NBI_SHARE ((int)105)

// tabBar buttons
#define TAG_TBI_MAIN ((int)1001)
#define TAG_TBI_WHO ((int)1002)
#define TAG_TBI_BUY ((int)1003)
#define TAG_TBI_CALL ((int)1004)
#define TAG_TBI_MORE ((int)1005)

// main menu buttons
#define CTGID_SMART ((int)52) //100)
#define CTGID_LOFT ((int)53)
#define CTGID_FINLAND ((int)54)
#define CTGID_ISLAND ((int)55) // 103)
#define CTGID_COUNTRY ((int)56)
#define CTGID_CONTAINER ((int)65)
#define CTGID_VILLAS ((int)57)
#define CTGID_EXCLUSIVE ((int)58)
#define CTGID_VIDEOS ((int)59)

// main sub menu buttons
#define CTGID_ISLAND_AEGEAN ((int)62)
#define CTGID_ISLAND_CYCLADIC ((int)63)
#define CTGID_ISLAND_IONIAN ((int)64)

#define CTGID_EXCLUSIVE_DESIGNER ((int)74)
#define CTGID_EXCLUSIVE_ART ((int)75)

// predefined categories IDs
#define CTGID_CAROUSEL ((int)77)
#define CTGID_CAROUSEL_MORE ((int)78)
#define CTGID_GENERAL_BUY_DLG ((int)76)
#define CTGID_WHO_WE_ARE ((int)60)
#define CTGID_NEW_NEXT ((int)-1000)

// HOUSE INFO KIND IDs
#define HIKID_UNDEFINED ((int)-1) //	UNDEFINED
#define HIKID_FLOOR_PLAN ((int)1)	 // ΚΑΤΟΨΕΙΣ
//#define HIKID_FACES ((int)2)	 // ΟΨΕΙΣ
#define HIKID_SECTIONS ((int)3)	 // ΤΟΜΕΣ
#define HIKID_INTERIOR ((int)4)  // 	ΕΣΩΤΕΡΙΚΟΙ ΧΩΡΟΙ
#define HIKID_EXTERIOR ((int)5)	 // ΕΞΩΤΕΡΙΚΟΙ ΧΩΡΟΙ
#define HIKID_GROUND_FLOOR ((int)6)	 // ΙΣΟΓΕΙΟ
#define HIKID_1ST_FLOOR ((int)7)	 // ΟΡΟΦΟΣ
#define HIKID_ATTIC ((int)8)	 // ΠΑΤΑΡΙ
#define HIKID_HEATING_COOLING ((int)9)	 // ΘΕΡΜΑΝΣΗ - ΔΡΟΣΙΣΜΟΣ
#define HIKID_ENERGY_SAVING ((int)10)	// ΕΞΟΙΚΟΝΟΜΗΣΗ ΕΝΕΡΓΕΙΑΣ
#define HIKID_GARDEN_ARCHITECTURE ((int)14)	// ΑΡΧΙΤΕΚΤΟΝΙΚΗ ΚΗΠΟΥ
#define HIKID_LIGHTING ((int)15)	// ΜΕΛΕΤΗ ΦΩΤΙΣΜΟΥ
#define HIKID_LUMINAIRES ((int)16)	// ΦΩΤΙΣΤΙΚΑ ΣΩΜΑΤΑ
#define HIKID_COMING_SOON_COMMON ((int)17)	// COMING SOON - COMMON
#define HIKID_COMING_SOON_DESIGNER ((int)18)	// COMING SOON - DESIGNER SERIES
#define HIKID_COMING_SOON_ART ((int)19)	// COMING SOON - ART SERIES
#define HIKID_CUSTOM ((int)20)	// CUSTOM

//// HOUSE INFO KIND IMGs
//UIKIT_EXTERN NSString *const HIK_IMG_UNDEFINED; //	UNDEFINED
//UIKIT_EXTERN NSString *const HIK_IMG_FLOOR_PLAN;	 // ΚΑΤΟΨΕΙΣ
//UIKIT_EXTERN NSString *const HIK_IMG_FACES;	 // ΟΨΕΙΣ
//UIKIT_EXTERN NSString *const HIK_IMG_SECTIONS;	 // ΤΟΜΕΣ
//UIKIT_EXTERN NSString *const HIK_IMG_INTERIOR;  // 	ΕΣΩΤΕΡΙΚΟΙ ΧΩΡΟΙ
//UIKIT_EXTERN NSString *const HIK_IMG_EXTERIOR;	 // ΕΞΩΤΕΡΙΚΟΙ ΧΩΡΟΙ
//UIKIT_EXTERN NSString *const HIK_IMG_GROUND_FLOOR;	 // ΙΣΟΓΕΙΟ
//UIKIT_EXTERN NSString *const HIK_IMG_1ST_FLOOR;	 // ΟΡΟΦΟΣ
//UIKIT_EXTERN NSString *const HIK_IMG_ATTIC;	 // ΠΑΤΑΡΙ
//UIKIT_EXTERN NSString *const HIK_IMG_HEATING_COOLING;	 // ΘΕΡΜΑΝΣΗ - ΔΡΟΣΙΣΜΟΣ
//UIKIT_EXTERN NSString *const HIK_IMG_ENERGY_SAVING;	// ΕΞΟΙΚΟΝΟΜΗΣΗ ΕΝΕΡΓΕΙΑΣ
//UIKIT_EXTERN NSString *const HIK_IMG_GARDEN_ARCHITECTURE;	// ΑΡΧΙΤΕΚΤΟΝΙΚΗ ΚΗΠΟΥ
//UIKIT_EXTERN NSString *const HIK_IMG_LIGHTING;	// ΜΕΛΕΤΗ ΦΩΤΙΣΜΟΥ
//UIKIT_EXTERN NSString *const HIK_IMG_LUMINAIRES;	// ΦΩΤΙΣΤΙΚΑ ΣΩΜΑΤΑ
//UIKIT_EXTERN NSString *const HIK_IMG_COMING_SOON_COMMON;	// COMING SOON - COMMON
//UIKIT_EXTERN NSString *const HIK_IMG_COMING_SOON_DESIGNER;	// COMING SOON - DESIGNER SERIES
//UIKIT_EXTERN NSString *const HIK_IMG_COMING_SOON_ART;	// COMING SOON - ART SERIES
//UIKIT_EXTERN NSString *const HIK_IMG_CUSTOM;	// CUSTOM

// DEVICE TYPE IDs
#define DEVICE_TYPE_ID_IPHONE ((int)1)
#define DEVICE_TYPE_ID_IPHONE_RETINA ((int)2)
#define DEVICE_TYPE_ID_IPHONE5 ((int)3)
#define DEVICE_TYPE_ID_IPAD ((int)4)
#define DEVICE_TYPE_ID_IPAD_RETINA ((int)5)

// option identifier
UIKIT_EXTERN NSString *const USE_DATA_CACHING;

// notifications
UIKIT_EXTERN NSString *const DPN_currentLangChanged;


// bundle id
UIKIT_EXTERN NSString *const PRODUCT_IDENTIFIER;

// web service credentials
UIKIT_EXTERN NSString *const USER_NAME;
UIKIT_EXTERN NSString *const PASSWORD;

// web service URLs
UIKIT_EXTERN NSString *const BASE_HOST_NAME;

UIKIT_EXTERN NSString *const BANNERS_URL;
UIKIT_EXTERN NSString *const CATEGORIES_URL;
UIKIT_EXTERN NSString *const HOUSE_OVERVIEW_URL;
UIKIT_EXTERN NSString *const ARTICLES_URL;
// test webservice urls
UIKIT_EXTERN NSString *const BASE_HOST_NAME_TEST;

UIKIT_EXTERN NSString *const BANNERS_URL_TEST;
UIKIT_EXTERN NSString *const CATEGORIES_URL_TEST;
UIKIT_EXTERN NSString *const HOUSE_OVERVIEW_URL_TEST;
UIKIT_EXTERN NSString *const ARTICLES_URL_TEST;


// localization keys
UIKIT_EXTERN NSString *const kbtnOK_Title;

UIKIT_EXTERN NSString *const ktbiMain_Title;
UIKIT_EXTERN NSString *const ktbiWho_Title;
UIKIT_EXTERN NSString *const ktbiBuy_Title;
UIKIT_EXTERN NSString *const ktbiCall_Title;
UIKIT_EXTERN NSString *const ktbiMore_Title;

UIKIT_EXTERN NSString *const kbbiMore_Title;
UIKIT_EXTERN NSString *const kbbiMoreBack_Title;
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

void NSLogFrame(NSString *msg, CGRect frame);

BOOL isLocalUrl(NSString *urlstr);

UILabel * createLabel(CGRect frame, NSString *title, UIFont *font);

int getDeviceType();

NSString* SHA1Digest(NSString* input);

NSString* getDocumentsFilePath(NSString* filename);


