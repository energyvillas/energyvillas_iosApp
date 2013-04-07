//
//  DPAnimatedScrollViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/7/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "DPScrollableViewDelegate.h"
#import "DPDataLoader.h"

@interface DPAnimatedScrollViewController : DPScrollableViewController <DPDataLoaderDelegate, DPScrollableViewDelegate, DPScrollableDataSourceDelegate>

- (id) initWithCategory:(int)ctgID isLeaf:(BOOL)isLeaf;

@end
