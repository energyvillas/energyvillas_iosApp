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
#import "YTVimeoExtractor.h"


@interface DPBuyContentViewController : DPScrollableViewController //DPCtgScrollViewController
    <
    DPDataLoaderDelegate
    , DPScrollableViewDelegate
    , DPScrollableDataSourceDelegate
    , YTVimeoExtractorDelegate
    >

- (id) initWithCategory:(int)ctgID;

@end
