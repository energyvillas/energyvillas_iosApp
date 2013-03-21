//
//  DPScrollableDetailViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableDetailViewController.h"
#import "../External/ImageHelper/ImageResizing.h"

@interface DPScrollableDetailViewController () {
    bool pageControlUsed;
    int pageCount;
    NSMutableArray *contentRendered;
}

@end

@implementation DPScrollableDetailViewController

@synthesize scrollView, pageControl;
@synthesize contentList, currentPage;
@synthesize colCount, rowCount;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    int h = self.view.superview.bounds.size.height;
    int w = self.view.superview.bounds.size.width;
    
    self.view.frame = CGRectMake(0,0, w, h);

    self.scrollView.frame = CGRectMake(0, 0, w, h);
    
    self.pageControl.frame = CGRectMake(0, h - pageControl.frame.size.height,
                                   w, pageControl.frame.size.height);

    [self doInit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (void) doInit {
    contentRendered = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < contentList.count; i++)
    {
		[contentRendered addObject: [NSNumber numberWithInt:0]];
    }

    int rc = rowCount * colCount;
	pageCount = contentList.count / rc + (contentList.count % rc > 0 ? 1 : 0);
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    int fw = scrollView.frame.size.width;
    int fh = scrollView.frame.size.height;
    scrollView.contentSize = CGSizeMake(fw * pageCount, fh);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    
    scrollView.delegate = self;

    pageControl.numberOfPages = pageCount;
    pageControl.currentPage = currentPage;
	[self pageChanged:nil];
}

- (void)loadScrollViewWithPage:(int)page{
    if (page < 0)
        return;
    if (page >= pageCount)
        return;

    int w = scrollView.frame.size.width / colCount;
    int h = scrollView.frame.size.height / rowCount;
    
    for (int r = 0; r<rowCount; r++)
        for (int c = 0; c<colCount; c++)
        {
            int indx = page * (rowCount * colCount) + r * colCount + c;
            
            if (indx < contentList.count)
                if (((NSNumber *)contentRendered[indx]).intValue == 0) {
                    int iX = page * w  * colCount + w * c;
                    int iY = h * r;
                    UIImageView *iv = [[UIImageView alloc]
                                       initWithFrame:CGRectMake(iX, iY, w, h)];
                    iv.image = [(UIImage *)contentList[indx] scaleToSize:CGSizeMake(w, h)];
                    [scrollView addSubview:iv];
                    contentRendered[indx] = [NSNumber numberWithInt:1];
                }
        }
}

- (IBAction)pageChanged:(id)sender {
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}
         
- (void)scrollViewDidScroll:(UIScrollView *)sender{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
             
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
             
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
            
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

         
// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}
         
// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}
         

@end
