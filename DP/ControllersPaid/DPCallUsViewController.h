//
//  DPCallUsViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPModalDialogManager.h"

@interface DPCallUsViewController : UINavContentViewController<DPModalControllerProtocol>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *btnCall;
@property (strong, nonatomic) IBOutlet UIButton *btnMail;

@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)btnTouchupInside:(UIButton *)sender;

// protocol methods
- (void) setCompletion:(void (^)(int tag))completion;

@end
