//
//  DPSocialManager.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "DPSocialManager.h"
#import "DPSocialViewController.h"
#import "DPConstants.h"
#import "DPFacebookViewController.h"
#import <Twitter/Twitter.h>
#import "DPMailHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DPAppDelegate.h"
#import "DPAppHelper.h"
#import "DPFavoritesViewController.h"

@interface DPSocialManager ()

@property (strong, nonatomic) DPSocialViewController *socialController;
@property (weak, nonatomic) UIViewController *controller;
@property (strong) void (^onSocialClosed)(void);
@property (strong) void (^onCompleted)(int socialAction);

@end

@implementation DPSocialManager

-(id) initWithController:(UIViewController *)controller
          onSocialClosed:(void(^)(void))onSocialClosed {
    self = [super init];
    if (self) {
        self.controller = controller;
        self.onSocialClosed = onSocialClosed;
    }
    return self;
}

//==============================================================================
#pragma mark - Dialog handling

-(BOOL) getIsShowing {
    return (self.socialController != nil);
}

- (void) hideSocialsDialog {
    if (self.socialController) {
        [self.controller.navigationController dismissViewControllerAnimated:NO completion:nil];
        self.controller.view.userInteractionEnabled = YES;
        self.socialController = nil;
    }
}


- (void) showSocialsDialog:(void(^)(int socialAction))completed {
    AudioServicesPlaySystemSound(0x528);
    self.onCompleted = completed;
    if (IS_IPAD)
        [self showSocialsDialog_iPads];
    else
        [self showSocialsDialog_iPhones];
}

//==============================================================================

- (void) showSocialsDialog_iPads {
    self.socialController = [[DPSocialViewController alloc]
                             initWithCompletion:^(int indx){
                                 self.controller.view.userInteractionEnabled = YES;
                                 self.socialController = nil;
                                 
//                                 if (self.onCompleted)
//                                     self.onCompleted(indx);
                                 if (indx == -1)
                                     ;//[self showSocialsDialog];
                                 else if (indx > 0)
                                    [self launchSocialAction:indx];
                             }];
    
    self.controller.view.userInteractionEnabled = NO;
    self.socialController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.controller.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.controller.navigationController presentViewController:self.socialController animated:YES completion:nil];
    
    CGRect svfrm = [self.socialController calcFrame];
    self.socialController.view.superview.backgroundColor = [UIColor clearColor];
    if (IS_PORTRAIT)
        self.socialController.view.superview.frame = svfrm;
    else
        self.socialController.view.superview.frame = svfrm;
}

//==============================================================================

- (void) showSocialsDialog_iPhones {
    id del = self.controller.navigationController.delegate;
    UIViewController *main = del;
    
    self.socialController = [[DPSocialViewController alloc]
                                  initWithCompletion:^(int indx){
                                      self.controller.view.userInteractionEnabled = YES;
                                      self.socialController = nil;
                                      
//                                      if (self.onCompleted)
//                                          self.onCompleted(indx);
                                      if (indx == -1)
                                          ;//[self showSocialsDialog:self.onCompleted];
                                      else if (indx > 0)
                                          [self launchSocialAction:indx];
                                  }];
    
    self.controller.view.userInteractionEnabled = NO;
    
    [main addChildViewController:self.socialController];
    [main.view addSubview:self.socialController.view];
}

//==============================================================================

-(void) launchSocialAction:(int) action {
    [self hideSocialsDialog];
    
    switch (action) {
        case SOCIAL_ACT_FACEBOOK: {
            [self showFB];
            break;
        }
        case SOCIAL_ACT_TWITTER:
            [self tweet:[DPAppHelper sharedInstance].imageUrl2Share url:[DPAppHelper sharedInstance].imageUrl2Share];
            break;
            
        case SOCIAL_ACT_LINKEDIN:
            
            break;
            
        case SOCIAL_ACT_EMAIL:
            
            [self composeEmail];
            break;
            
        case SOCIAL_ACT_FAVS: {
            if ([[[DPAppHelper sharedInstance] favoriteArticles] count] > 0) {
                DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
                UINavigationController *nvc = [appdel findNavController];
                DPFavoritesViewController *favs = [[DPFavoritesViewController alloc] init];
                [nvc pushViewController:favs animated:YES];
            }
            break;
        }
        case SOCIAL_ACT_OTHER:
            
            break;
            
        default:
            break;
    }
}

//==============================================================================
#pragma mark - Facebook
- (void) showFB {
    DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;

//    FBSessionState status = FBSession.activeSession.state;
//    if (/*status == FBSessionStateCreated || */status == FBSessionStateCreatedTokenLoaded) {
    if (FBSession.activeSession.isOpen) {
        [appdel showFBView];
    } else {
        DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
        [appdel openFBSession];
//        [appdel showFBLogin];
    }
}

//==============================================================================
#pragma mark - eMail

-(void) composeEmail {
    if (![MFMailComposeViewController canSendMail]){
        showAlertMessage(nil, kERR_TITLE_INFO, kERR_MSG_TRY_LATER); // pending::new message for missing mail setup
        return;
    }
    
    /*
     {
     MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
     controller.mailComposeDelegate = self;
     [controller setToRecipients:[NSArray arrayWithObject:eMail]];
     [self presentViewController:controller animated:YES completion:nil];
     }
     else
     */
    
    MFMailComposeViewController *composer = [DPMailHelper composeEmail];
    composer.mailComposeDelegate = self;
    if (!IS_IPAD)
        [self.controller.navigationController presentModalViewController:composer
                                                                animated:YES];
    else {
//        composer.modalPresentationStyle = UIModalPresentationPageSheet;
        self.controller.navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self.controller.navigationController presentModalViewController:composer
                                                                          animated:YES];
//                                                         completion:nil];
    }
    
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void) mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
	[controller dismissModalViewControllerAnimated:YES];
    
    if (self.onSocialClosed)
        self.onSocialClosed();
}

//==============================================================================
#pragma mark - Twitter

- (void) tweet:(NSString *)imgUrl url:(NSString *)urlstr {
    if (![TWTweetComposeViewController canSendTweet]) {
        showAlertMessage(nil, kERR_TITLE_INFO, @"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"); // pending::new message for missing twitter setup
        return;
    }
    //    if (![TWTweetComposeViewController canSendTweet])
    //    {
    //        UIAlertView *alertView = [[UIAlertView alloc]
    //                                  initWithTitle:@"Sorry"
    //                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
    //                                  delegate:self
    //                                  cancelButtonTitle:@"OK"
    //                                  otherButtonTitles:nil];
    //        [alertView show];
    //
    //        return;
    //    }
    
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    [tweetSheet setInitialText: @"Tweeting from energyVillas! :)"];
    BOOL added = NO;
//    if (imgUrl) {
//        UIImage *img = [UIImage imageNamed:imgUrl];
//        if (img)
//            added = [tweetSheet addImage:img];
//    }
    
    if (urlstr) {
        NSURL *url = [NSURL URLWithString:urlstr];
        if (url)
            added = [tweetSheet addURL:url];
    }
    
    [self.controller presentModalViewController:tweetSheet animated:YES];
}

@end
