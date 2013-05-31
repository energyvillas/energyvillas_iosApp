//
//  DPCategoryViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"



@interface DPCategoryViewController : UINavContentViewController 

@property (nonatomic, readonly) int category;

@property (strong, nonatomic) IBOutlet UIView *ctgView;
@property (strong, nonatomic) IBOutlet UIView *adsView;
@property (strong, nonatomic) IBOutlet UIView *mmView;

@property (strong, nonatomic) IBOutlet UIImageView *imgTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIView *actualCtgView;

- (id) initWithCategory:(int)ctgID;

- (void) showCategory:(int)ctgID;

@end
