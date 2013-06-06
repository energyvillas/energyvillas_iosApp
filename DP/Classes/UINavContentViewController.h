//
//  UINavContentViewController.h
//  testSV
//
//  Created by george on 16/3/13.
//  Copyright (c) 2013 george. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPActionDelegate <NSObject>

- (void) onTapped:(id)sender;

@end

@protocol DPNavigatorDelegate <NSObject>

- (void) next;
- (void) prev;
- (int) currentItemIndex;
- (int) itemsCount;

@end



@interface UINavContentViewController : UIViewController

@property (weak, nonatomic) id<DPNavigatorDelegate> navigatorDelegate;
@property (weak, nonatomic) id <DPActionDelegate> actionDelegate;

- (void) doLayoutSubViews:(BOOL)fixtop;
- (void) doLocalize;
- (void) reachabilityChanged;
- (void) fixFavsButton;

// protected virtual
- (BOOL) showNavBar;
- (BOOL) showNavBarLanguages;
- (BOOL) showNavBarAddToFav;
- (BOOL) showNavBarSocial;
- (BOOL) showNavBarInfo;
- (BOOL) showNavBarNavigator;

@end
