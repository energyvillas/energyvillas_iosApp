//
//  DPiCarouselViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 8/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"
#import "DPDataLoader.h"
#import "iCarousel.h"

@interface DPiCarouselViewController : UIViewController <DPNavigatorDelegate, DPDataLoaderDelegate, iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, readonly) int currentIndex;
@property (nonatomic, readonly) int carouselCategoryID;


-(id) initWithCtg:(int)ctgid currentIndex:(int)currIndx showSocials:(BOOL)showSocials;

-(void) makeCurrentImageAtIndex:(int)indx;
- (void) reloadData;

@end
