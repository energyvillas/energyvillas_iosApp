//
//  DPMailHelper.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMailHelper.h"
#import "DPAppHelper.h"
#import "DPConstants.h"

@interface DPMailHelper ()  

@end

@implementation DPMailHelper

+(MFMailComposeViewController *) composeEmail {
    NSString *mailSubject = DPLocalizedString(kEMAIL_SUBJECT);
//    NSString *device = IS_IPAD ? @"iPad" : @"iPhone";
    NSString *evurl = [CURRENT_LANG isEqualToString:@"el"] ? @"http://www.energeiakikatoikia.gr" : @"http://www.energyvillas.com";
    NSString *imgname = [DPAppHelper sharedInstance].imageUrl2Share;
    NSString *imgdescr = [DPAppHelper sharedInstance].imageTitle2Share;
    UIImage *img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgname];
    CGSize sz = img.size;
    if (sz.width > 300 || sz.height > 300) {
        CGFloat ratio = sz.width / sz.height;
        if (sz.width > sz.height) {
            sz.width = 300.0f;
            sz.height = sz.width / ratio;
        } else {
            sz.height = 300.0f;
            sz.width = sz.height * ratio;
        }
    }
    
    NSString *bodyfmt = ((imgname == nil)
                         ? DPLocalizedString(kEMAIL_BODY_NO_IMG_FMT)
                         : DPLocalizedString(kEMAIL_BODY_FMT));
    NSString *mailBody = nil;
    if (imgname == nil) {
        mailBody = [NSString stringWithFormat:bodyfmt, evurl, evurl];

	} else {
        mailBody = [NSString stringWithFormat:bodyfmt, imgname, imgdescr,
                    imgname, imgname, imgdescr, sz.width, sz.height,
                    evurl, evurl];
    }
    
    NSLog(@"%@", mailBody);
	MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
	[mailComposer setSubject:mailSubject];
	[mailComposer setMessageBody:mailBody isHTML:TRUE];
    
    return mailComposer;
}

@end
