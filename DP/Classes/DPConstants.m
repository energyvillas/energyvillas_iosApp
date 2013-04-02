//
//  DPConstants.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPConstants.h"
#import "DPAppHelper.h"
/*
NSString *const MyFirstConstant = @"FirstConstant";
NSString *const MySecondConstant = @"SecondConstant";
*/

//notifications
NSString *const DPN_currentLangChanged = @"DPN_currentLangChanged";

// bundle id
NSString *const PRODUCT_IDENTIFIER = @"gr.DesignProjects.DP";

// web service credentials
NSString *const USER_NAME = @"phone";
NSString *const PASSWORD = @"phone";

// web service URLs
NSString *const BANNERS_URL = @"http://designprojectsapps.com/iphonebanners.php";
// http://www.mysite.com/iphonebanners.php?user=<UUU>&pass=<PPP>&group=<XXX>

NSString *const CATEGORIES_URL = @"http://designprojectsapps.com/iphonecategory.php";
// http://www.mysite.com/iphonecategory.php?user=<UUU>&pass=<PPP>&lang=<XXX>&parentid=<YYY>

NSString *const ARTICLES_URL = @"http://designprojectsapps.com/iphonenews.php";
// http://www.mysite.com/iphonenews.php?user=<UUU>&pass=<PPP>&lang=<XXX>&cid=<YYY>&count=<WWW>&from=<ZZZ>



// localization keys
NSString *const ktbiMain_Title = @"tbiMain_Title";
NSString *const ktbiWho_Title = @"tbiWho_Title";
NSString *const ktbiBuy_Title = @"tbiBuy_Title";
NSString *const ktbiCall_Title = @"tbiCall_Title";
NSString *const ktbiMore_Title = @"tbiMore_Title";

NSString *const kbbiMore_Title = @"bbiMore_Title";
NSString *const kbbiBuy_Title = @"bbiBuy_Title";

NSString *const MENU_TITLE_Fmt = @"MENU_TITLE_%i";

NSString *const kIMAGE_RESET_MENU = @"IMAGE_RESET_MENU";


void showAlertMessage(id aDelegate, NSString *aTitle, NSString *aMessage) {
	UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc]
                   initWithTitle:aTitle
                   message:aMessage
                   delegate:aDelegate
                   cancelButtonTitle: NSLocalizedString(@"btnOK_Title", nil)
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
    
    return result;
}

NSString* NullIfEmpty(NSString *aString) {
    return aString == nil || [aString isEqualToString:@""] ? nil : aString;
}

