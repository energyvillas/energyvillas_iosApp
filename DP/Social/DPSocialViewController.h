//
//  DPSocialViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"

@interface DPSocialViewController : UINavContentViewController

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;

@property (strong, nonatomic) IBOutlet UIView *facebookView;
@property (strong, nonatomic) IBOutlet UIView *twitterView;
@property (strong, nonatomic) IBOutlet UIView *linkedinView;
@property (strong, nonatomic) IBOutlet UIView *emailView;
@property (strong, nonatomic) IBOutlet UIView *favsView;
@property (strong, nonatomic) IBOutlet UIView *otherView;

- (IBAction)socialBtnTapped:(id)sender;

- (id) initWithCompletion:(void (^)(int tag))completion;

-(CGRect) calcFrame;

@end
