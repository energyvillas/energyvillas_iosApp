//
//  DPNewNextViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"
#import "DPDataLoader.h"

@interface DPNewNextViewController : UINavContentViewController <DPDataLoaderDelegate>

-(void) refresh;
@end
