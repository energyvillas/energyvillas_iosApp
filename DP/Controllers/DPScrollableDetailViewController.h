//
//  DPScrollableDetailViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"

@interface DPScrollableDetailViewController : UINavContentViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)pageChanged:(id)sender;

@property (nonatomic) NSMutableArray *contentList;
@property (nonatomic) int currentPage;
@property (nonatomic) int rowCount;
@property (nonatomic) int colCount;

@end
