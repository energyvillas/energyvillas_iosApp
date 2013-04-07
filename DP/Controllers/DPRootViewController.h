//
//  DPRootViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "AFOpenFlowView.h"

@interface DPRootViewController : UINavContentViewController
    <AFOpenFlowViewDataSource, AFOpenFlowViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *toolbarBackView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiMore;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiBuy;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@end
