//
//  UINavContentViewController.h
//  testSV
//
//  Created by george on 16/3/13.
//  Copyright (c) 2013 george. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavContentViewController : UIViewController

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation fixtop:(BOOL)fixtop;
- (void) doLocalize;
- (void) reachabilityChanged;

@end
