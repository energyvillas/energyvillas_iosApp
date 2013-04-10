//
//  DPRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPRootViewController.h"
#import "../External/OpenFlow/UIImageExtras.h"
//#import "../Classes/DPImageInfo.h"
//#import "DPCtgScrollViewController.h"
#import "DPCategoriesViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "DPConstants.h"
#import "DPVimeoPlayerViewController.h"
//#import "DPIAPHelper.h"
#import "DPAppHelper.h"
#import "DPMainViewController.h"
#import "DPBuyViewController.h"
#import "Article.h"
#import "DPCategoryLoader.h"



@interface DPRootViewController ()

@property (strong, nonatomic) NSMutableDictionary *coverFlowDict;

@end

@implementation DPRootViewController {
    int currentIndex;
    bool isPortrait;
}

@synthesize topView, toolbar, bbiBuy, bbiMore, bottomView;

- (id) init {
    self = [super init];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self doLocalize];
    [bbiMore setAction:@selector(doMore:)];
    [bbiBuy setAction:@selector(doBuy:)];
}

- (void) doLocalize {
    [super doLocalize];
    bbiMore.title = DPLocalizedString(kbbiMore_Title);
    bbiBuy.title = DPLocalizedString(kbbiBuy_Title);
    
    if (self.bottomView.subviews.count > 0) {
        [self loadDetailView:YES];
        [self loadOpenFlow];
    }
}

//- (BOOL) isBuyRunning {
//    id del = self.navigationController.delegate;
//    DPMainViewController *main = del;
//    
//    BOOL isRunning = NO;
//    for (id vc in main.childViewControllers)
//        if ([vc isMemberOfClass:[DPBuyViewController class]]) {
//            isRunning = YES;
//            break;
//        }
//    return isRunning;
//}

- (void) showBuyDialog:(int)ctgId {
//    if ([self isBuyRunning]) return;

    id del = self.navigationController.delegate;
    DPMainViewController *main = del;
    
    DPBuyViewController *buyVC = [[DPBuyViewController alloc]
                                  initWithCategoryId:ctgId
                                  completion:^{
                                      self.view.userInteractionEnabled = YES;
                                  }];
    
//    buyVC.modalPresentationStyle = UIModalPresentationCurrentContext;
//    [self presentViewController:buyVC animated:YES];
    
    self.view.userInteractionEnabled = NO;

    [main addChildViewController:buyVC];
    [main.view addSubview:buyVC.view];
}

- (void) doBuy:(id) sender {
    [self showBuyDialog:-1];
}

- (void) doMore:(id) sender {
//    if ([self isBuyRunning]) return;

    // do the more stuff here
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillLayoutSubviews {
    switch (INTERFACE_ORIENTATION) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = NO;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            isPortrait = YES;
            break;
    }
    
    CGRect vf = self.view.frame;
    
    int h = isPortrait ? vf.size.height : vf.size.height - vf.origin.y ;
    int w = vf.size.width;
    int top = 0; //fixtop ? vf.origin.y : 0;
    

//    int carouselHeight = 0;
//    int toolbarHeight = self.toolbar.bounds.size.height;
//    int detailsHeight = 0;
//    
//    if (IS_IPHONE) {
//        carouselHeight = (isPortrait) ? 202 : 148;
//        detailsHeight = (isPortrait) ? 170 : 64;
//    } else if (IS_IPHONE_5) {
//        carouselHeight = (isPortrait) ? 290 : 137;
//        detailsHeight = (isPortrait) ? 170 : 75;
//    } else if (IS_IPAD) {
//        carouselHeight = (isPortrait) ? 508 : 524;
//        detailsHeight = (isPortrait) ? 408 : 136;
//    }
//
//    self.topView.frame = CGRectMake(0, top, w, carouselHeight);
//    
//    self.toolbar.frame = CGRectMake(0, top + carouselHeight,
//                                    w, toolbarHeight);
//    
//    self.toolbarBackView.frame = self.toolbar.frame;
//    
//    self.bottomView.frame = CGRectMake(0, top + carouselHeight + toolbarHeight,
//                                       w, detailsHeight);
  
//////////////////////
    
    int toolbarHeight = self.toolbar.frame.size.height;

    int BOTTOM_HEIGHT;
    if (IS_IPHONE)
        BOTTOM_HEIGHT = (isPortrait) ? 170 : 64;
    else if (IS_IPHONE_5)
        BOTTOM_HEIGHT = (isPortrait) ? 170 : 75;
    else // if (IS_IPAD)
        BOTTOM_HEIGHT = (isPortrait) ? 408 : 136;//340 : 114;
    
    //self.view.frame = CGRectMake(0, 0, w, h);
    int topHeight = h - toolbarHeight - BOTTOM_HEIGHT;
    
    self.topView.frame = CGRectMake(0, top, w, topHeight);
    
    self.toolbar.frame = CGRectMake(0, top + topHeight,
                                    w, toolbarHeight);
//    self.toolbarBackView.frame = self.toolbar.frame;
    
    self.bottomView.frame = CGRectMake(0, top + topHeight + toolbarHeight,
                                       w, BOTTOM_HEIGHT);
    
    [self loadOpenFlow];
    [self loadDetailView:NO];

}
- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation fixtop:(BOOL)fixtop{
    return;
    
    
    switch (toOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = NO;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            isPortrait = YES;
            break;
    }

    CGRect vf = self.view.frame;
//    CGRect vf = self.view.superview.frame;
    
    int h = isPortrait ? vf.size.height : vf.size.height - vf.origin.y ;
    int w = vf.size.width;    
    int top = fixtop ? vf.origin.y : 0;    

    int BOTTOM_HEIGHT;
    if (IS_IPHONE) 
        BOTTOM_HEIGHT = (isPortrait) ? 170 : 64;
    else if (IS_IPHONE_5)
        BOTTOM_HEIGHT = (isPortrait) ? 170 : 72;
    else // if (IS_IPAD)
        BOTTOM_HEIGHT = (isPortrait) ? 408 : 136;//340 : 114;

    //self.view.frame = CGRectMake(0, 0, w, h);
    int toolbarHeight = self.toolbar.frame.size.height;
    int topHeight = h - toolbarHeight - BOTTOM_HEIGHT;
    
    self.topView.frame = CGRectMake(0, top, w, topHeight);
    
    self.toolbar.frame = CGRectMake(0, top + topHeight,
                                    w, toolbarHeight);
//    self.toolbarBackView.frame = self.toolbar.frame;
    
    self.bottomView.frame = CGRectMake(0, top + topHeight + toolbarHeight,
                                       w, BOTTOM_HEIGHT);

    [self loadOpenFlow];
    [self loadDetailView:NO];
}

- (void) loadDetailView:(BOOL)reload{
    UIView *bcv = self.bottomView;
    
//    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)", bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);

    DPCategoriesViewController *detvc;
    if (reload && bcv.subviews.count > 0) {
        detvc = (DPCategoriesViewController *)self.childViewControllers[0];
        [detvc.view removeFromSuperview];
        [detvc removeFromParentViewController];
        detvc = nil;
    }        
    
    if (bcv.subviews.count == 0) {
        DPAppHelper *apphelper = [DPAppHelper sharedInstance];
        if (isPortrait)
            detvc = [[DPCategoriesViewController alloc] initWithCategory:-1
                                                                    lang:apphelper.currentLang
                                                           localResource:@"free-details.plist"
                                                                    rows:2
                                                                 columns:2
                                                              autoScroll:YES
                                                                  parent:self];
        else
            detvc = [[DPCategoriesViewController alloc] initWithCategory:-1
                                                                    lang:apphelper.currentLang
                                                           localResource:@"free-details.plist"
                                                                    rows:1
                                                                 columns:4
                                                              autoScroll:YES
                                                                  parent:self];
        
        
        [self addChildViewController: detvc];
        [bcv addSubview: detvc.view];
        
        detvc = nil;
    } else {
        detvc = (DPCategoriesViewController *)self.childViewControllers[0];
        if (isPortrait) {
            [detvc changeRows:2 columns:2];
        } else {
            [detvc changeRows:1 columns:4];
        }
        
    }
}

- (void) loadOpenFlow {
    UIView *ofvc = self.topView;
    AFOpenFlowView *ofv = nil;
    
//    NSLog(@"ofvc frame : (x, y, w, h) = (%f, %f, %f, %f)", ofvc.frame.origin.x, ofvc.frame.origin.y, ofvc.frame.size.width, ofvc.frame.size.height);

    ofv = ofvc.subviews.count == 0 ? nil : ofvc.subviews[0];
    if (ofv)
        [ofv removeFromSuperview];
    ofv = nil;

    if (ofvc.subviews.count == 0) {
        ofv = [[AFOpenFlowView alloc] initWithFrame:ofvc.frame];
        ofv.viewDelegate = self;
        ofv.dataSource = self;

        [ofvc addSubview:ofv];
        
        NSArray *langCoverFlow = [self currlangCoverFlow];
        
        [ofv setNumberOfImages:langCoverFlow.count];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
    }
    else {
        ofv = ofvc.subviews[0];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
    }
}

- (NSArray *) currlangCoverFlow {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];

    if (!self.coverFlowDict)
        self.coverFlowDict = [[NSMutableDictionary alloc] initWithCapacity:2];

    NSArray *langCoverFlow = self.coverFlowDict[apphelper.currentLang];
    if (!langCoverFlow) {
        langCoverFlow = [apphelper freeCoverFlowFor:apphelper.currentLang];
        [self.coverFlowDict setValue:langCoverFlow forKey:apphelper.currentLang];
    }
    
    return langCoverFlow;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIView *ofvc = self.topView;
    AFOpenFlowView *ofv = nil;

    if (ofvc.subviews.count != 0) {
        ofv = ofvc.subviews[0];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
        [ofv centerOnSelectedCover:YES];
    }
}

- (UIImage *) imageForIndex:(int)indx withFrame:(CGRect *) targetFrame {
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indx]];

    if (targetFrame == nil) return img;
    else return [self rescaleImage:img toFrame:targetFrame];
}

- (UIImage *) imageNamed:(NSString *)imgName withFrame:(CGRect *) targetFrame {
    UIImage *img = [UIImage imageNamed:imgName];
    
    if (targetFrame == nil) return img;
    else return [self rescaleImage:img toFrame:targetFrame];
}

-(UIImage *) rescaleImage:(UIImage *)image toFrame:(CGRect *) targetFrame {
//    float coeff = 1.0;
    float vh = (*targetFrame).size.height;
    float vw = (*targetFrame).size.width;
    float ih = image.size.height;
    float iw = image.size.width;
    
    float ir = ih / iw;
    float vr = vh / vw;
    if (vr < ir) {
        ih = vh;
        iw = ih / ir;
    } else {
        iw = vw;
        ih = iw * ir;
    }

    return [image rescaleImageToSize:CGSizeMake(iw, ih)];
}

// protocol AFOpenFlowViewDelegate
- (void) openFlowView:(AFOpenFlowView *)openFlowView click:(int)index {
//    if ([self isBuyRunning]) return;
    
    Article *article = [self currlangCoverFlow][index];

    if (article.videoUrl == nil) {
        DPImageContentViewController *vc = [[DPImageContentViewController alloc]
                                            initWithImageName:[self calcImageName:article.imageUrl]];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSString *videourl = article.videoUrl;
        DPVimeoPlayerViewController *vimeo = [[DPVimeoPlayerViewController alloc]
                                              initWithUrl:videourl];
        [self.navigationController pushViewController:vimeo animated:YES];
    }
}

- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
    currentIndex = index;
}

// protocol AFOpenFlowViewDatasource
- (void) openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
    Article *article = [self currlangCoverFlow][index];
//    CGRect frm = topView.frame;
//    UIImage *img = [self imageNamed:[self calcImageName:article.imageUrl] withFrame:&frm];
    NSString *imgName = [self calcImageName:article.imageUrl];
    UIImage *img = [UIImage imageNamed:imgName];
    
    [openFlowView setImage:img forIndex:index];
}

- (NSString *) calcImageName:(NSString *)baseName {
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *lang = @"el"; //[DPAppHelper sharedInstance].currentLang;
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            NSString *result = [NSString stringWithFormat:@"Carousel/%@_%@_%@.%@",
                                parts[0], lang, orientation, parts[1]];
            return result;
        }
        else
            return baseName;
    }
    @catch (NSException* exception) {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        return baseName;
    }
}

- (UIImage *) defaultImage {
    return nil; // thi should return the missing image replacement
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setBbiMore:nil];
    [self setBbiBuy:nil];
    [self setTopView:nil];
    [self setBottomView:nil];
//    [self setToolbarBackView:nil];
    [super viewDidUnload];
}

@end
