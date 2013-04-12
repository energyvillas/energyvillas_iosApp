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


@interface DPScrollableViewController ()

@property (nonatomic) int currentPage;

@property (strong, nonatomic) NSMutableArray *portraitRendered;
@property (strong, nonatomic) NSMutableArray *landscapeRendered;

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;

@end

@implementation DPScrollableViewController {
    bool initializing, pageControlUsed, timerUsed, autoScroll, showPages;
    DPScrollDirection scrollDirection;
    int userTimerActive;
    NSTimer *timer, *usertimer;
    int TIMED_SCROLL_WIDTH;
 }

@synthesize scrollView, pageControl;
@synthesize currentPage;
@synthesize colCount, rowCount;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithContent:(NSArray *)content
            autoScroll:(BOOL)autoscroll {
    self = [self initWithContent:content autoScroll:autoscroll showPages:YES scrollDirection:DPScrollDirectionHorizontal];
    return self;
}

- (id) initWithContent:(NSArray *)content
            autoScroll:(BOOL)autoscroll
             showPages:(BOOL)showpages
       scrollDirection:(DPScrollDirection)scrolldir {
    self = [super init];
    if (self) {
        autoScroll = autoscroll;
        showPages = showpages;
        scrollDirection = scrolldir;
        self.contentList = content;
//        if (!self.view)
            self.view = [[UIView alloc] init];
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
    
    return self;
}

- (DPScrollDirection) getScrollDir {
    return scrollDirection;
}

- (void) contentLoaded:(NSArray *)content {
    self.contentList = content;
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
    
    CGSize sz = self.view.superview.frame.size;
    self.view.frame = CGRectMake(0, 0, sz.width, sz.height);
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self changeRows:self.rowCount columns:self.colCount];
}

- (void) calcFrames {
    CGRect vf = self.view.frame;
    if (CGRectIsEmpty(vf)) return;
    
    int h = vf.size.height;
    int w = vf.size.width;
    
    self.scrollView.frame = CGRectMake(0, 0, w, h - PAGE_CONTROL_HEIGHT);
    
//    CGRect pcf = self.pageControl.frame;
    self.pageControl.frame = CGRectMake(0, h - PAGE_CONTROL_HEIGHT, //pcf.size.height,
                                        w, PAGE_CONTROL_HEIGHT);//pcf.size.height);
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self stopIndicator];
    if (self.downloadQueue)
        [self.downloadQueue cancelAllOperations];
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
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
    
    if (scrollDirection == DPScrollDirectionHorizontal)
        self.scrollView.contentSize = CGSizeMake(fw * pageCount, fh);
    else
        self.scrollView.contentSize = CGSizeMake(fw, fh * pageCount);
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    
    self.scrollView.delegate = self;

    NSLog(@"PAGES:: %@", [[self class] description]);
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
    int colWidth = pageWidth / colCount;
    int rowHeight = pageHeight / rowCount;
    
    if (colWidth == 0 || rowHeight == 0) return;
    
    int rowHeightResidue = (int)pageHeight % rowCount;
    int fixHeight = (rowHeightResidue > 0 ? 1 : 0);
    
    NSMutableArray *contentRendered = UIInterfaceOrientationIsPortrait(INTERFACE_ORIENTATION) ? self.portraitRendered : self.landscapeRendered;
    
    int posY = scrollDirection == DPScrollDirectionHorizontal ? 0 : page * pageHeight;
    for (int r = 0; r<rowCount; r++)
    {
        posY = posY + (rowHeight + fixHeight) * (r == 0 ? 0 : 1);
        int colWidthResidue = pageWidth % colCount;
        fixHeight = (rowHeightResidue > 0 ? 1 : 0);
        
        int posX = scrollDirection == DPScrollDirectionHorizontal ? page * pageWidth : 0;
        
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
                    
                    [self loadPage:indx inView:v frame:CGRectMake(0, 0,
                                                                  colWidth + fixWidth,
                                                                  rowHeight + fixHeight)];
                    
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

- (void) loadPage:(int)contentIndex inView:(UIView *)container frame:(CGRect)frame {
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

- (void) loadImageFor:(DPDataElement *)element inView:(UIImageView *)imgView {
    NSLog(@"ImageUrl:: '%@'", element.imageUrl);
    if ([self isLocalUrl:element.imageUrl]) {
        NSString *imgname =[self resolveImageName:element];
        imgView.image = [UIImage imageNamed:imgname];
        
        NSString *imghighname =[self resolveHighlightImageName:element];
        if (imghighname)
            imgView.highlightedImage = [UIImage imageNamed:imghighname];
    } else
        [self loadImageAsync:element inView:imgView cacheImage:YES];
}

- (UIView *) createViewFor:(int)contentIndex frame:(CGRect)frame {
    UIView *result = nil;
    if ([self.dataDelegate respondsToSelector:@selector(createViewFor:frame:)])
        result = [self.dataDelegate createViewFor:contentIndex frame:frame];
    else
        result = [self doCreateViewFor:contentIndex frame:frame];
    return result;
}

- (void) postProcessView:(UIView *)aView
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
    
    [self postProcessView:imgView contentIndex:contentIndex frame:frame];
    
    return imgView;
}

- (UILabel *) createLabelFor:(int)contentIndex
                       frame:(CGRect)frame
                       title:(NSString *)title {
    UILabel *result= nil;
    if ([self.dataDelegate respondsToSelector:@selector(createLabel:title:)])
        result = [self.dataDelegate createLabelFor:contentIndex frame:frame title:title];
    else
        result = [self doCreateLabelFor:contentIndex frame:frame title:title];
    return result;
}

- (void) postProcessLabel:(UILabel *)aLabel
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
    [self postProcessLabel:label contentIndex:contentIndex frame:frame];
    return label;
}


- (void) doloadPage:(int)contentIndex inView:(UIView *)container frame:(CGRect)frame {
    //CGRect r = CGRectMake(0, 0, size.width, size.height);
    
    DPDataElement *element = self.contentList[contentIndex];
    
    // add imageview
    UIView *aView = [self createViewFor:contentIndex frame:frame];
    if ([aView isKindOfClass:[UIImageView class]])
        [self loadImageFor:element inView:(UIImageView *)aView];

    // add label
    UILabel *lblView = [self createLabelFor:contentIndex frame:frame title:element.title];
    
    // insert image and label in the view
    [container addSubview:aView];
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
        NSLog(@"Clicked image at index %i named %@", indx, element.title);
        
        [self invokeViewDelegate:sender element:element];
        
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
    
//    NSLog(@"onTimer - time: %@", [dateFormatter stringFromDate:[NSDate date]]);
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

#pragma mark - loading of image data

- (BOOL) isLocalUrl:(NSString *)urlstr {
    NSURL *url = [NSURL URLWithString:urlstr];
    return url.isFileReferenceURL || url.host == nil;
}

- (void) startIndicator {
    if(!self.busyIndicator) {
		self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.busyIndicator.frame = CGRectMake((self.view.frame.size.width-25)/2,
                                              (self.view.frame.size.height-25)/2,
                                              25, 25);
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self.view addSubview:self.busyIndicator];
	}
    
    if (!self.busyIndicator.isAnimating)
        [self.busyIndicator startAnimating];
}

- (void) stopIndicator {
    if (self.busyIndicator &&
        self.downloadQueue &&
        self.downloadQueue.operationCount == 0) {
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        self.busyIndicator = nil;
    }
}

- (void) fix:(DPDataElement *)elm
   imageView:(UIImageView *)imgView
   imageUrl:(NSString *)imageUrl
        data:(NSData *)imgData
  addToCache:(BOOL)addToCache{
    //elm.imageData = [request responseData];
    imgView.image = [UIImage imageWithData:imgData];
    if (addToCache)
        [[DPAppHelper sharedInstance] saveImageToCache:imageUrl data:imgData];
}

//PENDING : i think i must pass just the elm.imageUrl not the calced name!!!!
// in the whole async process!!!!
- (void) loadImageAsync:(DPDataElement *)elm inView:(UIImageView *)imgView cacheImage:(BOOL)cacheimage{
    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
    NSData *imgData = [appHelper loadImageFromCache:[self calcImageName: elm.imageUrl]];
    if (imgData) 
        [self fix:elm imageView:imgView imageUrl:[self calcImageName: elm.imageUrl] data:imgData addToCache:NO];
    else
        [self doloadImageAsync:elm inView:imgView cacheImage:cacheimage];
}

- (void) doloadImageAsync:(DPDataElement *)elm inView:(UIImageView *)imgView cacheImage:(BOOL)cacheimage{
    if (!self.downloadQueue)
        self.downloadQueue = [[NSOperationQueue alloc] init];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self calcImageName:elm.imageUrl]]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        elm, @"element",
                        imgView, @"imageView",
                        [self calcImageName:elm.imageUrl], @"imageUrl",
                        [NSNumber numberWithBool:cacheimage], @"cacheimage",
                        nil];
    [self.downloadQueue addOperation:request];

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
	NSLog(@"Request Failed: %@", [request error]);    
}

@end
