//
//  DPCategoriesViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/6/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "DPDataLoader.h"

@interface DPCategoriesViewController : DPScrollableViewController
        <DPScrollableViewDelegate,
        DPScrollableDataSourceDelegate,
        DPDataLoaderDelegate>

- (id) initWithCategory:(int)ctg
                   lang:(NSString *)lang
          localResource:(NSString *)resfile
                   rows:(int)rows
                columns:(int)cols
             autoScroll:(BOOL)autoscroll
                 parent:(UIViewController *)parentVC;

@end
