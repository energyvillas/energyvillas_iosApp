//
//  DPRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPRootViewController.h"
#import "DPTestViewController.h"

@interface DPRootViewController ()
@property (weak, nonatomic, readonly, getter = getOpenFlowView) UIView *openFlowView;
@property (nonatomic, strong) AFOpenFlowView *openFlow;
@end

@implementation DPRootViewController

@synthesize landscapeView, portraitView, landscapecontainerView, portraitContainerView, openFlow, openFlowView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.rotationDelegate = self;
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
}

- (UIView *) getOpenFlowView {
    UIView *ofv = (UIView *)
    (self.view == portraitView ? portraitContainerView
     : self.view == landscapeView ? landscapecontainerView : nil);
    
    return ofv;
}

- (void) loadOpenFlow {
    
    UIView *ofvc = self.openFlowView;
    if (ofvc) {
        if (ofvc.subviews.count == 0) {            
            if (openFlow == nil) {
                openFlow = [[AFOpenFlowView alloc] initWithFrame:ofvc.bounds];
                openFlow.viewDelegate = self;
                openFlow.dataSource = self;
                
                [ofvc addSubview:openFlow];
                
                NSString *imageName;
                int imgCount = 30;
                
                for (int i=0; i < imgCount; i++) {
                    imageName = [[NSString alloc] initWithFormat:@"%d.jpg", i];
                    [openFlow setImage: [UIImage imageNamed:imageName] forIndex:i];
                    imageName = nil;
                }
                
                [openFlow setNumberOfImages:imgCount];
            }
            else {
                [ofvc addSubview:openFlow];
                openFlow.frame = ofvc.bounds;
            }
        }
        
    }
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
    
}


// protocol AFOpenFlowViewDatasource
- (void) openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
    
}

- (UIImage *) defaultImage {
    return [UIImage imageNamed:@"3.jpg"];
}


- (void)viewDidUnload {
    [self setPortraitView:nil];
    [self setLandscapeView:nil];
    [self setPortraitContainerView:nil];
    [self setLandscapecontainerView:nil];
    [super viewDidUnload];
}
@end
