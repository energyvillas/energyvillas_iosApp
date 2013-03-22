//
//  DPPaidRootViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"

@interface DPPaidRootViewController : UINavContentViewController <UITabBarDelegate>

@property (strong, nonatomic) IBOutlet UIView *adsView;
@property (strong, nonatomic) IBOutlet UIView *nnView;
@property (strong, nonatomic) IBOutlet UIView *mmView;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiMain;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiWho;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiBuy;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiCall;
@property (strong, nonatomic) IBOutlet UITabBarItem *tbiMore;

@end
