//
//  DPMailHelper.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMailHelper.h"

@interface DPMailHelper ()  

@end

@implementation DPMailHelper

+(MFMailComposeViewController *) composeEmail {
    NSString *bodyfmt = @"-----<br/>Sent from the energyVillas App for iPhone<br/>-----<br/><br/>Hey, check this out :<br/>%@<br/>%@";
    
    NSString *mailSubject = [NSString stringWithFormat:@"energyVillas - %@", @"subject"];//[self getCurrentArticle].articleTitle];
	NSString *mailBody = [NSString stringWithFormat:bodyfmt, @"", @"" ];// [self getCurrentArticle].articleTitle, [self getCurrentArticle].articleURL];
	
	MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
//	mailComposer.mailComposeDelegate = delegate;
	[mailComposer setSubject:mailSubject];
	[mailComposer setMessageBody:mailBody isHTML:TRUE];
//	[fromController presentModalViewController:mailComposer animated:YES];
    
    return mailComposer;
}

@end
