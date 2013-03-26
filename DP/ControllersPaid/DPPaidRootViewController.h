//
//  DPPaidRootViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "../Classes/DPScrollableViewDelegate.h"

@interface DPPaidRootViewController : UINavContentViewController <DPScrollableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *adsView;
@property (strong, nonatomic) IBOutlet UIView *nnView;
@property (strong, nonatomic) IBOutlet UIView *mmView;

@end
