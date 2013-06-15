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
#import <CommonCrypto/CommonDigest.h>
#import "UIImage+FX.h"


/*
NSString *const MyFirstConstant = @"FirstConstant";
NSString *const MySecondConstant = @"SecondConstant";
*/

// option identifier
NSString *const USE_DATA_CACHING_Key = @"USE_DATA_CACHING";

//notifications
NSString *const DPN_currentLangChanged = @"DPN_currentLangChanged";
NSString *const DPN_ShowFacebookViewNotification = @"DPN_ShowFacebookViewNotification";
NSString *const DPN_PAID_SelectedCategoryChanged_Notification = @"DPN_PAID_SelectedCategoryChanged_Notification";
NSString *const DPN_FavoritesChangedNotification = @"DPN_FavoritesChangedNotification";
// bundle id
NSString *const PRODUCT_IDENTIFIER = @"com.energyvillas.energyvillas.ev01";

// web service credentials
NSString *const USER_NAME = @"phone";
NSString *const PASSWORD = @"phone";


NSString *const BASE_HOST_NAME = @"www.designprojectsapps.com";
NSString *const BASE_HOST_NAME_TEST = @"192.168.1.4/designprojectsapps";

// web service URLs
NSString *const BANNERS_URL = @"http://designprojectsapps.com/iphonebanners.php";
NSString *const BANNERS_URL_TEST = @"http://192.168.1.4/designprojectsapps/iphonebanners.php";
// http://www.mysite.com/iphonebanners.php?user=<UUU>&pass=<PPP>&group=<XXX>

NSString *const CATEGORIES_URL = @"http://designprojectsapps.com/iphonecategory.php";
NSString *const CATEGORIES_URL_TEST = @"http://192.168.1.4/designprojectsapps/iphonecategory.php";
// http://www.mysite.com/iphonecategory.php?user=<UUU>&pass=<PPP>&lang=<XXX>&parentid=<YYY>&devicetype=<DDD>

NSString *const ARTICLES_URL = @"http://designprojectsapps.com/iphonenews.php";
NSString *const ARTICLES_URL_TEST = @"http://192.168.1.4/designprojectsapps/iphonearticles.php";
// http://www.mysite.com/iphonenews.php?user=<UUU>&pass=<PPP>&lang=<XXX>&cid=<YYY>&count=<WWW>&from=<ZZZ>

NSString *const HOUSE_OVERVIEW_URL = @"http://designprojectsapps.com/iphonehouseoverview.php";
NSString *const HOUSE_OVERVIEW_URL_TEST = @"http://192.168.1.4/designprojectsapps/iphonehouseoverview.php";
// http://www.mysite.com/iphonehouseoverview.php?user=<UUU>&pass=<PPP>&lang=<XXX>&cid=<YYY>


// nav bar buttons and items
NSString *const NAVBAR_BACK_IMG = @"Navbar/back.png"; //@"Navbar/back_arrow.png";
NSString *const NAVBAR_BACK_SEL_IMG = @"Navbar/back_roll.png"; //@"Navbar/back_arrow_rol.png";

NSString *const NAVBAR_LOGO_IMG_FMT = @"Navbar/logo_%@.png";

NSString *const NAVBAR_LANG_EN_IMG = @"Navbar/lang_en.png";
NSString *const NAVBAR_LANG_EN_SEL_IMG = @"Navbar/lang_en_roll.png";

NSString *const NAVBAR_LANG_EL_IMG = @"Navbar/lang_el.png";
NSString *const NAVBAR_LANG_EL_SEL_IMG = @"Navbar/lang_el_roll.png";

NSString *const NAVBAR_FAV_IMG = @"Navbar/fav.png";
NSString *const NAVBAR_FAV_SEL_IMG = @"Navbar/fav_roll.png";

NSString *const NAVBAR_SHARE_IMG = @"Navbar/share.png";
NSString *const NAVBAR_SHARE_SEL_IMG = @"Navbar/share_roll.png";

NSString *const NAVBAR_NEXT_IMG = @"Navbar/arrow_next.png";
NSString *const NAVBAR_NEXT_SEL_IMG = @"Navbar/arrow_next_roll.png";

NSString *const NAVBAR_PREV_IMG = @"Navbar/arrow_prev.png";
NSString *const NAVBAR_PREV_SEL_IMG = @"Navbar/arrow_prev_roll.png";

//NSString *const NAVBAR_PREVNEXT_BORDER_IMG = @"Navbar/prev_next_border.png";

NSString *const NAVBAR_INFO_IMG = @"Navbar/info-big_03.png";


// localization keys
NSString *const kbtnOK_Title = @"btnOK_Title";

NSString *const ktbiMain_Title = @"tbiMain_Title";
NSString *const ktbiIdea_Title = @"tbiIdea_Title";
NSString *const ktbiRealEstate_Title = @"tbiRealEstate_Title";
NSString *const ktbiCall_Title = @"tbiCall_Title";
NSString *const ktbiMore_Title = @"tbiMore_Title";

NSString *const ktbiWho_Title = @"tbiWho_Title";
NSString *const ktbiFranchise_Title = @"tbiFranchise_Title";
NSString *const ktbiCost_Title = @"tbiCost_Title";
NSString *const ktbiProfit_Title = @"tbiProfit_Title";
NSString *const ktbiMaterials_Title = @"tbiMaterials_Title";
NSString *const ktbiPlanet_Title = @"tbiPlanet_Title";
NSString *const ktbiFavorites_Title = @"tbiFavorites_Title";



NSString *const kbbiMore_Title = @"bbiMore_Title";
NSString *const kbbiMoreBack_Title = @"bbiMoreBack_Title";

NSString *const kbbiBuy_Title = @"bbiBuy_Title";

NSString *const kMENU_TITLE_Fmt = @"MENU_TITLE_%i";

NSString *const kIMAGE_RESET_MENU = @"IMAGE_RESET_MENU";

NSString *const kERR_TITLE_ERROR = @"ERR_TITLE_ERROR";
NSString *const kERR_TITLE_WARNING = @"ERR_TITLE_WARNING";

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

NSString* SHA1Digest(NSString* input)
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

NSString* getDocumentsFilePath(NSString* filename) {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:filename];
    
    return filePath;
}


CGPoint calcBoundsCenterOfView(UIView *view) {
    CGPoint cntr = view.center;
    cntr.x -= view.frame.origin.x;
    cntr.y -= view.frame.origin.y;
    return cntr;
}

UIActivityIndicatorView* makeIndicatorForView(UIView *container) {
    UIActivityIndicatorView *busyIndicator = [[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    busyIndicator.frame = CGRectMake(0, 0,
                                     busyIndicator.frame.size.width,
                                     busyIndicator.frame.size.height);
    busyIndicator.hidesWhenStopped = TRUE;
    
    busyIndicator.center = calcBoundsCenterOfView(container);
    [container addSubview:busyIndicator];
    [busyIndicator startAnimating];
    
    return busyIndicator;
}


UIView* createImageViewLoadingSizedWithIndicator(CGRect vFrame, CGSize loadingImgMaxSize,
                                                 BOOL addIndicator, BOOL startIndicator)  {
    addIndicator = NO; startIndicator = NO;
    
    UIImage *img = [UIImage imageNamed:@"loading.png"];
    CGFloat coeff = /*addIndicator ? 0.5f :*/ 0.8f;
    CGSize maxSize = CGSizeMake(vFrame.size.width * coeff,
                                vFrame.size.height * coeff);
    maxSize = CGSizeMake(MIN(maxSize.width, loadingImgMaxSize.width),
                         MIN(maxSize.height, loadingImgMaxSize.height));
    if (img.size.width > maxSize.width || img.size.height > maxSize.height) {
        img = [img imageScaledToFitSize:maxSize];
    }
    
    CGRect frm = CGRectMake(0.0f, 0.0f,
                            maxSize.width,
                            maxSize.height);
    frm = CGRectOffset(frm,
                       (vFrame.size.width - frm.size.width) / 2.0f,
                       (vFrame.size.height - frm.size.height) / 2.0f);
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:frm];
    iv.contentMode = UIViewContentModeCenter;
    iv.image = img;
    
    UIView *v = [[UIView alloc] initWithFrame:vFrame];
    v.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    v.layer.cornerRadius = IS_IPAD ? 8.0f : 4.0f;
    v.layer.borderWidth = IS_IPAD ? 2.0f : 2.0f;
    v.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.75f].CGColor;
    
    [v addSubview:iv];
    
    if (addIndicator) {
        frm = v.bounds;
        UIActivityIndicatorView *bi = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle: IS_IPAD ? UIActivityIndicatorViewStyleWhiteLarge: UIActivityIndicatorViewStyleWhite];
        bi.center = v.center;
        bi.hidesWhenStopped = YES;
        [v addSubview:bi];
        if (startIndicator)
            [bi startAnimating];
    }
    
    return v;
}

UIView* createImageViewLoadingSized(CGRect vFrame, CGSize loadingImgMaxSize) {
    CGSize maxSize = CGSizeMake(LOADING_IMG_MAX_WIDTH, LOADING_IMG_MAX_HEIGHT);
    
    return createImageViewLoadingSizedWithIndicator(vFrame, maxSize, NO, NO);
}

UIView* createImageViewLoading(CGRect vFrame, BOOL addIndicator, BOOL startIndicator)  {
    CGSize maxSize = CGSizeMake(LOADING_IMG_MAX_WIDTH, LOADING_IMG_MAX_HEIGHT);

    return createImageViewLoadingSizedWithIndicator(vFrame, maxSize, addIndicator, startIndicator);
}

void removeSubViews(UIView *v) {
    for (UIView *sv in v.subviews) {
        releaseSubViews(sv);
        [sv removeFromSuperview];
    }
}

void releaseSubViews(UIView *v) {
    for (UIView *sv in v.subviews) {
        releaseSubViews(sv);
        
        if ([sv isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *aiv = (UIActivityIndicatorView *)sv;
            [aiv stopAnimating];
            int cntr = 20;
            while (aiv.isAnimating && cntr>=0) {
                [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                cntr--;
            }
        } else
            [sv removeFromSuperview];
    }
}

void fixActivityIndicators(UIView *v, BOOL start) {
    for (UIView *sv in v.subviews) {
        fixActivityIndicators(sv, start);
        
        if ([sv isKindOfClass:[UIActivityIndicatorView class]]) {
            if (start)
                [((UIActivityIndicatorView *)sv) stopAnimating];
            else
                [((UIActivityIndicatorView *)sv) stopAnimating];
        }
    }
}

void startActivityIndicators(UIView *v) {
    fixActivityIndicators(v, YES);
}

void stopActivityIndicators(UIView *v) {
    fixActivityIndicators(v, NO);
}

