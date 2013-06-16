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
    NSString *bodyfmt = DPLocalizedString(kEMAIL_BODY_FMT);
    
    NSString *mailSubject = DPLocalizedString(kEMAIL_SUBJECT);
    NSString *device = IS_IPAD ? @"iPad" : @"iPhone";
    NSString *evurl = [CURRENT_LANG isEqualToString:@"el"] ? @"http://www.energeiakikatoikia.gr" : @"http://www.energyvillas.com";
    NSString *imgname = [DPAppHelper sharedInstance].imageUrl2Share;
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
    
	NSString *mailBody = [NSString stringWithFormat:bodyfmt, device, imgname, imgname, sz.width, sz.height, evurl];
	
	MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
	[mailComposer setSubject:mailSubject];
	[mailComposer setMessageBody:mailBody isHTML:TRUE];
    
    return mailComposer;
}

@end
