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
#import "Article.h"
#import "DPImageInfo.h"
#import "../External/OpenFlow/UIImageExtras.h"
#import "DPCategoryViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"


@interface DPPaidRootViewController ()


@property (strong, nonatomic) DPCtgScrollViewController *nnViewController;
@property (strong, nonatomic) DPCtgScrollViewController *mmViewController;

@property (strong, nonatomic) FPPopoverController *popController;
@property (strong, nonatomic) UIViewController *islandPopupViewController;
@property (strong, nonatomic) NSArray *islandsContent;

@end

@implementation DPPaidRootViewController {
    //int currentIndex;
    bool isPortrait;
    
    int islands_count;
    int island_width;
    int island_height;
}


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

- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation fixtop:(BOOL)fixtop {
    // dismiss popover since the positioning will be wrong
    if (self.popController) {
        [self.popController dismissPopoverAnimated:YES];
        self.popController = nil;
    }
    
    self.islandPopupViewController = nil;
    self.islandsContent = nil;

    // handle orientation change
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
    
    // iphone sizes
    int PHONE_H_ADS = 60; 
    int PHONE_H_NEW_NEXT = 92;
    
    int PHONE_HL_ADS = 60; 
    int PHONE_WL_NEW_NEXT = 181;
    
    // iphone5 sizes
    int PHONE5_H_ADS = 60; 
    int PHONE5_H_NEW_NEXT = 92;
    
    int PHONE5_HL_ADS = 60; 
    int PHONE5_WL_NEW_NEXT = 210; //181
    
    // ipad sizes
    int PAD_H_ADS = 120;
    int PAD_H_NEW_NEXT = 221;
    
    int PAD_HL_ADS = 120;
    int PAD_WL_NEW_NEXT = 465;
    
    
    if (IS_IPHONE) {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, top, w, PHONE_H_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PHONE_H_ADS, w, PHONE_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, top + PHONE_H_ADS + PHONE_H_NEW_NEXT,
                                           w, h - PHONE_H_ADS - PHONE_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(PHONE_WL_NEW_NEXT, top,
                                            w - PHONE_WL_NEW_NEXT, PHONE_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, top, PHONE_WL_NEW_NEXT, h);
            
            self.mmView.frame = CGRectMake(PHONE_WL_NEW_NEXT, top + PHONE_HL_ADS,
                                           w - PHONE_WL_NEW_NEXT, h - PHONE_HL_ADS);
        }
    } else if (IS_IPHONE_5) {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, top, w, PHONE5_H_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PHONE5_H_ADS, w, PHONE5_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, top + PHONE5_H_ADS + PHONE5_H_NEW_NEXT,
                                           w, h - PHONE5_H_ADS - PHONE5_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(PHONE5_WL_NEW_NEXT, top,
                                            w - PHONE5_WL_NEW_NEXT, PHONE5_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, top,
                                           PHONE5_WL_NEW_NEXT, h);
            
            self.mmView.frame = CGRectMake(PHONE5_WL_NEW_NEXT, top + PHONE5_HL_ADS,
                                           w - PHONE5_WL_NEW_NEXT, h - PHONE5_HL_ADS);
        }
    } else /* if (IS_IPAD) */ {
        if (isPortrait) {
            self.adsView.frame = CGRectMake(0, top, w, PAD_H_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PAD_H_ADS,
                                           w, PAD_H_NEW_NEXT);
            
            self.mmView.frame = CGRectMake(0, top + PAD_H_ADS + PAD_H_NEW_NEXT,
                                           w, h - PAD_H_ADS - PAD_H_NEW_NEXT);
        } else {
            self.adsView.frame = CGRectMake(0, top, w, PAD_HL_ADS);
            
            self.nnView.frame = CGRectMake(0, top + PAD_HL_ADS,
                                           PAD_WL_NEW_NEXT, h - PAD_HL_ADS);
            
            self.mmView.frame = CGRectMake(PAD_WL_NEW_NEXT, top + PAD_H_ADS,
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
        DPAppHelper *apphelper = [DPAppHelper sharedInstance];
        for (int i = 0; i < 2; i++) {
            Article *article = [[Article alloc] initWithValues:[NSString stringWithFormat:@"%d", i]
                                                          lang:apphelper.currentLang
                                                      category:nil
                                                         title:nil
                                                      imageUrl:[NSString stringWithFormat:@"%d.jpg", i+20]
                                                          body:nil
                                                           url:nil
                                                   publishDate:nil
                                                      videoUrl:nil
                                                   videolength:nil];
            

            [content addObject: article];
        }
        
        if (isPortrait)
            self.nnViewController = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:1 columns:2 autoScroll:NO];
        else
            self.nnViewController = [[DPCtgScrollViewController alloc]
                     initWithContent:content rows:2 columns:1 autoScroll:NO];
        
        content = nil;
        
        [self addChildViewController: self.nnViewController];
        [bcv addSubview: self.nnViewController.view];
    } else {
        if (isPortrait) {
            [self.nnViewController changeRows:1 columns:2];
        } else {
            [self.nnViewController changeRows:2 columns:1];
        }
        
    }
}

- (void) elementTapped:(id)element {
    Article *article = element;
    if (article == nil) return;
    
    int ctgid = article.category.intValue;
    switch (ctgid) {
        case TAG_MM_ISLAND: {
            UIView *scrlv = self.mmViewController.view.subviews[0];
            [self showIslandMenu:scrlv.subviews[3] ofCategory:article.category.intValue];
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
            DPCategoryViewController *ctgVC = [[DPCategoryViewController alloc]
                                                initWithCategory:55];//article.category.intValue];
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
        DPAppHelper *apphelper = [DPAppHelper sharedInstance];
        NSArray *content = [apphelper paidArticlesOfCategory:-1
                                                        lang:apphelper.currentLang];
       
        self.mmViewController = [[DPCtgScrollViewController alloc]
                 initWithContent:content rows:3 columns:3 autoScroll:NO];

        content = nil;
        self.mmViewController.viewDelegate = self;
        [self addChildViewController: self.mmViewController];
        [bcv addSubview: self.mmViewController.view];
    } else {
        [self.mmViewController changeRows:3 columns:3];
    }
}

- (UIView *) doCreateItem:(Article *)article tag:(int)indx{
    CGRect frm = CGRectMake(island_width * indx, 0, island_width, island_height);

    UIView *v = [[UIView alloc] initWithFrame: frm];
    v.clipsToBounds = YES;
    
    frm = CGRectMake(0, 0, island_width, island_height);
    UIImageView *iv = [[UIImageView alloc] initWithFrame: frm];
    iv.image = [UIImage imageNamed: article.imageUrl];
    iv.contentMode = UIViewContentModeScaleAspectFill; //UIViewContentModeScaleAspectFit;
    iv.tag = indx;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleIslandTap:)];
    [iv addGestureRecognizer:tapper];
    iv.userInteractionEnabled = YES;
    
    UILabel *lv = [[UILabel alloc] initWithFrame: frm];
    lv.textAlignment = NSTextAlignmentCenter;
    if (IS_IPAD)
        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    else
        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    lv.adjustsFontSizeToFitWidth = YES;
    lv.text = article.title;
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
    [self.popController dismissPopoverAnimated:YES];
    self.popController = nil;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        int indx = sender.view.tag;
        Article *article = self.islandsContent[indx];
        NSLog(@"Clicked island image at index %i named %@ ", indx, article.title);
        
        [self elementTapped:article];
    }
}

-(id) doCreateIslandViewController:(int)ctgId {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.frame = CGRectMake(island_width * islands_count, 0, island_width, island_height);
    
    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
    self.islandsContent = [appHelper paidArticlesOfCategory:ctgId lang:appHelper.currentLang];

    for (int i = 0; i < self.islandsContent.count; i++) {
        Article *article = self.islandsContent[i];
        [vc.view addSubview:[self doCreateItem:article tag:i]];
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

-(void) showIslandMenu:(id)fromView ofCategory:(int)ctgId{
    CGRect mmfrm = self.mmView.frame;
    islands_count = 3;

    //the popover will be presented to a point relative to mmview
    CGPoint pnt;

    if (UIInterfaceOrientationIsPortrait(INTERFACE_ORIENTATION)) {
        CGFloat ratio = mmfrm.size.width / mmfrm.size.height;
        island_width = (mmfrm.size.width / 3) - 8;
        island_height = island_width / ratio;

        pnt = CGPointMake(mmfrm.origin.x + 2,
                          self.view.frame.origin.y + mmfrm.origin.y + (mmfrm.size.height / 3) * 2.1);
    } else {
        island_width = mmfrm.size.width / 3;
        island_height = mmfrm.size.height / 3;

        pnt = CGPointMake(mmfrm.origin.x + island_width * 2,
                                  self.view.frame.origin.y + mmfrm.origin.y + (mmfrm.size.height / 3) * 2.1);
    }
    
    //the view controller you want to present as popover
    if (!self.islandPopupViewController)
        self.islandPopupViewController = [self doCreateIslandViewController:ctgId];
    
    self.islandPopupViewController.title = nil;

    //our popover
    self.popController = [[FPPopoverController alloc]
                                    initWithViewController:self.islandPopupViewController];
    self.popController.delegate = self;
    self.popController.border = YES;
    self.popController.contentSize = CGSizeMake(island_width * 3 + 20, island_height + 40);
    self.popController.arrowDirection = FPPopoverArrowDirectionDown;//FPPopoverArrowDirectionDown | FPPopoverArrowDirectionRight;
    
    //[self.popoverController presentPopoverFromPoint:pnt];
    [self.popController presentPopoverFromView:fromView];
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
