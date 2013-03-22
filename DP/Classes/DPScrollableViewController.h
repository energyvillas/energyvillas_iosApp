//
//  DPScrollableDetailViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"

@interface DPScrollableViewController : UINavContentViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *contentList;

@property (nonatomic) int rowCount;
@property (nonatomic) int colCount;


- (id) initWithContent:(NSArray *)content;
- (void) changeRows:(int)rows columns:(int)columns;

@end
