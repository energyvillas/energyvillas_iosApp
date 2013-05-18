//
//  DPFBLoginViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"


@interface DPFBLoginViewController : UINavContentViewController

@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;

@property (strong, nonatomic) IBOutlet UIImageView *logoImgView;
- (IBAction)btnTouchUpInside:(id)sender;

- (void) loginFailed;

@end
