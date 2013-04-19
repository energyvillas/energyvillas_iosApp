//
//  DPMailHelper.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageUI/MessageUI.h"

@interface DPMailHelper : NSObject

+(MFMailComposeViewController *) composeEmail;

@end
