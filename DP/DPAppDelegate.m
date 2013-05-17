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

@implementation DPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DPIAPHelper sharedInstance];//loadStore];
    
    [DPAppHelper sharedInstance].currentLang = @"en"; //[[NSLocale preferredLanguages] objectAtIndex:0];//@"el";
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    if (IS_APP_PURCHASED)
        self.controller = [[DPPaidMainViewController alloc] init];
    else
        self.controller = [[DPMainViewController alloc] init];
    
    self.window.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = self.controller;
    
    [self.window makeKeyAndVisible];

    NSSetUncaughtExceptionHandler (&myExceptionHandler);

    [self hookToNotifications];
    
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

//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}
// FBSample logic
// It is important to close any FBSession object that is no longer useful
- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[FBSession activeSession] close];
}



@end
