//
//  DPBuyContentViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/10/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "DPDataLoader.h"
#import "DPScrollableViewDelegate.h"


@interface DPBuyContentViewController : DPScrollableViewController //DPCtgScrollViewController
    <
    DPDataLoaderDelegate
    , DPScrollableViewDelegate
    , DPScrollableDataSourceDelegate
    >

- (id) initWithCategory:(int)ctgID;

@end
