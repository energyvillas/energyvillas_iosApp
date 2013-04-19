//
//  DPFBLoginViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"

@protocol DPFBLoginDialogDelegate
- (void)accessTokenFound:(NSString *)accessToken;
- (void)displayRequired;
- (void)closeTapped;
@end



@interface DPFBLoginViewController : UINavContentViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;


- (id)initWithAppId:(NSString *)apiKey
requestedPermissions:(NSString *)requestedPermissions
           delegate:(id<DPFBLoginDialogDelegate>)delegate;


- (void)login;
- (void)logout;


-(void)checkForAccessToken:(NSString *)urlString;
-(void)checkLoginRequired:(NSString *)urlString;

- (IBAction)onCloseTapped:(id)sender;

@end
