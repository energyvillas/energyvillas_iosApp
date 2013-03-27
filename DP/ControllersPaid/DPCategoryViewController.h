//
//  DPCategoryViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"

@interface DPCategoryViewController : UINavContentViewController

@property (strong, nonatomic) IBOutlet UIView *ctgView;
@property (strong, nonatomic) IBOutlet UIView *adsView;
@property (strong, nonatomic) IBOutlet UIView *mmView;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

- (id) initWithCategory:(int)ctgID;

@end