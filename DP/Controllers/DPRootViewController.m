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
#import "../Classes/DPImageInfo.h"
#import "DPCtgScrollViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "DPConstants.h"
#import "DPVimeoPlayerViewController.h"
//#import "DPIAPHelper.h"
#import "DPAppHelper.h"


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
    bbiMore.title = NSLocalizedString(kbbiMore_Title, nil);
    bbiBuy.title = NSLocalizedString(kbbiBuy_Title, nil);
    
    [bbiMore setAction:@selector(doMore:)];
    [bbiBuy setAction:@selector(doBuy:)];
}

- (void) doBuy:(id) sender {
//    SKProduct *product = [SKProduct alloc] init
//    [[DPIAPHelper sharedInstance] buyProduct:<#(SKProduct *)#>
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
    CGRect svf = self.view.superview.frame;
    
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
    [self loadDetailView];
    
}

- (void) loadDetailView {
    UIView *bcv = self.bottomView;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)", bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);

    DPCtgScrollViewController *detvc;
    if (bcv.subviews.count == 0) {
        
        /*
        NSMutableArray *content = [[NSMutableArray alloc] init];

        NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];

        for (int i = 0; i<8; i++)
            if (i == 0 || i == 1) {
                NSString *dispName = [NSString stringWithFormat: @"MENU_TITLE_10%i", i];
                [content addObject:[[DPImageInfo alloc]
                                    initWithName: [NSString stringWithFormat:@"00%d-%@.jpg", i+1, lang]
                                    image: [UIImage imageNamed:[NSString stringWithFormat:@"00%d-%@.jpg", i+1, lang]]
                                    displayName: NSLocalizedString(dispName, nil)]];
            } else
                [content addObject:[[DPImageInfo alloc]
                                    initWithName:[NSString stringWithFormat:@"%d.jpg", i+5]
                                    image:[self imageForIndex:i+5 withFrame:nil]]];
        */
        
        NSArray *content = [DPAppHelper sharedInstance].freeDetails;
        if (isPortrait)
            detvc = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:2 columns:2];
        else
            detvc = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:1 columns:4];
        
        
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
    
    ih = ih * coeff * 0.8;
    iw = iw * coeff * 0.8;
    
    NSLog(@"scaling image %d.jpg from (%f, %f) => (%f, %f)", indx, img.size.width, img.size.height, iw, ih);
    return [img rescaleImageToSize:CGSizeMake(iw, ih)];
}

// protocol AFOpenFlowViewDelegate
- (void) openFlowView:(AFOpenFlowView *)openFlowView click:(int)index {
    NSLog(@"Clicked image at index %i", index);
/*
    // navigation logic goes here. create and push a new view controller;
    DPImageContentViewController *vc = [[DPImageContentViewController alloc]
                                        initWithImageName:[NSString stringWithFormat:@"%d.jpg", index]];
    [self.navigationController pushViewController:vc animated:YES];
*/

    DPVimeoPlayerViewController *vimeo = [[DPVimeoPlayerViewController alloc] 
                                          initWithUrl:@"http://vimeo.com/58323794"];
    [self.navigationController pushViewController:vimeo animated:YES];
}

- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
    currentIndex = index;
}


// protocol AFOpenFlowViewDatasource
- (void) openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
    
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
