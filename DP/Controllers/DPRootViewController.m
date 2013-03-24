//
//  DPRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPRootViewController.h"
#import "DPTestViewController.h"
#import "../External/OpenFlow/UIImageExtras.h"
//#import "DPScrollableDetailViewController.h"
#import "../Classes/DPImageInfo.h"
#import "DPCtgScrollViewController.h"
#import "../Classes/DPImageContentViewController.h"

@interface DPRootViewController ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation {
    switch (toOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            isPortrait = NO;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = NO;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            isPortrait = YES;
            break;
            
        case UIInterfaceOrientationPortrait:
            isPortrait = YES;
            break;
    }
        
    UIView *sv;
    sv = self.view.superview;
    
    int h = sv.bounds.size.height;
    int w = sv.bounds.size.width;

    int BOTTOM_HEIGHT;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        BOTTOM_HEIGHT = (isPortrait) ? 214 : 107;
    else
        BOTTOM_HEIGHT = (isPortrait) ? 400 : 200;

    //self.view.frame = CGRectMake(0, 0, w, h);
    int toolbarHeight = self.toolbar.frame.size.height;
    int topHeight = h - toolbarHeight - BOTTOM_HEIGHT;
    self.topView.frame = CGRectMake(0, 0, w, topHeight);
    self.toolbar.frame = CGRectMake(0, topHeight, w, toolbarHeight);
    self.bottomView.frame = CGRectMake(0, topHeight + toolbarHeight, w, BOTTOM_HEIGHT);

    [self loadOpenFlow];
    [self loadDetailView];
    
}

- (void) loadDetailView {
    UIView *bcv = self.bottomView;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)", bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);

    //DPScrollableDetailViewController *detvc;
    DPCtgScrollViewController *detvc;
    if (bcv.subviews.count == 0) {
        NSMutableArray *content = [[NSMutableArray alloc] init];
        for (int i = 0; i<8; i++)
            [content addObject:[[DPImageInfo alloc]
                                initWithName:[NSString stringWithFormat:@"%d.jpg", i+5]
                                image:[self imageForIndex:i+5 withFrame:nil]]];
        
        if (isPortrait)
            detvc = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:2 columns:2];
        else
            detvc = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:1 columns:3];
        
        content = nil;
        
        [self addChildViewController: detvc];
        [bcv addSubview: detvc.view];
        
        detvc = nil;
    } else {
        detvc = (DPCtgScrollViewController *)self.childViewControllers[0];
        if (isPortrait) {
            [detvc changeRows:2 columns:2];
        } else {
            [detvc changeRows:1 columns:3];
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
            
        int imgCount = 30;
        int imgBase = 1;
        CGRect topFrame = topView.frame;
        for (int i=imgBase; i < imgCount; i++)
            [ofv setImage:[self imageForIndex:i-imgBase withFrame:&topFrame] forIndex:i-imgBase];
            
        [ofv setNumberOfImages:imgCount-imgBase];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
    }
    else {
        ofv = ofvc.subviews[0];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    UIView *ofvc = self.topView;
    AFOpenFlowView *ofv = nil;

    if (ofvc.subviews.count != 0) {
        ofv = ofvc.subviews[0];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
        [ofv centerOnSelectedCover:YES];
    }
}

- (UIImage *) imageForIndex:(int) indx withFrame:(CGRect *) targetFrame {
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indx]];

    if (targetFrame == nil) return img;
    
    float coeff = 1.0;
    float vh = (*targetFrame).size.height;
    float vw = (*targetFrame).size.width;
    float ih = img.size.height;
    float iw = img.size.width;
    if (iw/vw > ih/vh)
        coeff = (vw / iw);
    else
        coeff = (vh / ih);
    
    if (coeff > 1.5) coeff = 1.5;
    
    ih = ih * coeff;
    iw = iw * coeff;
    
    NSLog(@"scaling image %d.jpg from (%f, %f) => (%f, %f)", indx, img.size.width, img.size.height, iw, ih);
    return [img rescaleImageToSize:CGSizeMake(iw, ih)];
}

// protocol AFOpenFlowViewDelegate
- (void) openFlowView:(AFOpenFlowView *)openFlowView click:(int)index {
    NSLog(@"Clicked image at index %i", index);
    
    // navigation logic goes here. create and push a new view controller;
    //DPTestViewController *vc = [[DPTestViewController alloc] init];
    //[self.navigationController pushViewController: vc animated: YES];
    //
    /*
    DPCtgScrollViewController *detvc;

    NSMutableArray *content = [[NSMutableArray alloc] init];
    for (int i = 0; i<8; i++)
        [content addObject:[[DPImageInfo alloc]
                            initWithName:[NSString stringWithFormat:@"%d.jpg", i+5]
                            image:[self imageForIndex:i+5 withFrame:nil]]];

    detvc = [[DPCtgScrollViewController alloc]
                    initWithContent:content rows:1 columns:1];
    */
/*
 CGRect aframe = CGRectMake(0, 0,
                               self.view.superview.bounds.size.width,
                               self.view.superview.bounds.size.height) ;
*/
    DPImageContentViewController *vc = [[DPImageContentViewController alloc] initWithImageName:[NSString stringWithFormat:@"%d.jpg", index]];
/*
    vc.view = [[UIView alloc] initWithFrame:aframe];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:aframe];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.userInteractionEnabled = YES;
    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", index]];
    [vc.view addSubview: imgView];
*/    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
    currentIndex = index;
}


// protocol AFOpenFlowViewDatasource
- (void) openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
    
}

- (UIImage *) defaultImage {
    return [UIImage imageNamed:@"0.jpg"]; // thi should return the missing image replacement
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
