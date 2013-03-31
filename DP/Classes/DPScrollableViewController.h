//
//  DPScrollableDetailViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPScrollableViewDelegate.h"

@interface DPScrollableViewController : UINavContentViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *contentList;

@property (nonatomic) int rowCount;
@property (nonatomic) int colCount;

@property (nonatomic, weak) id <DPScrollableViewDelegate> viewDelegate;


- (id) initWithContent:(NSArray *)content autoScroll:(BOOL)autoscroll;
- (void) changeRows:(int)rows columns:(int)columns;

@end
