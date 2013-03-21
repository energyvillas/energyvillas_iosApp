//
//  DPRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPRootViewController.h"
#import "DPTestViewController.h"
#import "../External/ImageHelper/ImageResizing.h"
#import "DPScrollableDetailViewController.h"

@interface DPRootViewController ()
@property (weak, nonatomic, readonly, getter = getOpenFlowContainerView) UIView *openFlowContainerView;
@property (weak, nonatomic, readonly, getter = getBottomContainerView) UIView *bottomContainerView;
//@property (nonatomic, strong) AFOpenFlowView *openFlow;
@property int currentIndex;
@property (readonly, getter = getIsPortrait) bool isPortrait;
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
            self.view = landscapeView;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            self.view = landscapeView;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            self.view = portraitView;
            break;
            
        case UIInterfaceOrientationPortrait:
            self.view = portraitView;
            break;
    }
    
    [self loadOpenFlow];
    [self loadDetailView];
}

- (bool) getIsPortrait {
    return self.view != landscapeView;
}


- (UIView *) getBottomContainerView {
    UIView *ofv = (UIView *)
    (self.view == portraitView ? portraitBottomView
     : self.view == landscapeView ? landscapeBottomView : nil);
    
    return ofv;
}

- (void) loadDetailView {
	DPScrollableDetailViewController *detailViewController = [[DPScrollableDetailViewController alloc] init];
    NSMutableArray *content = [[NSMutableArray alloc] init];
    for (int i = 0; i<8; i++)
        [content addObject:[self imageForIndex:i+5]];
	detailViewController.contentList = content;
    content = nil;
	detailViewController.currentPage = 0;
    detailViewController.rowCount = 2;
    detailViewController.colCount = 2;
    int h = self.bottomContainerView.bounds.size.height;
    int w = self.bottomContainerView.bounds.size.width;
    detailViewController.view.frame = CGRectMake(0, 0, w, h);
    detailViewController.view.bounds = CGRectMake(0, 0, w, h);
    
    [self addChildViewController: detailViewController];
    [self.bottomContainerView addSubview: detailViewController.view];
	detailViewController = nil;
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
    if (ofvc) {
        if (ofvc.subviews.count == 0) {
            if (openFlow == nil) {
                openFlow = [[AFOpenFlowView alloc] initWithFrame:ofvc.bounds];
                openFlow.viewDelegate = self;
                openFlow.dataSource = self;
                
                [ofvc addSubview:openFlow];
                
                int imgCount = 30;
                int imgBase = 1;
                for (int i=imgBase; i < imgCount; i++) {
                    [openFlow setImage:[self imageForIndex:i-imgBase] forIndex:i-imgBase];
                }
                
                [openFlow setNumberOfImages:imgCount];
                [openFlow setSelectedCover: 5];
            }
            else {
                [ofvc addSubview:openFlow];
                openFlow.frame = ofvc.bounds;
                openFlow.bounds = ofvc.bounds;
                
            }
        }
    }
}
*/
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

- (UIImage *) imageForIndex:(int) indx {
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indx]];
    float h = self.isPortrait
        ? portraitContainerView.bounds.size.height
        : landscapeContainerView.bounds.size.height;
    float w = img.size.width * h / img.size.height;
    return [img scaleToSize:CGSizeMake(w, h)];
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
    [super viewDidUnload];
}
@end
