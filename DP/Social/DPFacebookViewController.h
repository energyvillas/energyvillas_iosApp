//
//  DPFacebookViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DPFacebookViewController : UINavContentViewController <UITextViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UITextView *postMessageTextView;

- (IBAction)toolBarItemTapped:(UIBarButtonItem *)sender;
@end
