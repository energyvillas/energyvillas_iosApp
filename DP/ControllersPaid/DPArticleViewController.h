//
//  DPArticleViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "DPDataLoader.h"
#import "DPScrollableViewDelegate.h"

@interface DPArticleViewController : DPScrollableViewController
        <
        DPDataLoaderDelegate
        , DPScrollableViewDelegate
        , DPScrollableDataSourceDelegate
        >

- (id) initWithCategory:(int)ctgID;

@end
