//
//  DPModalDialogManager.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol DPModalControllerProtocol <NSObject>

- (CGRect) calcFrame;
- (void) setCompletion:(void (^)(int tag))completion;

@end



@interface DPModalDialogManager : NSObject

@property (strong, nonatomic) UIViewController<DPModalControllerProtocol> *modalController;

- (id) initWithController:(UIViewController *)controller;

- (void) showDialog:(UIViewController<DPModalControllerProtocol> *)aModalController;

@end

