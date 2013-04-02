//
//  DPScrollableDetailViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "../External/ImageHelper/ImageResizing.h"
#import "Article.h"
#import "DPTestViewController.h"
#import "DPConstants.h"
#include <Quartzcore/Quartzcore.h>


@interface DPScrollableViewController ()

@property (nonatomic) int currentPage;

@property (strong, nonatomic) NSMutableArray *portraitRendered;
@property (strong, nonatomic) NSMutableArray *landscapeRendered;

@end

@implementation DPScrollableViewController {
    bool initializing, pageControlUsed, timerUsed, autoScroll;
    int userTimerActive;
    NSTimer *timer, *usertimer;
    int TIMED_SCROLL_WIDTH;
 }

@synthesize scrollView, pageControl;
@synthesize currentPage;
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

- (id) initWithContent:(NSArray *)content autoScroll:(BOOL)autoscroll {
    self = [super init];
    if (self) {
        autoScroll = autoscroll;
        self.contentList = content;
        self.view = [[UIView alloc] init];
        self.scrollView = [[UIScrollView alloc] init];
        self.pageControl = [[UIPageControl alloc] init];
        [self.pageControl addTarget:self
                             action:@selector(pageChanged:)
                   forControlEvents:UIControlEventValueChanged];
                
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

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self killUserTimer];
    [self killTimer];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    BOOL isRendered = NO;
    if (UIInterfaceOrientationIsPortrait(INTERFACE_ORIENTATION)) {
        isRendered = self.portraitRendered != nil;
        if (!isRendered) {
            // content rendered for portrait...
            self.portraitRendered = [[NSMutableArray alloc] init];
            for (unsigned i = 0; i < self.contentList.count; i++)
            {
                [self.portraitRendered addObject: [NSNull null]];
            }
        }
    } else {
        isRendered = self.landscapeRendered != nil;
        if (!isRendered) {
            // content rendered for portrait...
            self.landscapeRendered = [[NSMutableArray alloc] init];
            for (unsigned i = 0; i < self.contentList.count; i++)
            {
                [self.landscapeRendered addObject: [NSNull null]];
            }
        }
    }
    
	int pageCount = [self calcPageCount];
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    int fw = self.scrollView.frame.size.width;
    int fh = self.scrollView.frame.size.height;
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

- (void)loadScrollViewWithPage:(int)page{
    if (initializing) return;
    if (page < 0) return;
    if (page >= self.pageControl.numberOfPages) return;

    int pageWidth = self.scrollView.frame.size.width;
    int colWidth = pageWidth / colCount;
    int rowHeight = self.scrollView.frame.size.height / rowCount;
    
    if (colWidth == 0 || rowHeight == 0) return;
    
    int rowHeightResidue = (int)self.scrollView.frame.size.height % rowCount;
    int fixHeight = (rowHeightResidue > 0 ? 1 : 0);
    
    NSMutableArray *contentRendered = UIInterfaceOrientationIsPortrait(INTERFACE_ORIENTATION) ? self.portraitRendered : self.landscapeRendered;
    
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

            if (indx < self.contentList.count) {
                if (contentRendered[indx] == [NSNull null]) {
                    CGRect r = CGRectMake(posX, posY, colWidth + fixWidth, rowHeight + fixHeight);
                    UIView *v = [[UIView alloc] initWithFrame:r];
                    v.clipsToBounds = YES;
                    
                    r = CGRectMake(0, 0, colWidth + fixWidth, rowHeight + fixHeight);
                    UIImageView *iv = [[UIImageView alloc] initWithFrame: r];
                    iv.contentMode = UIViewContentModeScaleAspectFill; //UIViewContentModeScaleToFill; //UIViewContentModeScaleAspectFill; //UIViewContentModeScaleAspectFit;
                    Article *article = self.contentList[indx];
                    iv.image = [UIImage imageNamed:article.imageUrl];
                    iv.tag = indx;
                    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleTap:)];
                    [iv addGestureRecognizer:tapper];
                    iv.userInteractionEnabled = YES;
                    
                    // add label
                    UILabel *lv = [[UILabel alloc] initWithFrame: r];
                    lv.textAlignment = NSTextAlignmentCenter;
                    if (IS_IPAD)
                        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
                    else
                        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
                    lv.adjustsFontSizeToFitWidth = YES;
                    lv.text = article.title;
                    lv.backgroundColor = [UIColor clearColor];
                    [lv sizeToFit];
                    CGRect b = lv.bounds;
                    int offsetfix = IS_IPAD ? 4 : 2;
                    lv.frame = CGRectMake(r.origin.x, r.origin.y + r.size.height - b.size.height - offsetfix, r.size.width, b.size.height);
                    // setup text shadow
                    lv.textColor = [UIColor blackColor];
                    lv.layer.shadowColor = [lv.textColor CGColor];
                    lv.textColor = [UIColor whiteColor];
                    lv.layer.shadowOffset = CGSizeMake(0.0, 0.0);
                    lv.layer.masksToBounds = NO;                    
                    lv.layer.shadowRadius = 1.5f;
                    lv.layer.shadowOpacity = 0.95;

                    // insert image and label in the view
                    [v addSubview:iv];
                    [v addSubview:lv];
                    
                    contentRendered[indx] = v;
                }
                int scrlvc = self.scrollView.subviews.count;
                [self.scrollView addSubview: contentRendered[indx]];
                scrlvc = self.scrollView.subviews.count;

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
        Article * article = self.contentList[indx];
        NSLog(@"Clicked image at index %i named %@", indx, article.title);
        
        [self invokeViewDelegate:article];
        
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
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.currentPage;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
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
    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
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

- (void) engageAutoTimer {
    if (!autoScroll) return;
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

- (void) killTimer {
    [timer invalidate];
    timer = nil;
    timerUsed = NO;
}

- (void) engageUserTimer {
    if (!autoScroll) return;
    if (self.pageControl.numberOfPages <= 1) return;
    
    if (!timerUsed) {
        userTimerActive++;

        usertimer = [NSTimer scheduledTimerWithTimeInterval:USER_SCROLL_INTERVAL
                                target:self
                                selector:@selector(onUserTimer)
                                userInfo:nil repeats:NO];
        [self killTimer];
    }
}

- (void) onUserTimer {
    userTimerActive--;
    if (userTimerActive == 0) {
        [self killUserTimer];
        [self engageAutoTimer];
    }
}

- (void) killUserTimer {
    [usertimer invalidate];
    usertimer = nil;
    userTimerActive = 0;
    timerUsed = NO;
}

@end
