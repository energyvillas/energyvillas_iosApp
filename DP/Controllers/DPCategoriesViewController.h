//
//  DPCategoriesViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/6/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCtgScrollViewController.h"
#import "DPDataLoader.h"

@interface DPCategoriesViewController : DPCtgScrollViewController <DPScrollableViewDelegate, DPDataLoaderDelegate>

- (id) initWithCategory:(int)ctg
                   lang:(NSString *)lang
          localResource:(NSString *)resfile
                   rows:(int)rows
                columns:(int)cols
             autoScroll:(BOOL)autoscroll;

@end
