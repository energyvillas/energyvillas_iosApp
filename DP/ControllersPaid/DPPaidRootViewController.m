//
//  DPPaidRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPPaidRootViewController.h"
#import "../Classes/DPHtmlContentViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "../Controllers/DPCtgScrollViewController.h"
#import "../Classes/DPImageInfo.h"
#import "../External/OpenFlow/UIImageExtras.h"
#import "DPCategoryViewController.h"
#import "DPConstants.h"


@interface DPPaidRootViewController ()

@property (strong, nonatomic) UIViewController *whoViewController;
@property (strong, nonatomic) UIViewController *buyViewController;
@property (strong, nonatomic) UIViewController *callViewController;
@property (strong, nonatomic) UIViewController *moreViewController;

@property (strong, nonatomic) DPCtgScrollViewController *nnViewController;
@property (strong, nonatomic) DPCtgScrollViewController *mmViewController;

@property (strong, nonatomic) FPPopoverController *popoverController;
@property (strong, nonatomic) UIViewController *islandPopupViewController;
@property (strong, nonatomic) NSMutableArray *islandsContent;

@end

@implementation DPPaidRootViewController {
    //int currentIndex;
    bool isPortrait;
    
    int islands_count;
    int island_width;
    int island_height;
}

@synthesize whoViewController, buyViewController, callViewController, moreViewController;
@synthesize nnViewController, mmViewController;
@synthesize popoverController, islandPopupViewController, islandsContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation {
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
    
//    if (self.islandPopupViewController)
    self.islandPopupViewController = nil;
    self.islandsContent = nil;
    
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
    
    UIView *sv;
    sv = self.view.superview;
    
    int h = sv.bounds.size.height;
    int w = sv.bounds.size.width;
    
    // iphone sizes
    int PHONE_H_ADS = 60; // 44;
    int PHONE_H_NEW_NEXT = 92;// 100;
    
    int PHONE_HL_ADS = 60; // 44;
    int PHONE_WL_NEW_NEXT = 182;//203;//129; // 160;
    
    // iphone5 sizes
    int PHONE5_H_ADS = 60; // 44;
    int PHONE5_H_NEW_NEXT = 92;// 100;
    
    int PHONE5_HL_ADS = 60; // 44;
    int PHONE5_WL_NEW_NEXT = 210;//182;//203;//129; // 160;
    
    // ipad sizes
    int PAD_H_ADS = 120;
    int PAD_H_NEW_NEXT = 220;//198;//221;
    
    int PAD_HL_ADS = 120;
    int PAD_WL_NEW_NEXT = 468;//520;//463;
    
    
    // ph : 44, 100, 267
    // lh : 44, 207 (x2),
    // lw : , 160, 320,
    
    if (IS_IPHONE) {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, 0, w, PHONE_H_ADS);
            
            self.nnView.frame = CGRectMake(0, PHONE_H_ADS, w, PHONE_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, PHONE_H_ADS + PHONE_H_NEW_NEXT,
                                           w, h - PHONE_H_ADS - PHONE_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(PHONE_WL_NEW_NEXT, 0,
                                            w - PHONE_WL_NEW_NEXT, PHONE_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, 0, PHONE_WL_NEW_NEXT, h);
            
            self.mmView.frame = CGRectMake(PHONE_WL_NEW_NEXT, PHONE_HL_ADS,
                                           w - PHONE_WL_NEW_NEXT, h - PHONE_HL_ADS);
        }
    } else if (IS_IPHONE_5) {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, 0, w, PHONE5_H_ADS);
            
            self.nnView.frame = CGRectMake(0, PHONE5_H_ADS, w, PHONE5_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, PHONE5_H_ADS + PHONE5_H_NEW_NEXT,
                                           w, h - PHONE5_H_ADS - PHONE5_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(0, 0, w, PHONE5_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, PHONE5_HL_ADS,
                                           PHONE5_WL_NEW_NEXT, h - PHONE5_HL_ADS);
            
            self.mmView.frame = CGRectMake(PHONE5_WL_NEW_NEXT, PHONE5_HL_ADS,
                                           w - PHONE5_WL_NEW_NEXT, h - PHONE5_HL_ADS);
        }
    } else /* if (IS_IPAD) */ {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, 0, w, PAD_H_ADS);
            
            self.nnView.frame = CGRectMake(0, PAD_H_ADS,
                                           w, PAD_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, PAD_H_ADS + PAD_H_NEW_NEXT,
                                           w, h - PAD_H_ADS - PAD_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(0, 0, w, PAD_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, PAD_HL_ADS,
                                           PAD_WL_NEW_NEXT, h - PAD_HL_ADS);
            
            self.mmView.frame = CGRectMake(PAD_WL_NEW_NEXT, PAD_H_ADS,
                                           w - PAD_WL_NEW_NEXT, h - PAD_HL_ADS);
        }
    }
    
    [self loadNewNextView];
    [self loadMenuView];
}

- (void) loadNewNextView {
    UIView *bcv = self.nnView;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)",
          bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);
    
    if (bcv.subviews.count == 0) {
        NSMutableArray *content = [[NSMutableArray alloc] init];
        for (int i = 0; i < 2; i++) {
            DPImageInfo *ii = [[DPImageInfo alloc]
                               initWithName:[NSString stringWithFormat:@"%d.jpg", i+20]
                               image:[self imageForIndex:i+20 withFrame:nil]];
            [content addObject: ii];
        }
        
        if (isPortrait)
            nnViewController = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:1 columns:2];
        else
            nnViewController = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:2 columns:1];
        
        content = nil;
        
        [self addChildViewController: nnViewController];
        [bcv addSubview: nnViewController.view];
    } else {
        if (isPortrait) {
            [nnViewController changeRows:1 columns:2];
        } else {
            [nnViewController changeRows:2 columns:1];
        }
        
    }
}

- (void) elementTapped:(id)element {
    DPImageInfo *ii = element;
    if (ii == nil) return;
    
    switch (ii.tag) {
        case TAG_MM_ISLAND: {
            [self showIslandMenu];
            break;
        }
            
        case TAG_MM_EXCLUSIVE:
            
            break;
            
        case TAG_MM_SMART:
        case TAG_MM_LOFT:
        case TAG_MM_FINLAND:
        case TAG_MM_COUNTRY:
        case TAG_MM_CONTAINER:
        case TAG_MM_VILLAS: {
            DPCategoryViewController *ctgVC = [[DPCategoryViewController alloc] initWithCategory:ii.tag];
            [self.navigationController pushViewController:ctgVC animated:YES];
            
            break;
        }
            
        case TAG_MM_VIDEOS:
            
            break;
            
        case TAG_MM_ISLAND_AEGEAN:
            
            break;
            
        case TAG_MM_ISLAND_CYCLADIC:
            
            break;
            
        case TAG_MM_ISLAND_IONIAN:
            
            break;
            
        default:
            break;
    }
}

- (void) loadMenuView {
    UIView *bcv = self.mmView;
    
    NSLog(@"bvc frame : (x, y, w, h) = (%f, %f, %f, %f)",
          bcv.frame.origin.x, bcv.frame.origin.y, bcv.frame.size.width, bcv.frame.size.height);

    if (bcv.subviews.count == 0) {
        NSMutableArray *content = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++) {
            DPImageInfo *ii = [[DPImageInfo alloc]
                               initWithName:[NSString stringWithFormat:@"%d.jpg", i+11]
                               image:[self imageForIndex:i+11 withFrame:nil]];
            ii.tag = i + 100;
            [content addObject: ii];

        }
       
        mmViewController = [[DPCtgScrollViewController alloc]
                 initWithContent:content rows:3 columns:3];

        content = nil;
        mmViewController.viewDelegate = self;
        [self addChildViewController: mmViewController];
        [bcv addSubview: mmViewController.view];
    } else {
        [mmViewController changeRows:3 columns:3];
    }
}

- (UIView *) doCreateItem:(DPImageInfo *) ii tag:(int)indx{
    CGRect frm = CGRectMake(island_width * indx, 0, island_width, island_height);

    UIView *v = [[UIView alloc] initWithFrame: frm];
    v.clipsToBounds = YES;
    
    frm = CGRectMake(0, 0, island_width, island_height);
    UIImageView *iv = [[UIImageView alloc] initWithFrame: frm];
    iv.image = ii.image;
    iv.contentMode = UIViewContentModeScaleAspectFill; //UIViewContentModeScaleAspectFit;
    iv.tag = indx;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleIslandTap:)];
    [iv addGestureRecognizer:tapper];
    iv.userInteractionEnabled = YES;
    
    UILabel *lv = [[UILabel alloc] initWithFrame: frm];
    lv.textAlignment = NSTextAlignmentCenter;
    lv.adjustsFontSizeToFitWidth = YES;
    NSString *dl = ii.displayNname;
    lv.text = dl ? dl : ii.name;
    lv.backgroundColor = [UIColor clearColor];
    lv.textColor = [UIColor whiteColor];
    [lv sizeToFit];
    CGRect b = lv.bounds;
    frm = CGRectMake(frm.origin.x, frm.origin.y + frm.size.height - b.size.height,
                     frm.size.width, b.size.height);
    lv.frame = frm;
    
    [v addSubview:iv];
    [v addSubview:lv];
    
    return v;
}

- (void)handleIslandTap:(UITapGestureRecognizer *)sender {
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        int indx = sender.view.tag;
        DPImageInfo * ii = self.islandsContent[indx];
        NSLog(@"Clicked island image at index %i named %@ with tag %i", indx, ii.name, ii.tag);
        
        [self elementTapped:ii];
    }
}

-(id) doCreateIslandViewController {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.frame = CGRectMake(island_width * islands_count, 0, island_width, island_height);
    
    self.islandsContent = [[NSMutableArray alloc] init];
    
    CGRect imgfrm = CGRectMake(0, 0, island_width, island_height);
    for (int i = 0; i < islands_count; i++) {
        DPImageInfo *ii = [[DPImageInfo alloc]
                           initWithName:[NSString stringWithFormat:@"%d.jpg", i+11]
                           image:[self imageForIndex:i+11
                                                       withFrame:&imgfrm]];
        ii.tag = i + TAG_MM_ISLAND * TAG_MM_ISLAND_SHIFT;
        
        [self.islandsContent addObject: ii];
        [vc.view addSubview:[self doCreateItem:ii tag:i]];
    }
         
    return vc;
}

- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    
}

-(void) showIslandMenu {
    CGRect mmfrm = self.mmView.frame;
    islands_count = 3;
    island_width = mmfrm.size.width * 0.98 / 3;
    island_height = mmfrm.size.height * 0.98 / 3;
    
    //the view controller you want to present as popover
    if (!self.islandPopupViewController)
        self.islandPopupViewController = [self doCreateIslandViewController];
    
    self.islandPopupViewController.title = nil;

    //our popover
    self.popoverController = [[FPPopoverController alloc]
                                    initWithViewController:self.islandPopupViewController];
    self.popoverController.delegate = self;
    self.popoverController.border = NO;
    self.popoverController.contentSize = CGSizeMake(island_width * 3 + 20, island_height + 40);
    self.popoverController.arrowDirection = FPPopoverArrowDirectionVertical;
    
    //the popover will be presented to a point relative to mmview
    [self.popoverController presentPopoverFromPoint:CGPointMake(mmfrm.origin.x + mmfrm.size.width / 2 + 10,
                                                                mmfrm.origin.y + mmfrm.size.height * 0.5 / 3)];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAdsView:nil];
    [self setNnView:nil];
    [self setMmView:nil];
    [super viewDidUnload];
}
@end
