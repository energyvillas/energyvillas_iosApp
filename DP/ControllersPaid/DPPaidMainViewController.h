//
//  DPPaidMainViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "FPPopoverController.h"
#import "DPMoreMenuViewController.h"



@interface DPPaidMainViewController : UINavContentViewController <UITabBarDelegate, UINavigationControllerDelegate, FPPopoverControllerDelegate, DPMoreMenuHandlerDelegate>

@property (strong, nonatomic) IBOutlet UINavigationController *navController;

@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiMain;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiWho;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiBuy;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiCall;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiMore;

@end
