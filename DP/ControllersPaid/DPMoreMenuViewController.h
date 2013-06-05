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

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIButton *btnWho;
@property (strong, nonatomic) IBOutlet UIButton *btnFranchise;
@property (strong, nonatomic) IBOutlet UIButton *btnCost;
@property (strong, nonatomic) IBOutlet UIButton *btnProfit;
@property (strong, nonatomic) IBOutlet UIButton *btnMaterial;
@property (strong, nonatomic) IBOutlet UIButton *btnPlanet;
@property (strong, nonatomic) IBOutlet UIButton *btnFavs;

@property (weak, nonatomic) id<DPMoreMenuHandlerDelegate> menuDelegate;

- (IBAction)btnTouchUpInside:(id)sender;

- (CGSize) calcViewSize;
- (CGPoint) calcOriginInFrame:(CGRect)frm;

@end
