//
//  DPAdsViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "DPDataLoader.h"

@interface DPAdsViewController : DPScrollableViewController <DPDataLoaderDelegate>

- (id) initWithGroup:(int)aGroup;

@end
