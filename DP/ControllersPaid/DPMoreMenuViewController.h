//
//  DPMoreMenuViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPMoreMenuHandlerDelegate <NSObject>

- (void) menuItemSelected:(int)menuTag;

@end


@interface DPMoreMenuViewController : UIViewController

@property (weak, nonatomic) id<DPMoreMenuHandlerDelegate> menuDelegate;

- (IBAction)btnTouchUpInside:(id)sender;

@end
