//
//  DPAdsViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "DPDataLoader.h"

@interface DPAdsViewController : DPScrollableViewController <DPDataLoaderDelegate, DPScrollableDataSourceDelegate>

@property (nonatomic, readonly, getter = getCurrentAdPage) int currentAdPage;
@property (nonatomic, readonly) int group;

- (id) initWithGroup:(int)aGroup initialPage:(int)aInitialPage;

@end
