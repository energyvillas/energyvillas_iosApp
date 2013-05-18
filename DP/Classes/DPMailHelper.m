//
//  DPMailHelper.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMailHelper.h"
#import "DPAppHelper.h"

@interface DPMailHelper ()  

@end

@implementation DPMailHelper

+(MFMailComposeViewController *) composeEmail {
    NSString *bodyfmt = @"-----<br/>Sent from the energyVillas App for iPhone<br/>-----<br/><br/>Hey, check this out :<br/><img src=\"%@\" alt=\"\" width=\"100\" height=\"100\" /><br/>%@";
    
    NSString *mailSubject = [NSString stringWithFormat:@"energyVillas - %@", @"subject"];
	NSString *mailBody = [NSString stringWithFormat:bodyfmt,
                          [DPAppHelper sharedInstance].imageUrl2Share, @"" ];// [self getCurrentArticle].articleTitle, [self getCurrentArticle].articleURL];
	
	MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
//	mailComposer.mailComposeDelegate = delegate;
	[mailComposer setSubject:mailSubject];
	[mailComposer setMessageBody:mailBody isHTML:TRUE];
    
    return mailComposer;
}

@end
