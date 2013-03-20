//
//  DPRootViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "../External/OpenFlow/AFOpenFlowView.h"

@interface DPRootViewController : UINavContentViewController
    </*ViewRotationDelegate, */AFOpenFlowViewDataSource, AFOpenFlowViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *portraitView;
@property (strong, nonatomic) IBOutlet UIView *landscapeView;

@property (weak, nonatomic) IBOutlet UIView *portraitContainerView;
@property (weak, nonatomic) IBOutlet UIView *landscapecontainerView;

@end
