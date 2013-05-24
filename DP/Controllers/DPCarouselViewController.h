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
//#import "AFOpenFlowView.h"
#import "iCarousel.h"

@interface DPCarouselViewController : UIViewController <DPNavigatorDelegate, DPDataLoaderDelegate, iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, readonly) int currentIndex;
@property (nonatomic, readonly) int carouselCategoryID;


-(id) initWithCtg:(int)ctgid;

-(void) makeCurrentImageAtIndex:(int)indx;

@end
