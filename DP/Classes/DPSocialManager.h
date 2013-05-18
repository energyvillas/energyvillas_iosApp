//
//  DPSocialManager.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>



@interface DPSocialManager : NSObject <MFMailComposeViewControllerDelegate>

//@property (weak, nonatomic) id <DPSocialManagerDelegate> socialDelegate;
@property (readonly, getter = getIsShowing) BOOL showingDialog;


-(id) initWithController:(UIViewController *)controller
          onSocialClosed:(void(^)(void))onSocialClosed;

- (void) showSocialsDialog:(void(^)(int socialAction))completed;
- (void) hideSocialsDialog;

@end
