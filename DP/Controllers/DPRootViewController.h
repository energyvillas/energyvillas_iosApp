//
//  DPRootViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>


@protocol DPBuyAppProtocol <NSObject>

-(void) showBuyDialog:(int)ctgId;

@end


@interface DPRootViewController : UINavContentViewController
    <DPBuyAppProtocol> //, DPActionDelegate , FPPopoverControllerDelegate, MFMailComposeViewControllerDelegate >

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *spacingLeft;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiFavs;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiInfo;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *spacingInfoMore;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiMore;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiBuy;

@property (strong, nonatomic) IBOutlet UIView *bottomView;

-(id) init;

@end
