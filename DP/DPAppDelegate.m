//
//  DPAppDelegate.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "DPAppDelegate.h"
#import "Classes/DPIAPHelper.h"
#import "Controllers/DPMainViewController.h"
#import "ControllersPaid/DPPaidMainViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "UIImage+Retina4.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Reachability.h"
#import "DPFBLoginViewController.h"
#import "DPFacebookViewController.h"

@implementation DPAppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DPIAPHelper sharedInstance];//loadStore];
    
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ( (![lang isEqualToString:@"en"]) && (![lang isEqualToString:@"el"]) )
        lang = @"en";
    
    [DPAppHelper sharedInstance].currentLang = lang;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    if (IS_APP_PURCHASED)
        self.controller =  [[DPPaidMainViewController alloc] init]; 
    else
        self.controller = [[DPMainViewController alloc] init];
    
    self.window.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = self.controller;
    
    [self.window makeKeyAndVisible];

    NSSetUncaughtExceptionHandler (&myExceptionHandler);

    [self hookToNotifications];
    
    if (!IS_APP_PURCHASED)
        if ([DPAppHelper sharedInstance].hostIsReachable)
            [DPIAPHelper loadStore];

    return YES;
}

void myExceptionHandler (NSException *exception)
{
    NSArray *stack = [exception callStackReturnAddresses];
    NSLog(@"Stack trace: %@", stack);
}

- (void) hookToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:DPN_ShowFacebookViewNotification
                                               object:nil];
}

- (void) onNotified:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:IAPHelperProductPurchasedNotification]) {
        NSLog (@"Successfully received the ==IAPHelperProductPurchasedNotification== notification!");
        if (IS_APP_PURCHASED) {
            NSLog(@"=====##### SWITCHING INTERFACES #####=====");
            self.controller = [[DPPaidMainViewController alloc] init];
            self.window.rootViewController = self.controller;
        }
    }
    
    if ([[notification name] isEqualToString:kReachabilityChangedNotification]) {
        NSLog (@"Successfully received the ==kReachabilityChangedNotification== notification!");
        
        if (!IS_APP_PURCHASED)
            if ([DPAppHelper sharedInstance].hostIsReachable)
                [DPIAPHelper loadStore];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[DPAppHelper sharedInstance] saveFavorites];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [[FBSession activeSession] handleOpenURL:url];
}

// It is important to close any FBSession object that is no longer useful
- (void)applicationWillTerminate:(UIApplication *)application {
    [[DPAppHelper sharedInstance] saveFavorites];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[FBSession activeSession] close];
}

- (void) fbSessionStateChanged:(FBSession *)session
                         state:(FBSessionState)state
                         error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            UIViewController *topVC = [[self findNavController] topViewController];
            if ([topVC.modalViewController isKindOfClass:[DPFBLoginViewController class]]) {
                [topVC dismissModalViewControllerAnimated:NO];
            }

            [self showFBView];
        }
            break;
            
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            [FBSession.activeSession closeAndClearTokenInformation];
//            [self showFBLogin];
        }
            break;
            
        default:
            break;
    }
    
    if (error) {
        showAlertMessage(nil, DPLocalizedString(kERR_TITLE_ERROR), error.localizedDescription);
    }
}

- (void) openFBSession {
    NSArray *permissions = [NSArray arrayWithObjects:@"user_photos",
                            nil];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      [self fbSessionStateChanged:session state:status error:error];
                                  }];
}

- (void) showFBLogin {
    UINavigationController *nvc = [self findNavController];
    UIViewController *topVC = [nvc topViewController];
    UIViewController *modalVC = topVC.modalViewController;
    
    DPFBLoginViewController *fbloginVC = nil;
    if (![modalVC isKindOfClass:[DPFBLoginViewController class]]) {
        fbloginVC = [[DPFBLoginViewController alloc] init];
        [topVC presentModalViewController:fbloginVC animated:NO];
    } else {
        fbloginVC = (DPFBLoginViewController *)modalVC;
        [fbloginVC loginFailed];
    }
}

- (void) showFBView {
    [self showFBFeedDlg];
//    [self doShowFBView];
}
- (void) doShowFBView {
    UINavigationController *nvc = [self findNavController];
    DPFacebookViewController *facebook = [[DPFacebookViewController alloc] init];
    [nvc pushViewController:facebook animated:YES];
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (void) showFBFeedDlg {
    // Put together the dialog parameters
    NSString *name = NilIfEmpty(DPLocalizedString(kFACEBOOK_LINK_TEXT));
    NSString *link = ([CURRENT_LANG isEqualToString:@"el"]
                      ? @"http://www.energeiakikatoikia.gr"
                      : @"http://www.energyvillas.com");
    NSString *tmp = [DPAppHelper sharedInstance].imageUrl2Share;
    NSString *picUrl = NilIfEmpty(tmp);
    tmp = [DPAppHelper sharedInstance].imageTitle2Share;
    NSString *caption = NilIfEmpty(tmp);
    NSString *descr = NilIfEmpty(DPLocalizedString(kFACEBOOK_DESCR));
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name != nil) params[@"name"] = name;
    if (link != nil) params[@"link"] = link;
    if (picUrl != nil) params[@"picture"] = picUrl;
    if (caption != nil) params[@"caption"] = caption;
    if (descr != nil) params[@"description"] = descr;
    
    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             } else {
                 // Handle the publish feed callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // User clicked the Share button
                     NSString *msg = [NSString stringWithFormat:
                                      DPLocalizedString(kFACEBOOK_RESULT_FMT),
                                      [urlParams valueForKey:@"post_id"]];
                     NSLog(@"%@", msg);
                     // Show the result in an alert
                     [[[UIAlertView alloc] initWithTitle:DPLocalizedString(kERR_TITLE_INFO)
                                                 message:msg
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil]
                      show];
                 }
             }
         }
     }];
}

- (UINavigationController *) findNavController {
    id contr = self.controller;
    UINavigationController *result = [contr navController];
    return result;
}

@end
