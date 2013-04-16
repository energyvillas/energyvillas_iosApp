//
//  DPCarouselViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/16/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"
#import "DPDataLoader.h"
#import "AFOpenFlowView.h"

@interface DPCarouselViewController : UIViewController <AFOpenFlowViewDataSource, AFOpenFlowViewDelegate, DPDataLoaderDelegate>

@property (nonatomic, readonly) int currentIndex;

-(void) makeCurrentImageAtIndex:(int)indx;

@end
