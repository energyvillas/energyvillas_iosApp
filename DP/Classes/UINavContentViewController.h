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


@interface UINavContentViewController : UIViewController

@property (weak, nonatomic) id <DPActionDelegate> actionDelegate;

- (void) doLayoutSubViews:(BOOL)fixtop;
- (void) doLocalize;
- (void) reachabilityChanged;

@end
