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
#import "UIApplication+ScreenDimensions.h"

//==============================================================================

@interface DPModalDialogManager ()

@end

//==============================================================================

@implementation DPModalDialogManager

- (id) initWithController:(UIViewController *)controller {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc {
    self.modalController = nil;
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

- (UIViewController *) findTabController {
	DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
	return [appdel window].rootViewController;
}

- (void) showDialog_iPads {
	UIViewController *nc = [self findTabController];

	if (Is_iOS_Version_LessThan(@"8.0")) {
		self.modalController.modalPresentationStyle = UIModalPresentationPageSheet;
		nc.definesPresentationContext = YES;
	} else
	{
//		// ios 8
		nc.providesPresentationContextTransitionStyle = YES;
		nc.definesPresentationContext = YES;
		self.modalController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	}
	
	[nc presentViewController:self.modalController
                     animated:YES
                   completion:nil];
    
	self.modalController.view.superview.backgroundColor = [UIColor clearColor];
	if (Is_iOS_Version_LessThan(@"8.0")) {
		self.modalController.view.superview.backgroundColor = [UIColor clearColor];
	}
}

//==============================================================================

- (void) showDialog_iPhones {
	UIViewController* main =[self findTabController];

    [main addChildViewController:self.modalController];
    [main.view addSubview:self.modalController.view];
}

@end
