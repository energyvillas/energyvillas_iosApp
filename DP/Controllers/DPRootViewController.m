//
//  DPRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPRootViewController.h"
#import "DPTestViewController.h"
//#import "../External/ImageHelper/ImageResizing.h"
#import "../External/OpenFlow/UIImageExtras.h"
#import "DPScrollableDetailViewController.h"

@interface DPRootViewController ()
@property (nonatomic, readonly, getter = getOpenFlowContainerView) UIView *openFlowContainerView;
@property (nonatomic, readonly, getter = getBottomContainerView) UIView *bottomContainerView;
//@property (nonatomic, strong) AFOpenFlowView *openFlow;
@property int currentIndex;
//@property (readonly, getter = getIsPortrait) bool isPortrait;

@property bool isPortrait;
@end

@implementation DPRootViewController

@synthesize landscapeView, portraitView;
@synthesize landscapeContainerView, portraitContainerView;
@synthesize /*openFlow, */openFlowContainerView;

@synthesize landscapeBottomView, portraitBottomView;
@synthesize bottomContainerView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.rotationDelegate = self;
        self.currentIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation {
    switch (toOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
//            self.view = landscapeView;
            self.isPortrait = NO;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
//            self.view = landscapeView;
            self.isPortrait = NO;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
//            self.view = portraitView;
            self.isPortrait = YES;
            break;
            
        case UIInterfaceOrientationPortrait:
//            self.view = portraitView;
            self.isPortrait = YES;
            break;
    }
        
    UIView *sv;
    if (self.view == self.navigationController.view)
        sv = self.view;
    else
        sv = self.navigationController.view;//self.view.superview;
    sv = self.view.superview;
    
    int h = sv.bounds.size.height;
    int w = sv.bounds.size.width;

    int BOTTOM_HEIGHT;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        BOTTOM_HEIGHT = (self.isPortrait) ? 214 : 107;
    else
        BOTTOM_HEIGHT = (self.isPortrait) ? 400 : 200;

    //self.view.frame = CGRectMake(0, 0, w, h);
    int toolbarHeight = self.toolbar.frame.size.height;
    int topHeight = h - toolbarHeight - BOTTOM_HEIGHT;
    self.portraitContainerView.frame = CGRectMake(0, 0, w, topHeight);
    self.toolbar.frame = CGRectMake(0, topHeight, w, toolbarHeight);
    self.portraitBottomView.frame = CGRectMake(0, topHeight + toolbarHeight, w, BOTTOM_HEIGHT);

    [self loadOpenFlow];
    [self loadDetailView];
    
}
/*
- (bool) getIsPortrait {
    return self.view != landscapeView;
}
*/

- (UIView *) getBottomContainerView {
    UIView *ofv = (UIView *)
    (self.view == portraitView ? portraitBottomView
     : self.view == landscapeView ? landscapeBottomView : nil);
    
    return ofv;
}
/*
- (void) loadDetailView {
    UIView *bcv = self.bottomContainerView;
    if (bcv && bcv.subviews.count == 0) {
        DPScrollableDetailViewController *detailViewController;
        
        NSMutableArray *content = [[NSMutableArray alloc] init];
        for (int i = 0; i<8; i++)
            [content addObject:[self imageForIndex:i+5]];
        
        if (self.isPortrait)
            detailViewController = [[DPScrollableDetailViewController alloc]
                                    initWithContent:content rows:2 columns:2];
        else
            detailViewController = [[DPScrollableDetailViewController alloc]
                                    initWithContent:content rows:1 columns:3];
        
        content = nil;
        
        [self addChildViewController: detailViewController];
        [bcv addSubview: detailViewController.view];
        detailViewController = nil;
    }
}
 */

- (void) loadDetailView {
    UIView *bcv = self.portraitBottomView;
    if (bcv == nil) return;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)", bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);

    DPScrollableDetailViewController *detvc;
    if (bcv.subviews.count == 0) {
        NSMutableArray *content = [[NSMutableArray alloc] init];
        for (int i = 0; i<8; i++)
            [content addObject:[self imageForIndex:i+5]];
        
        if (self.isPortrait)
            detvc = [[DPScrollableDetailViewController alloc]
                     initWithContent:content rows:2 columns:2];
        else
            detvc = [[DPScrollableDetailViewController alloc]
                     initWithContent:content rows:1 columns:3];
        
        content = nil;
        
        [self addChildViewController: detvc];
        [bcv addSubview: detvc.view];
        
        detvc = nil;
    } else {
        detvc = (DPScrollableDetailViewController *)self.childViewControllers[0];
        if (self.isPortrait) {
            [detvc reInitWithRows:2 columns:2];
        } else {
            [detvc reInitWithRows:1 columns:3];
        }
        
    }
}


- (UIView *) getOpenFlowContainerView {
    UIView *ofv = (UIView *)
    (self.view == portraitView ? portraitContainerView
     : self.view == landscapeView ? landscapeContainerView : nil);
    
    return ofv;
}
/*
- (void) loadOpenFlow {
    UIView *ofvc = self.openFlowContainerView;
    AFOpenFlowView *ofv = nil;
    if (ofvc) {
        if (ofvc.subviews.count == 0) {
            ofv = [[AFOpenFlowView alloc] initWithFrame:ofvc.bounds];
            ofv.viewDelegate = self;
            ofv.dataSource = self;
            
            [ofvc addSubview:ofv];
            
            int imgCount = 30;
            int imgBase = 1;
            for (int i=imgBase; i < imgCount; i++) {
                [ofv setImage:[self imageForIndex:i-imgBase] forIndex:i-imgBase];
            }
            
            [ofv setNumberOfImages:imgCount-imgBase];
            if (self.currentIndex != -1)
                [ofv setSelectedCover: self.currentIndex];
        }
        else {
            ofv = ofvc.subviews[0];
            if (self.currentIndex != -1)
                [ofv setSelectedCover: self.currentIndex];
        }
        [ofv centerOnSelectedCover:YES];
    }
}
*/
- (void) loadOpenFlow {
    UIView *ofvc = self.portraitContainerView;
    AFOpenFlowView *ofv = nil;
    if (ofvc) {
        
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
            
            int imgCount = 30;
            int imgBase = 1;
            for (int i=imgBase; i < imgCount; i++) {
                [ofv setImage:[self imageForIndex:i-imgBase] forIndex:i-imgBase];
            }
            
            [ofv setNumberOfImages:imgCount-imgBase];
            if (self.currentIndex != -1)
                [ofv setSelectedCover: self.currentIndex];
        }
        else {
            ofv = ofvc.subviews[0];
            if (self.currentIndex != -1)
                [ofv setSelectedCover: self.currentIndex];
        }
        //[ofv centerOnSelectedCover:YES];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    UIView *ofvc = self.portraitContainerView;
    AFOpenFlowView *ofv = nil;
    if (ofvc) {
        if (ofvc.subviews.count != 0) {
            ofv = ofvc.subviews[0];
            if (self.currentIndex != -1)
                [ofv setSelectedCover: self.currentIndex];
            [ofv centerOnSelectedCover:YES];
        }
    }
}

- (UIImage *) imageForIndex:(int) indx {
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indx]];
//    float h = self.isPortrait
//    ? portraitContainerView.bounds.size.height
//    : landscapeContainerView.bounds.size.height;
    //float w = img.size.width * h / img.size.height;

    float coeff = 1.0;
    float vh = portraitContainerView.frame.size.height;
    float vw = portraitContainerView.frame.size.width;
    float ih = img.size.height;
    float iw = img.size.width;
    if (iw/vw > ih/vh)
        coeff = (vw / iw);
    else
        coeff = (vh / ih);
    
    if (coeff > 1.5) coeff = 1.5;
    
    ih = ih * coeff;
    iw = iw * coeff;
    
    NSLog(@"scaling image %d.jpg from (%f, %f) => (%f, %f)", indx, img.size.width, img.size.height, 0.8*iw, 0.8*ih);
//    return [img scaleToSize:CGSizeMake(0.8 * iw, 0.8 * ih)];
    return [img rescaleImageToSize:CGSizeMake(iw, ih)];

}

// protocol AFOpenFlowViewDelegate
- (void) openFlowView:(AFOpenFlowView *)openFlowView click:(int)index {
    NSLog(@"Clicked image at index %i", index);
    
    // navigation logic goes here. create and push a new view controller;
    DPTestViewController *vc = [[DPTestViewController alloc] init];
    [self.navigationController pushViewController: vc animated: YES];
    vc = nil;
}

- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
    self.currentIndex = index;
}


// protocol AFOpenFlowViewDatasource
- (void) openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
    
}

- (UIImage *) defaultImage {
    return [UIImage imageNamed:@"1.jpg"];
}


- (void)viewDidUnload {
    [self setPortraitView:nil];
    [self setLandscapeView:nil];
    [self setPortraitContainerView:nil];
    [self setLandscapeContainerView:nil];
    [self setPortraitBottomView:nil];
    [self setLandscapeBottomView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}
@end
