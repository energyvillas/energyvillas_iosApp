//
//  DPMenuViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/5/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "FPPopoverController.h"

@interface DPMenuViewController : DPScrollableViewController <DPScrollableViewDelegate, DPScrollableDataSourceDelegate, FPPopoverControllerDelegate>

@property (nonatomic, readonly, getter = getCurrentMenuPage) int currentMenuPage;

- (id) initWithRows:(int)rows
            columns:(int)columns
         autoScroll:(BOOL)autoscroll
          showPages:(BOOL)showpages
    scrollDirection:(DPScrollDirection)scrolldir
          menulevel:(int)level
        initialPage:(int)initialPage;


@end
