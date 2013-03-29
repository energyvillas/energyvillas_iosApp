//
//  DPScrollableDetailViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "../External/ImageHelper/ImageResizing.h"
#import "../Classes/DPImageInfo.h"
#import "DPTestViewController.h"
#import "DPConstants.h"


@interface DPScrollableViewController ()

@property (nonatomic) int currentPage;

@end

@implementation DPScrollableViewController {
    bool initializing, pageControlUsed, timerUsed;
    int userTimerActive;
    NSMutableArray *contentRendered;
    NSTimer *timer;
    int TIMED_SCROLL_WIDTH;
}

@synthesize scrollView, pageControl;
@synthesize contentList, currentPage;
@synthesize colCount, rowCount;

@synthesize viewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        if (self.view)
            NSLog(@"has view");
        else
            NSLog(@"view nil");
    }
    return self;
}

- (id) initWithContent:(NSArray *)content {
    self = [super init];
    if (self) {
        self.contentList = content;
        self.view = [[UIView alloc] init];
        self.scrollView = [[UIScrollView alloc] init];
        self.pageControl = [[UIPageControl alloc] init];
        [self.view addSubview:self.scrollView];
        [self.view addSubview:self.pageControl];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidDisappear:(BOOL)animated{

}
- (void) viewDidAppear:(BOOL)animated {
    [self calcFrames];
    [self doInit];
}

- (void) calcFrames {
    UIView *v = self.view;
    UIView *sv = v.superview;
    int h = sv.frame.size.height;
    int w = sv.frame.size.width;
    
    self.view.frame = CGRectMake(0,0, w, h);
    
    self.scrollView.frame = CGRectMake(0, 0, w, h);
    
    self.pageControl.frame = CGRectMake(0, h - pageControl.frame.size.height,
                                        w, pageControl.frame.size.height);
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (void) changeRows:(int)rows columns:(int)columns {
    int oldpage = self.currentPage;
    int oldrows = self.rowCount;
    int oldcols = self.colCount;
    
    self.colCount = columns;
    self.rowCount = rows;
    self.currentPage = oldpage * oldcols * oldrows / (rows * columns);
    while (self.scrollView.subviews.count>0) {
        UIView *v = self.scrollView.subviews[0];
        [v removeFromSuperview];
        v = nil;
    }
    initializing = YES;
    [self calcFrames];
    initializing = false;
    [self doInit];
}

- (int) calcPageCount {
    int rc = self.rowCount * self.colCount;
	int pageCount = self.contentList.count / rc + (self.contentList.count % rc > 0 ? 1 : 0);
    return pageCount;
}

- (void) doInit {
    contentRendered = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < contentList.count; i++)
    {
		[contentRendered addObject: [NSNumber numberWithInt:0]];
    }

	int pageCount = [self calcPageCount];
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    int fw = scrollView.frame.size.width;
    int fh = scrollView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(fw * pageCount, fh);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    
    self.scrollView.delegate = self;

    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = self.currentPage;
    
    TIMED_SCROLL_WIDTH = fw;
    [self engageAutoTimer];
	[self pageChanged:nil];
}

- (void) engageAutoTimer {
    if (self.pageControl.numberOfPages <= 1) return;
    
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:AUTO_SCROLL_INTERVAL target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}

- (void) onTimer {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    
    NSLog(@"onTimer - time: %@", [dateFormatter stringFromDate:[NSDate date]]);
    //This makes the scrollView scroll to the desired position
    //[scrollView setContentOffset:CGPointMake(TIMED_SCROLL_WIDTH, 0) animated:YES];
    int cp = self.pageControl.currentPage + 1;
    int pc = self.pageControl.numberOfPages;
    if (cp == pc)
        cp = 0;
    self.pageControl.currentPage = cp;
    timerUsed = YES;
    [self pageChanged:nil];
}

- (void)loadScrollViewWithPage:(int)page{
    if (initializing) return;
    if (page < 0) return;
    if (page >= self.pageControl.numberOfPages) return;

    int pageWidth = scrollView.frame.size.width;
    int colWidth = pageWidth / colCount;
    int rowHeight = scrollView.frame.size.height / rowCount;
    int rowHeightResidue = (int)scrollView.frame.size.height % rowCount;
    int fixHeight = (rowHeightResidue > 0 ? 1 : 0);
    
    int posY = 0;
    for (int r = 0; r<rowCount; r++)
    {
        posY = posY + (rowHeight + fixHeight) * (r == 0 ? 0 : 1);
        int colWidthResidue = pageWidth % colCount;
        fixHeight = (rowHeightResidue > 0 ? 1 : 0);

        int posX = page * pageWidth;

        int fixWidth = (colWidthResidue > 0 ? 1 : 0);
        for (int c = 0; c<colCount; c++)
        {
            posX = posX + (colWidth + fixWidth) * (c == 0 ? 0 : 1);
            int indx = page * (rowCount * colCount) + r * colCount + c;
            fixWidth = (colWidthResidue > 0 ? 1 : 0);

            if (indx < contentList.count)
                if (((NSNumber *)contentRendered[indx]).intValue == 0) {
                    /*
                    if (indx == 3) {
                        UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(iX, iY, w, h)];
                        wv.scalesPageToFit = YES;
                        [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.bitzarohotels.gr"]]];
                        [scrollView addSubview:wv];
                    } else */ {
                        CGRect r = CGRectMake(posX, posY, colWidth + fixWidth, rowHeight + fixHeight);
                        UIView *v = [[UIView alloc] initWithFrame:r];
                        v.clipsToBounds = YES;
                        
                        r = CGRectMake(0, 0, colWidth + fixWidth, rowHeight + fixHeight);
                        UIImageView *iv = [[UIImageView alloc] initWithFrame: r];
                        iv.image = ((DPImageInfo *)contentList[indx]).image;
                        iv.contentMode = UIViewContentModeScaleToFill; //UIViewContentModeScaleAspectFill; //UIViewContentModeScaleAspectFit;
                        iv.tag = indx;
                        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(handleTap:)];
                        [iv addGestureRecognizer:tapper];
                        iv.userInteractionEnabled = YES;
                        
                        UILabel *lv = [[UILabel alloc] initWithFrame: r];
                        lv.textAlignment = NSTextAlignmentCenter;
                        if (IS_IPAD)
                            lv.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
                        else
                            lv.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                        lv.adjustsFontSizeToFitWidth = YES;
                        NSString *dl = ((DPImageInfo *)contentList[indx]).displayNname;
                        lv.text = dl ? dl : ((DPImageInfo *)contentList[indx]).name;
                        lv.backgroundColor = [UIColor clearColor];
                        lv.textColor = [UIColor whiteColor];
                        [lv sizeToFit];
                        CGRect b = lv.bounds;
                        int offsetfix = IS_IPAD ? 4 : 2;
                        lv.frame = CGRectMake(r.origin.x, r.origin.y + r.size.height - b.size.height - offsetfix, r.size.width, b.size.height);
                        
                        [v addSubview:iv];
                        [v addSubview:lv];
                        [scrollView addSubview:v];
                    }
                    contentRendered[indx] = [NSNumber numberWithInt:1];
                }
        
            colWidthResidue = colWidthResidue > 0 ? colWidthResidue - 1 : 0;
        }
        
        rowHeightResidue = rowHeightResidue > 0 ? rowHeightResidue - 1 : 0;
    }
}

- (void) invokeViewDelegate:(id) element {
    if ([self.viewDelegate respondsToSelector:@selector(elementTapped:)])
        [self.viewDelegate elementTapped:element];

}
- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        int indx = sender.view.tag;
        DPImageInfo * ii = contentList[indx];
        NSLog(@"Clicked image at index %i named %@", indx, ii.name);
        
        [self invokeViewDelegate:ii];
        
        // navigation logic goes here. create and push a new view controller;
//        DPTestViewController *vc = [[DPTestViewController alloc] init];
//        [self.navigationController pushViewController: vc animated: YES];
    }
}
    
- (IBAction)pageChanged:(id)sender {
    if (initializing) return;
    self.currentPage = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * self.currentPage;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
    timerUsed = NO;
    if (sender != nil)
        [self engageUserTimer];
}
         
- (void)scrollViewDidScroll:(UIScrollView *)sender{
    if (timerUsed) return;
    if (initializing) return;
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
    self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = self.currentPage;
             
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage + 1];
            
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

         
// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
    [self engageUserTimer];
}
         
// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
    [self engageUserTimer];
}

- (void) engageUserTimer {
    if (self.pageControl.numberOfPages <= 1) return;
    
    if (!timerUsed) {
        userTimerActive++;
        [NSTimer scheduledTimerWithTimeInterval:5 * AUTO_SCROLL_INTERVAL
                                target:self
                                selector:@selector(onUserTimer)
                                userInfo:nil repeats:NO];
        
        [timer invalidate];
        timer = nil;
    }
}

- (void) onUserTimer {
    userTimerActive--;
    if (userTimerActive == 0)
        [self engageAutoTimer];
}

@end
