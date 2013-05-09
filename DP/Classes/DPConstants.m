//
//  DPConstants.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPConstants.h"
#import "DPAppHelper.h"
#import <QuartzCore/QuartzCore.h>
/*
NSString *const MyFirstConstant = @"FirstConstant";
NSString *const MySecondConstant = @"SecondConstant";
*/

// option identifier
NSString *const USE_DATA_CACHING = @"USE_DATA_CACHING";

//notifications
NSString *const DPN_currentLangChanged = @"DPN_currentLangChanged";

// bundle id
NSString *const PRODUCT_IDENTIFIER = @"gr.DesignProjects.DP";

// web service credentials
NSString *const USER_NAME = @"phone";
NSString *const PASSWORD = @"phone";


NSString *const BASE_HOST_NAME = @"www.designprojectsapps.com";
NSString *const BASE_HOST_NAME_TEST = @"192.168.16.2/designprojectsapps";

// web service URLs
NSString *const BANNERS_URL = @"http://designprojectsapps.com/iphonebanners.php";
NSString *const BANNERS_URL_TEST = @"http://192.168.16.2/designprojectsapps/iphonebanners.php";
// http://www.mysite.com/iphonebanners.php?user=<UUU>&pass=<PPP>&group=<XXX>

NSString *const CATEGORIES_URL = @"http://designprojectsapps.com/iphonecategory.php";
NSString *const CATEGORIES_URL_TEST = @"http://192.168.16.2/designprojectsapps/iphonecategory.php";
// http://www.mysite.com/iphonecategory.php?user=<UUU>&pass=<PPP>&lang=<XXX>&parentid=<YYY>&devicetype=<DDD>

NSString *const ARTICLES_URL = @"http://designprojectsapps.com/iphonenews.php";
NSString *const ARTICLES_URL_TEST = @"http://192.168.16.2/designprojectsapps/iphonearticles.php";
// http://www.mysite.com/iphonenews.php?user=<UUU>&pass=<PPP>&lang=<XXX>&cid=<YYY>&count=<WWW>&from=<ZZZ>

NSString *const HOUSE_OVERVIEW_URL = @"http://designprojectsapps.com/iphonehouseoverview.php";
NSString *const HOUSE_OVERVIEW_URL_TEST = @"http://192.168.16.2/designprojectsapps/iphonehouseoverview.php";
// http://www.mysite.com/iphonehouseoverview.php?user=<UUU>&pass=<PPP>&lang=<XXX>&cid=<YYY>

// localization keys
NSString *const kbtnOK_Title = @"btnOK_Title";

NSString *const ktbiMain_Title = @"tbiMain_Title";
NSString *const ktbiWho_Title = @"tbiWho_Title";
NSString *const ktbiBuy_Title = @"tbiBuy_Title";
NSString *const ktbiCall_Title = @"tbiCall_Title";
NSString *const ktbiMore_Title = @"tbiMore_Title";

NSString *const kbbiMore_Title = @"bbiMore_Title";
NSString *const kbbiMoreBack_Title = @"bbiMoreBack_Title";

NSString *const kbbiBuy_Title = @"bbiBuy_Title";

NSString *const kMENU_TITLE_Fmt = @"MENU_TITLE_%i";

NSString *const kIMAGE_RESET_MENU = @"IMAGE_RESET_MENU";

NSString *const kERR_TITLE_URL_NOT_FOUND = @"ERR_TITLE_URL_NOT_FOUND";
NSString *const kERR_MSG_DATA_LOAD_FAILED = @"ERR_MSG_DATA_LOAD_FAILED";

NSString *const kERR_TITLE_INFO = @"ERR_TITLE_INFO";
NSString *const kERR_MSG_NO_DATA_FOUND = @"ERR_MSG_NO_DATA_FOUND";

NSString *const kERR_TITLE_CONNECTION_FAILED = @"ERR_TITLE_CONNECTION_FAILED";
NSString *const kERR_MSG_TRY_LATER = @"ERR_MSG_TRY_LATER";


void showAlertMessage(id aDelegate, NSString *aTitle, NSString *aMessage) {
	UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc]
                   initWithTitle:aTitle
                   message:aMessage
                   delegate:aDelegate
                   cancelButtonTitle: DPLocalizedString(kbtnOK_Title)
                   otherButtonTitles:nil];
    
	[alertDialog show];
}

NSString* DPLocalizedString(NSString *key)
{
    NSString *langCode = [DPAppHelper sharedInstance].currentLang;

    // langCode should be set as a global variable somewhere
    NSString *path = [[NSBundle mainBundle] pathForResource:langCode ofType:@"lproj"];
    NSBundle* languageBundle = [NSBundle bundleWithPath:path];

    NSString *result = [languageBundle localizedStringForKey:key value:@"" table:nil];
    if ([result isEqualToString:@""]) {
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        languageBundle = [NSBundle bundleWithPath:path];

        result = [languageBundle localizedStringForKey:key value:@"" table:nil];
    }
    
    NSLog(@"Localized Key:%@, Value:%@", key, result);
    
    return result;
}

NSString* NullIfEmpty(NSString *aString) {
    return aString == nil || aString.length == 0 || [aString isEqualToString:@""] ? nil : aString;
}

void NSLogFrame(NSString *msg, CGRect frame) {
    NSLog(@"%@ :: frame(x, y, w, h) = (%f, %f, %f, %f)",
          msg,
          frame.origin.x, frame.origin.y,
          frame.size.width, frame.size.height);
}

BOOL isLocalUrl(NSString *urlstr) {
    NSURL *url = [NSURL URLWithString:urlstr];
    return url.isFileReferenceURL || url.host == nil;
}


UILabel * createLabel(CGRect frame, NSString *title, UIFont *font) {
    // add label
    UILabel *lv = [[UILabel alloc] initWithFrame: frame];
    lv.textAlignment = NSTextAlignmentCenter;
    if (font!=nil) {
        lv.font = font;
    } else {
        if (IS_IPAD)
            lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        else
            lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    }
    lv.adjustsFontSizeToFitWidth = NO;
    lv.text = /*element.*/title;
    lv.backgroundColor = [UIColor clearColor];
    [lv sizeToFit];
    CGRect b = lv.bounds;
    int offsetfix = IS_IPAD ? 4 : 2;
    lv.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - b.size.height - offsetfix,
                          frame.size.width, b.size.height);
    // setup text shadow
    lv.textColor = [UIColor blackColor];
    lv.layer.shadowColor = [lv.textColor CGColor];
    lv.textColor = [UIColor whiteColor];
    lv.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    lv.layer.masksToBounds = NO;
    lv.layer.shadowRadius = 1.9f;
    lv.layer.shadowOpacity = 0.95;

    return lv;
}

int getDeviceType() {
    if (IS_IPHONE)
        return IS_RETINA ? DEVICE_TYPE_ID_IPHONE_RETINA : DEVICE_TYPE_ID_IPHONE;
    
    if (IS_IPHONE_5)
        return DEVICE_TYPE_ID_IPHONE5;
    
    if (IS_IPAD)
        return IS_RETINA ? DEVICE_TYPE_ID_IPAD_RETINA : DEVICE_TYPE_ID_IPAD;
    
    return -1;
}

