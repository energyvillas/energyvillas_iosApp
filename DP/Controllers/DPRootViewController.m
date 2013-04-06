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
#import "DPCtgScrollViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "DPConstants.h"
#import "DPVimeoPlayerViewController.h"
//#import "DPIAPHelper.h"
#import "DPAppHelper.h"
#import "DPMainViewController.h"
#import "DPBuyViewController.h"
#import "Article.h"



@interface DPRootViewController ()

@property (strong, nonatomic) NSMutableDictionary *coverFlowDict;

@end

@implementation DPRootViewController {
    int currentIndex;
    bool isPortrait;
}

@synthesize topView, toolbar, bbiBuy, bbiMore, bottomView;


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

- (void) doBuy:(id) sender {
    DPBuyViewController *buyVC = [[DPBuyViewController alloc] init];

    id del = self.navigationController.delegate;
    DPMainViewController *main = del;

    [main addChildViewController:buyVC];
    [main.view addSubview:buyVC.view];
}

- (void) doMore:(id) sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation fixtop:(BOOL)fixtop{
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
//    CGRect svf = self.view.superview.frame;
    
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
    
    self.bottomView.frame = CGRectMake(0, top + topHeight + toolbarHeight,
                                       w, BOTTOM_HEIGHT);

    [self loadOpenFlow];
    [self loadDetailView:NO];
}

- (void) loadDetailView:(BOOL)reload{
    UIView *bcv = self.bottomView;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)", bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);

    DPCtgScrollViewController *detvc;
    if (reload && bcv.subviews.count > 0) {
        detvc = (DPCtgScrollViewController *)self.childViewControllers[0];
        [detvc.view removeFromSuperview];
        [detvc removeFromParentViewController];
        detvc = nil;
    }        
    
    if (bcv.subviews.count == 0) {
        NSArray *content = [[DPAppHelper sharedInstance] freeDetailsFor:[DPAppHelper sharedInstance].currentLang];
        if (isPortrait)
            detvc = [[DPCtgScrollViewController alloc] 
                     initWithContent:content rows:2 columns:2 autoScroll:YES];
        else
            detvc = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:1 columns:4 autoScroll:YES];
        
        
        [self addChildViewController: detvc];
        [bcv addSubview: detvc.view];
        
        detvc = nil;
    } else {
        detvc = (DPCtgScrollViewController *)self.childViewControllers[0];
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
    
    NSLog(@"ofvc frame : (x, y, w, h) = (%f, %f, %f, %f)", ofvc.frame.origin.x, ofvc.frame.origin.y, ofvc.frame.size.width, ofvc.frame.size.height);

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
    NSLog(@"Clicked image at index %i", index);
    
    Article *article = [self currlangCoverFlow][index];

    if (article.videoUrl == nil) {
        DPImageContentViewController *vc = [[DPImageContentViewController alloc]
                                            initWithImageName:article.imageUrl];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSString *videourl = article.videoUrl;
        DPVimeoPlayerViewController *vimeo = [[DPVimeoPlayerViewController alloc]
                                              initWithUrl:videourl];
        [self.navigationController pushViewController:vimeo animated:YES];
    }
    
/*
    // navigation logic goes here. create and push a new view controller;
    DPImageContentViewController *vc = [[DPImageContentViewController alloc]
                                        initWithImageName:[NSString stringWithFormat:@"%d.jpg", index]];
    [self.navigationController pushViewController:vc animated:YES];
*/

//    DPVimeoPlayerViewController *vimeo = [[DPVimeoPlayerViewController alloc] 
//                                          initWithUrl:@"http://vimeo.com/58323794"];
//    [self.navigationController pushViewController:vimeo animated:YES];
}

- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
    currentIndex = index;
}

// protocol AFOpenFlowViewDatasource
- (void) openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
    Article *article = [self currlangCoverFlow][index];
    CGRect frm = topView.frame;
    UIImage *img = [self imageNamed:article.imageUrl withFrame:&frm];
    [openFlowView setImage:img forIndex:index];
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
    [super viewDidUnload];
}

@end
