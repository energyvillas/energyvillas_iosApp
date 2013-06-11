//
//  DPModalDialogManager.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPModalDialogManager.h"
#import "DPAppHelper.h"
#import "DPConstants.h"
#import "DPAppDelegate.h"

//==============================================================================

@interface DPModalDialogManager ()

@property (weak, nonatomic) UIViewController *controller;

@end

//==============================================================================

@implementation DPModalDialogManager

- (id) initWithController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        self.controller = controller;
    }
    return self;
}

- (void) showDialog:(UIViewController<DPModalControllerProtocol> *)aModalController {
    [[DPAppHelper sharedInstance] playSoundBloodSplatOnWall];
    self.modalController = aModalController;
    if (IS_IPAD)
        [self showDialog_iPads];
    else
        [self showDialog_iPhones];

}

//==============================================================================
- (UINavigationController *) findNavController {
    DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
    return [appdel findNavController];
}
- (void) showDialog_iPads {
    self.controller.view.userInteractionEnabled = NO;
    self.modalController.modalPresentationStyle = UIModalPresentationFormSheet;
    UINavigationController *nc = [self findNavController];

    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    [nc presentViewController:self.modalController
                     animated:YES
                   completion:^{
//                       CGRect svfrm = [self.modalController calcFrame];
//                       self.modalController.view.superview.backgroundColor = [UIColor clearColor];
//                       self.modalController.view.superview.frame = svfrm;
                   }];
    
    CGRect svfrm = [self.modalController calcFrame];
    self.modalController.view.superview.backgroundColor = [UIColor clearColor];
    self.modalController.view.superview.frame = svfrm;
}

//==============================================================================

- (void) showDialog_iPhones {
//    UINavigationController *nc = [self findNavController];
//    id del = nc.delegate;
//    UIViewController *main = del;
    DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
    UIViewController *main = appdel.controller;
    
    self.controller.view.userInteractionEnabled = NO;
    
    [main addChildViewController:self.modalController];
    [main.view addSubview:self.modalController.view];
}

@end
