//
//  DPArticlesViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/23/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPArticlesViewController.h"
#import "DPiCarouselViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"

@interface DPArticlesViewController ()

@property (strong, nonatomic) UIView *container;
@end

@implementation DPArticlesViewController {
    int category;
    BOOL showSocials;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCategory:(int)ctgID  showSocials:(BOOL)aShowSocials{
    self = [super init];
    
    if (self) {
        category = ctgID;
        showSocials = aShowSocials;
    }
    
    return self;
}

- (void) dealloc {
    self.container = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.container = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.container];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doLocalize {
    [super doLocalize];

//    [self loadOpenFlow:YES];
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    
    self.container.frame = CGRectMake(0, top, w, h);
    
    [self loadOpenFlow:NO];
}

- (void) loadOpenFlow:(BOOL)reload {
    DPiCarouselViewController *carousel = nil;
    int currImgIndex = 0;
    for (int i = 0; i < self.childViewControllers.count; i++)
        if ([self.childViewControllers[i] isKindOfClass:[DPiCarouselViewController class]]) {
            carousel = (DPiCarouselViewController *)self.childViewControllers[i];
            currImgIndex = carousel.currentIndex;
            //            if (reload) {
            //                [carousel.view removeFromSuperview];
            //                [carousel removeFromParentViewController];
            //                carousel = nil;
            //            }
            break;
        }
    
    [self.container setNeedsDisplay];
    
    if (carousel != nil && carousel.carouselCategoryID != category) {
        [carousel.view removeFromSuperview];
        [carousel removeFromParentViewController];
        carousel = nil;
        currImgIndex = 0;
    }
    
    if (carousel == nil) {
        carousel = [[DPiCarouselViewController alloc] initWithCtg:category
                                                    currentIndex:currImgIndex
                                                     showSocials:showSocials];
        CGRect frm = self.container.bounds;
        carousel.view.frame = frm;
        [self addChildViewController:carousel];
        [self.container addSubview:carousel.view];
    } else {
        CGRect frm = self.container.bounds;
        carousel.view.frame = frm;
    }

    if (reload)
        [carousel reloadData];
    else
        [carousel makeCurrentImageAtIndex:currImgIndex];

}

@end
