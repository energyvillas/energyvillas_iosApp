//
//  UINavContentViewController.h
//  testSV
//
//  Created by george on 16/3/13.
//  Copyright (c) 2013 george. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol ViewRotationDelegate;

@interface UINavContentViewController : UIViewController

//@property (weak, nonatomic) id <ViewRotationDelegate> rotationDelegate;

//- (void) doLayoutForOrientation:(UIInterfaceOrientation) toOrientation;
- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation;

@end

/*
@protocol ViewRotationDelegate <NSObject>
@optional
- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation;

@end
*/
