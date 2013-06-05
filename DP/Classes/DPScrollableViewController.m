//
//  DPScrollableDetailViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPScrollableViewController.h"
#import "../External/ImageHelper/ImageResizing.h"
#import "DPDataElement.h"
//#import "DPTestViewController.h"
#import "DPConstants.h"
#import <Quartzcore/Quartzcore.h>
#import "ASIHTTPRequest.h"
#import "DPAppHelper.h"
#import "UIImage+FX.h"



@interface DPScrollableViewController ()

@property (nonatomic) int currentPage;

@property (strong, nonatomic) NSMutableArray *portraitRendered;
@property (strong, nonatomic) NSMutableArray *landscapeRendered;

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation DPScrollableViewController {
    bool initializing, pageControlUsed, timerUsed, autoScroll, showPages;
    DPScrollDirection scrollDirection;
    int userTimerActive;
    NSTimer *timer, *usertimer;
    int TIMED_SCROLL_WIDTH;
 }

//@synthesize scrollView, pageControl;
//@synthesize currentPage;
//@synthesize colCount, rowCount;

- (int) getCurrentPage {
    return _currentPage;
}

- (void) setCurrentPage:(int)aCurrentPage {
    _currentPage = aCurrentPage;
    if (self.scrollableViewDelegate &&
        [self.scrollableViewDelegate respondsToSelector:@selector(scrolledToPage:)])
        [self.scrollableViewDelegate scrolledToPage:_currentPage];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithContent:(NSArray *)content
                  rows:(int)rows
               columns:(int)columns
            autoScroll:(BOOL)autoscroll {
    self = [self initWithContent:content
                            rows:(int)rows
                         columns:(int)columns
                      autoScroll:autoscroll
                       showPages:YES
                 scrollDirection:DPScrollDirectionHorizontal
                     initialPage:0];
    return self;
}

- (id) initWithContent:(NSArray *)content
                  rows:(int)rows
               columns:(int)columns
            autoScroll:(BOOL)autoscroll
             showPages:(BOOL)showpages
       scrollDirection:(DPScrollDirection)scrolldir
           initialPage:(int)initialPage{
    self = [super init];
    if (self) {
        self.currentPage = initialPage;
        self.rowCount = rows;
        self.colCount = columns;
        autoScroll = autoscroll;
        showPages = showpages;
        scrollDirection = scrolldir;
        self.contentList = content;
    }
    
    return self;
}

- (DPScrollDirection) getScrollDir {
    return scrollDirection;
}

- (void) contentLoaded:(NSArray *)content {
    self.contentList = content;
    self.portraitRendered = nil;
    self.landscapeRendered = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] init];
    self.pageControl = [[UIPageControl alloc] init];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.pageControl.backgroundColor = [UIColor clearColor];
    
    [self.pageControl addTarget:self
                         action:@selector(pageChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self cleanUp];
    [super viewDidUnload];
}

-(void) cleanUp {
    [self killUserTimer];
    [self killTimer];

    if (self.queue) {
        [self.queue cancelAllOperations];
        [self stopIndicator];
        
        for (id op in self.queue.operations)
            if ([op isKindOfClass:[ASIHTTPRequest class]]) {
                [((ASIHTTPRequest *)op) setDidFinishSelector:nil];
                ((ASIHTTPRequest *)op).delegate = nil;
            }
    }

    self.queue = nil;
    
    [self setScrollView:nil];
    [self setPageControl:nil];
}

-(void) dealloc {
    [self cleanUp];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self killUserTimer];
    [self killTimer];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGSize sz = self.view.superview.frame.size;
    self.view.frame = CGRectMake(0, 0, sz.width, sz.height);
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    [super doLayoutSubViews:fixtop];
    [self changeRows:self.rowCount columns:self.colCount];
}

- (BOOL) overlapPageControl {
    return NO;
}

- (void) calcFrames {
    CGRect vf = self.view.frame;
    if (CGRectIsEmpty(vf)) return;
    
    int h = vf.size.height;
    int w = vf.size.width;
    
    int pgCount = [self calcPageCount];
    if (showPages && pgCount > 1 && ![self overlapPageControl])
        self.scrollView.frame = CGRectMake(0, 0, w, h - PAGE_CONTROL_HEIGHT);
    else
        self.scrollView.frame = CGRectMake(0, 0, w, h);
    
#ifdef LOG_SCROLLABLE
    NSLog(@"CALCFRAME:: class:'%@', frm=(%d,%d,%d,%f)",
          [[self class] description], 0, 0, w, self.scrollView.frame.size.height);
#endif
//    CGRect pcf = self.pageControl.frame;
    self.pageControl.frame = CGRectMake(0, h - PAGE_CONTROL_HEIGHT, //pcf.size.height,
                                        w, PAGE_CONTROL_HEIGHT);//pcf.size.height);
}


- (void) changeScrollDirection:(DPScrollDirection)scrolldir {
    [self changeRows:self.rowCount columns:self.colCount scrollDirection:scrollDirection];
}

- (void) changeRows:(int)rows columns:(int)columns {
    [self changeRows:rows columns:columns scrollDirection:scrollDirection];
}

- (void) changeRows:(int)rows columns:(int)columns scrollDirection:(DPScrollDirection)scrolldir {
    int oldpage = self.currentPage;
    int oldrows = self.rowCount;
    int oldcols = self.colCount;
    scrollDirection = scrolldir;
    
    self.colCount = columns;
    self.rowCount = rows;
    if (self.rowCount * self.colCount == 0)
        self.currentPage = -1;
    else
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
    if (rc == 0) return 0;
    
	int pageCount = self.contentList.count / rc + (self.contentList.count % rc > 0 ? 1 : 0);
    return pageCount;
}

- (void) doInit {
    if (self.contentList == nil || self.contentList.count == 0) return;
    if (CGRectIsEmpty(self.view.bounds)) return;
    
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
            // content rendered for landscape...
            self.landscapeRendered = [[NSMutableArray alloc] init];
            for (unsigned i = 0; i < self.contentList.count; i++)
            {
                [self.landscapeRendered addObject: [NSNull null]];
            }
        }
    }
    
    if (self.rowCount * self.colCount == 0) return;
    
	int pageCount = [self calcPageCount];
    
    // a page is the width/height of the scroll view
    self.scrollView.pagingEnabled = YES;
    int fw = self.scrollView.frame.size.width;
    int fh = self.scrollView.frame.size.height;
    
    self.scrollView.delegate = nil;
    if (scrollDirection == DPScrollDirectionHorizontal)
        self.scrollView.contentSize = CGSizeMake(fw * pageCount, fh);
    else
        self.scrollView.contentSize = CGSizeMake(fw, fh * pageCount);
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    
    self.scrollView.delegate = self;

#ifdef LOG_SCROLLABLE
    NSLog(@"PAGES:: %@", [[self class] description]);
#endif
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = self.currentPage;
    if (!showPages) self.pageControl.hidden = YES;
    
    TIMED_SCROLL_WIDTH = fw;
    [self engageAutoTimer];
	[self pageChanged:nil];
}

- (NSString *) calcImageName:(NSString *)baseName {
    return baseName;
}

- (void)loadScrollViewWithPage:(int)page{
    if (initializing) return;
    if (page < 0) return;
    if (page >= self.pageControl.numberOfPages) return;
    
    int pageWidth = self.scrollView.frame.size.width;
    int pageHeight = self.scrollView.frame.size.height;
    int colWidth = pageWidth / self.colCount;
    int rowHeight = pageHeight / self.rowCount;
    
    if (colWidth == 0 || rowHeight == 0) return;
    
    int rowHeightResidue = (int)pageHeight % self.rowCount;
    int fixHeight = (rowHeightResidue > 0 ? 1 : 0);
    
    NSMutableArray *contentRendered = UIInterfaceOrientationIsPortrait(INTERFACE_ORIENTATION) ? self.portraitRendered : self.landscapeRendered;
    
    int posY = scrollDirection == DPScrollDirectionHorizontal ? 0 : page * pageHeight;
    for (int r = 0; r<self.rowCount; r++)
    {
        posY = posY + (rowHeight + fixHeight) * (r == 0 ? 0 : 1);
        int colWidthResidue = pageWidth % self.colCount;
        fixHeight = (rowHeightResidue > 0 ? 1 : 0);
        
        int posX = scrollDirection == DPScrollDirectionHorizontal ? page * pageWidth : 0;
        
        int fixWidth = (colWidthResidue > 0 ? 1 : 0);
        for (int c = 0; c<self.colCount; c++)
        {
            posX = posX + (colWidth + fixWidth) * (c == 0 ? 0 : 1);
            int indx = page * (self.rowCount * self.colCount) + r * self.colCount + c;
            fixWidth = (colWidthResidue > 0 ? 1 : 0);
            
            if (indx < self.contentList.count) {
                if (contentRendered[indx] == [NSNull null])
                {
                    CGRect r = CGRectMake(posX, posY, colWidth + fixWidth, rowHeight + fixHeight);
                    UIView *v = [[UIView alloc] initWithFrame:r];
                    v.clipsToBounds = YES;
                    
                    [self loadPage:indx inView:v frame:CGRectMake(0, 0,
                                                                  colWidth + fixWidth,
                                                                  rowHeight + fixHeight)];
                    v.tag = indx;
                    contentRendered[indx] = v;
                }
                [self.scrollView addSubview: contentRendered[indx]];
                
            }
            colWidthResidue = colWidthResidue > 0 ? colWidthResidue - 1 : 0;
        }
        
        rowHeightResidue = rowHeightResidue > 0 ? rowHeightResidue - 1 : 0;
    }
}

- (void) loadPage:(int)contentIndex inView:(UIView *)container frame:(CGRect)frame {
#ifdef LOG_SCROLLABLE
    NSLog(@"LOADPAGE-FRAME:: class:'%@', frm=(%f,%f,%f,%f)",
          [[self class] description],
          frame.origin.x, frame.origin.y,
          frame.size.width, frame.size.height);
#endif
    if ([self.dataDelegate respondsToSelector:@selector(loadPage:inView:frameSize:)])
        [self.dataDelegate loadPage:contentIndex inView:container frame:frame];
    else
        [self doloadPage:contentIndex inView:container frame:frame];
}

- (NSString *) resolveImageName:(DPDataElement *)elm {
    return [self calcImageName: elm.imageUrl];
}
- (NSString *) resolveHighlightImageName:(DPDataElement *)elm  {
    return nil;
}

- (NSString *) getBaseImageUrlToLoadFor:(DPDataElement *)elm {
    return elm.imageUrl;
}
- (void) loadImageFor:(DPDataElement *)element inView:(UIImageView *)imgView {
    NSString *imgUrl = [self getBaseImageUrlToLoadFor:element];
    
    if ([self isLocalUrl:imgUrl]) {
        NSString *imgname =[self resolveImageName:element];
        imgView.image = [UIImage imageNamed:imgname];
        
        NSString *imghighname =[self resolveHighlightImageName:element];
        if (imghighname)
            imgView.highlightedImage = [UIImage imageNamed:imghighname];
    } else {
        [self loadImageAsync:element imageUrl:imgUrl inView:imgView cacheImage:YES];
    }
}

-(CGRect) calcFittingFrame:(CGSize)szImage frame:(CGRect)containerframe{
    CGRect frm;
    CGSize sz = containerframe.size; sz.width = 0.8f * sz.width;
    if (sz.width > szImage.width && sz.height > szImage.height)
        frm = CGRectMake(0, 0, szImage.width, szImage.height);
    else {
        CGFloat ir = szImage.width / szImage.height;
        CGFloat cr = sz.width / sz.height;
        if (ir < cr)  { //  image is taller than carousel
            // we should fix image height to be equal to carousel height
            // and calc image width according to aspect and new height
            frm = CGRectMake(0, 0, sz.height * ir, sz.height);
        } else { // image is wider or same aspect ratio to that of carousel
            // we should fix image width to be equal to carousel width * 0.8
            // and calc image height according to aspect and new width
            frm = CGRectMake(0, 0, sz.width, sz.width / ir);
        }
    }
    frm = CGRectOffset(frm,
                       (containerframe.size.width - frm.size.width) / 2.0f,
                       (containerframe.size.height - frm.size.height) / 2.0f);
    return frm;
}

-(UIView *) createImageViewLoading:(UIView *)container  {
    return createImageViewLoading(container.bounds, NO, NO);
    
//    CGRect vFrame = container.bounds;
//    vFrame = CGRectInset(vFrame, 20.0f, 20.0f);
//    
//    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%@.png", CURRENT_LANG]];
//    img = [img imageScaledToFitSize:CGSizeMake(vFrame.size.width / 2.0f,
//                                               vFrame.size.height / 2.0f)];
//    
//    //CGRect frm = CGRectInset(vFrame, vFrame.size.width / 4.0f, vFrame.size.height / 4.0f);
//    CGRect frm = CGRectMake(0.0f, 0.0f,
//                            vFrame.size.width / 2.0f,
//                            vFrame.size.height / 2.0f);
//    frm = CGRectOffset(frm,
//                       vFrame.size.width / 4.0f,
//                       vFrame.size.height / 4.0f);
//    
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:frm];
//    iv.contentMode = UIViewContentModeCenter;
//    iv.image = img;
//    
//    UIView *v = [[UIView alloc] initWithFrame:vFrame];
//    v.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
//    v.layer.cornerRadius = IS_IPAD ? 8.0f : 4.0f;
//    v.layer.borderWidth = IS_IPAD ? 4.0f : 2.0;
//    v.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.75f].CGColor;
//    
//    [v addSubview:iv];
//    
////    frm = v.bounds;
////    UIActivityIndicatorView *bi = [[UIActivityIndicatorView alloc]
////                                   initWithActivityIndicatorStyle: IS_IPAD ? UIActivityIndicatorViewStyleWhiteLarge: UIActivityIndicatorViewStyleWhite];
////    bi.frame = CGRectOffset(CGRectMake((frm.size.width-25)/2,
////                                       (frm.size.height-25)/2,
////                                       25, 25),
////                            0, IS_IPAD ? 110 : IS_IPHONE ? 40 : 55);
////    bi.hidesWhenStopped = YES;
////    [v addSubview:bi];
////    [bi startAnimating];
//    
//    return v;
}

- (UIView *) internalCreateViewFor:(int)contentIndex frame:(CGRect)frame {
    UIView *result = nil;
    if ([self.dataDelegate respondsToSelector:@selector(createViewFor:frame:)])
        result = [self.dataDelegate createViewFor:contentIndex frame:frame];
    else
        result = [self doCreateViewFor:contentIndex frame:frame];

    [self internalPostProcessView:result contentIndex:contentIndex frame:frame];
    
    return result;
}

- (void) internalPostProcessView:(UIView *)aView
            contentIndex:(int)contentIndex
                   frame:(CGRect)frame {
    if ([self.dataDelegate respondsToSelector:@selector(postProcessView:contentIndex:frame:)])
        [self.dataDelegate postProcessView:aView
                              contentIndex:contentIndex
                                     frame:frame];
}

- (UIView *) doCreateViewFor:(int)contentIndex frame:(CGRect)frame {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame: frame];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.contentMode = UIViewContentModeCenter; //ScaleAspectFit;//Center;//ScaleAspectFit;

    imgView.tag = contentIndex;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleTap:)];
    [imgView addGestureRecognizer:tapper];
    imgView.userInteractionEnabled = YES;
    
    return imgView;
}

- (UILabel *) internalCreateLabelFor:(int)contentIndex
                       frame:(CGRect)frame
                       title:(NSString *)title {
    UILabel *result= nil;
    if ([self.dataDelegate respondsToSelector:@selector(createLabelFor:frame:title:)])
        result = [self.dataDelegate createLabelFor:contentIndex frame:frame title:title];
    else
        result = [self doCreateLabelFor:contentIndex frame:frame title:title];
    
    [self internalPostProcessLabel:result contentIndex:contentIndex frame:frame];

    return result;
}

- (void) internalPostProcessLabel:(UILabel *)aLabel
            contentIndex:(int)contentIndex
                   frame:(CGRect)frame {
    if ([self.dataDelegate respondsToSelector:@selector(postProcessLabel:contentIndex:frame:)])
        [self.dataDelegate postProcessLabel:aLabel
                               contentIndex:contentIndex
                                      frame:frame];
}

- (UILabel *) doCreateLabelFor:(int)contentIndex
                         frame:(CGRect)frame
                         title:(NSString *)title {
    UILabel *label = createLabel(frame, title, nil);
    return label;
}


- (void) doloadPage:(int)contentIndex inView:(UIView *)container frame:(CGRect)frame {
    //CGRect r = CGRectMake(0, 0, size.width, size.height);
    
    DPDataElement *element = self.contentList[contentIndex];
    
    // add imageview
    UIView *aView = [self internalCreateViewFor:contentIndex frame:frame];
    if (aView != nil && [aView isKindOfClass:[UIImageView class]])
        [self loadImageFor:element inView:(UIImageView *)aView];

    // add label
    UILabel *lblView = [self internalCreateLabelFor:contentIndex frame:frame title:element.title];
    
    // insert image and label in the view
    if (aView != nil)
        [container addSubview:aView];
    
    if (lblView != nil)
        [container addSubview:lblView];
}

- (void) invokeViewDelegate:(UITapGestureRecognizer *)sender element:(id)element {
    if ([self.scrollableViewDelegate respondsToSelector:@selector(elementTapped:element:)])
        [self.scrollableViewDelegate elementTapped:sender element:element];

}
- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender == nil) return;
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        int indx = sender.view.tag;

        DPDataElement * element = self.contentList[indx];
#ifdef LOG_SCROLLABLE
        NSLog(@"Clicked image at index %i named %@", indx, element.title);
#endif
        [self invokeViewDelegate:sender element:element];
        
        // navigation logic goes here. create and push a new view controller;
//        DPTestViewController *vc = [[DPTestViewController alloc] init];
//        [self.navigationController pushViewController: vc animated: YES];
    }
}
    
- (IBAction)pageChanged:(id)sender {
    if (initializing) return;
    self.currentPage = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:self.currentPage - 2];
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage + 1];
    [self loadScrollViewWithPage:self.currentPage + 2];
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    switch (self.scrollDirection) {
        case DPScrollDirectionHorizontal:
            frame.origin.x = frame.size.width * self.currentPage;
            frame.origin.y = 0;
            break;
            
        case DPScrollDirectionVertical:
            frame.origin.x = 0;
            frame.origin.y = frame.size.height * self.currentPage;
            break;
    }

    if (timerUsed && (self.currentPage == 0))
        [self.scrollView scrollRectToVisible:frame animated:NO];
    else
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
    CGSize pageSize = self.scrollView.frame.size;
    switch (self.scrollDirection) {
        case DPScrollDirectionHorizontal:
            self.currentPage = floor((self.scrollView.contentOffset.x - pageSize.width / 2) / pageSize.width) + 1;
            break;
            
        case DPScrollDirectionVertical:
            self.currentPage = floor((self.scrollView.contentOffset.y - pageSize.height / 2) / pageSize.height) + 1;
            break;
    }
    
    self.pageControl.currentPage = self.currentPage;
#ifdef LOG_SCROLLABLE
    NSLog(@"SCROLLED TO PAGE %d", self.currentPage);
#endif
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:self.currentPage - 2];
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage + 1];
    [self loadScrollViewWithPage:self.currentPage + 2];
    
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

- (NSTimeInterval) autoScrollInterval {
    return AUTO_SCROLL_INTERVAL;
}
- (NSTimeInterval) userScrollInterval {
    return USER_SCROLL_INTERVAL;
}

- (void) engageAutoTimer {
    if (!autoScroll) return;
    if (self.pageControl.numberOfPages <= 1) return;
    
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[self autoScrollInterval] target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}

- (void) onTimer {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    
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

        usertimer = [NSTimer scheduledTimerWithTimeInterval:[self userScrollInterval]
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

#pragma mark - loading of image data

- (BOOL) isLocalUrl:(NSString *)urlstr {
    NSURL *url = [NSURL URLWithString:urlstr];
    return url.isFileReferenceURL || url.host == nil;
}

- (void) startIndicator {
//    if(!self.busyIndicator) {
//		self.busyIndicator = [[UIActivityIndicatorView alloc]
//                              initWithActivityIndicatorStyle:(IS_IPAD ? UIActivityIndicatorViewStyleWhiteLarge :  UIActivityIndicatorViewStyleWhite)];
//		self.busyIndicator.frame = CGRectMake((self.view.frame.size.width-25)/2,
//                                              (self.view.frame.size.height-25)/2,
//                                              25, 25);
//		self.busyIndicator.hidesWhenStopped = TRUE;
//        [self.view addSubview:self.busyIndicator];
//	}
//    
//    if (!self.busyIndicator.isAnimating)
//        [self.busyIndicator startAnimating];
}

- (void) stopIndicator {
//    if (self.busyIndicator &&
//        self.queue &&
//        self.queue.operationCount == 0) {
//        [self.busyIndicator stopAnimating];
//        [self.busyIndicator removeFromSuperview];
//        self.busyIndicator = nil;
//    }
}

- (void) fix:(DPDataElement *)elm
   imageView:(UIImageView *)imgView
    imageUrl:(NSString *)imageUrl
        data:(NSData *)imgData
  addToCache:(BOOL)addToCache{
    
    releaseSubViews(imgView);

    imgView.image = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
    if (addToCache)
        [[DPAppHelper sharedInstance] saveImageToCache:imageUrl data:imgData];
}

//PENDING : i think i must pass just the elm.imageUrl not the calced name!!!!
// in the whole async process!!!!
- (void) loadImageAsync:(DPDataElement *)elm imageUrl:(NSString *)imgUrl inView:(UIImageView *)imgView cacheImage:(BOOL)cacheimage{
    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
    NSData *imgData = [appHelper loadImageFromCache:imgUrl];
    if (imgData) 
        [self fix:elm imageView:imgView imageUrl:imgUrl data:imgData addToCache:NO];
    else {
        [imgView addSubview:[self createImageViewLoading:imgView]];

        [self doloadImageAsync:elm imageUrl:imgUrl inView:imgView cacheImage:cacheimage];
    }
}

- (void) doloadImageAsync:(DPDataElement *)elm imageUrl:(NSString *)imgUrl inView:(UIImageView *)imgView cacheImage:(BOOL)cacheimage{
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imgUrl]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        elm, @"element",
                        imgView, @"imageView",
                        imgUrl, @"imageUrl",
                        [NSNumber numberWithBool:cacheimage], @"cacheimage",
                        nil];
    [self.queue addOperation:request];

    [self startIndicator];
}

- (void)requestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];

    NSDictionary *uiDict = request.userInfo;

    [self fix:uiDict[@"element"]
    imageView:uiDict[@"imageView"]
     imageUrl:uiDict[@"imageUrl"]
         data:[request responseData]
   addToCache:[(NSNumber *)uiDict[@"cacheimage"] boolValue]];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self stopIndicator];
}

@end
