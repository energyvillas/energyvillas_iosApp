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
#import <Twitter/Twitter.h>
#import "DPMailHelper.h"
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

- (void) dealloc {
    self.socialController = nil;
    self.controller = nil;
    self.onSocialClosed = nil;
    self.onCompleted = nil;
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
    [[DPAppHelper sharedInstance] playSoundBloodSplatOnWall];
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
//    id del = self.controller.navigationController.delegate;
//    UIViewController *main = del;
    DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
    UIViewController *main = appdel.controller;
    
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
    
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    
    switch (action) {
        case SOCIAL_ACT_FACEBOOK: {
            [self showFB];
            [apphelper playSoundOpenSoda];
            break;
        }
        case SOCIAL_ACT_TWITTER: {
            [self tweet];
            [apphelper playSoundOpenSoda];
            break;
        }
        case SOCIAL_ACT_LINKEDIN:
            
            break;
            
        case SOCIAL_ACT_EMAIL: {
            [self composeEmail];
            [apphelper playSoundOpenSoda];
            break;
        }
        case SOCIAL_ACT_FAVS: {
            
            if ([[apphelper favoriteArticles] count] > 0) {
                DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
                UINavigationController *nvc = [appdel findNavController];
                DPFavoritesViewController *favs = [[DPFavoritesViewController alloc] init];
                [nvc pushViewController:favs animated:YES];
                [apphelper playSoundWoosh];
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
        showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), DPLocalizedString(kERR_MSG_UNABLE_TO_SEND_MAIL));
        return;
    }
    
    MFMailComposeViewController *composer = [DPMailHelper composeEmail];
    composer.mailComposeDelegate = self;
    if (!IS_IPAD) {
        DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
        [appdel.controller presentModalViewController:composer
                                             animated:YES];

//        [self.controller.navigationController presentModalViewController:composer
//                                                                animated:YES];
    } else {
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

- (void) tweet { //:(NSString *)imgUrl url:(NSString *)urlstr {
    if (![TWTweetComposeViewController canSendTweet]) {
        showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), DPLocalizedString(kERR_MSG_UNABLE_TO_TWEET));
        return;
    }
    
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    NSString *urlstr = ([CURRENT_LANG isEqualToString:@"el"]
                        ? @"http://www.energeiakikatoikia.gr"
                        : @"http://www.energyvillas.com");
    NSString *imgUrl = [DPAppHelper sharedInstance].imageUrl2Share;

    BOOL added = NO;
    if (imgUrl) {
        UIImage *img = [[DPAppHelper sharedInstance] loadUIImageFromCache:imgUrl];
        if (img)
            added = [tweetSheet addImage:img];
    }
    
    if (urlstr) {
        NSURL *url = [NSURL URLWithString:urlstr];
        if (url)
            added = [tweetSheet addURL:url];
    }

    added = [tweetSheet setInitialText: DPLocalizedString(kTWEET_INITIAL_TEXT)];
    
    [self.controller presentModalViewController:tweetSheet animated:YES];
}

@end
