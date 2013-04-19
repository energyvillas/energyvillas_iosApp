//
//  DPBuyViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"

@interface DPBuyViewController : UINavContentViewController 

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (strong, nonatomic) IBOutlet UIImageView *toolbar;
@property (strong, nonatomic) IBOutlet UIButton *btnBuy;
@property (strong, nonatomic) IBOutlet UIButton *btnRestore;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;

@property (readonly) int category;

- (IBAction)onTouchUpInside:(id)sender forEvent:(UIEvent *)event;



- (id) initWithCategoryId:(int)ctgid completion:(void (^)(void))completion;

-(CGRect) calcFrame;

@end
