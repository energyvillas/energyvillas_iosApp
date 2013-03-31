//
//  DPCtgScrollViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"

@interface DPCtgScrollViewController : DPScrollableViewController

- (id) initWithContent:(NSArray *)content
                  rows:(int)rows
               columns:(int)columns
            autoScroll:(BOOL)autoscroll;

@end
