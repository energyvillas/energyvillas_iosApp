//
//  DPMenuViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/5/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMenuViewController.h"
#import "DPConstants.h"
#import "DPDataElement.h"
#import "DPCategoryViewController.h"
#import "DPAppHelper.h"

@interface DPMenuViewController ()

@property (strong, nonatomic) FPPopoverController *popController;
@property (strong, nonatomic) UIViewController *islandPopupViewController;
@property (strong, nonatomic) NSArray *islandsContent;

@end

@implementation DPMenuViewController {
        bool isPortrait;
    
//    int islands_count;
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

- (id) initWithRows:(int)rows
            columns:(int)columns
         autoScroll:(BOOL)autoscroll {
    self = [self initWithRows:rows
                      columns:columns
                   autoScroll:autoscroll
                    showPages:YES
              scrollDirection:DPScrollDirectionHorizontal];
    return self;
}

- (id) initWithRows:(int)rows
            columns:(int)columns
         autoScroll:(BOOL)autoscroll
          showPages:(BOOL)showpages
    scrollDirection:(DPScrollDirection)scrolldir {

    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    NSArray *content = [apphelper paidMenuOfCategory:-1
                                                lang:apphelper.currentLang];
    
    self = [super initWithContent:content
                       autoScroll:NO
                        showPages:showpages
                  scrollDirection:scrolldir];
    
    if (self) {
        self.scrollableViewDelegate = self;
        self.rowCount = rows;
        self.colCount = columns;
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

- (void) changeRows:(int)rows columns:(int)columns {
    [self clearPopups];
    [super changeRows:rows columns:columns];
}

- (void) clearPopups {
    if (self.popController) {
        [self.popController dismissPopoverAnimated:YES];
        self.popController = nil;
    }
    
    self.islandPopupViewController = nil;
    self.islandsContent = nil;
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutForOrientation:INTERFACE_ORIENTATION fixtop:YES];
}
- (void) layoutForOrientation:(UIInterfaceOrientation)toOrientation fixtop:(BOOL)fixtop {
    // dismiss popover since the positioning will be wrong
    [self clearPopups];

    //
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

    CGRect vf = self.view.frame;
//    int top = fixtop ? vf.origin.y : 0;
//    int h = (isPortrait ? vf.size.height : vf.size.height - vf.origin.y) - top;
//    int w = vf.size.width;
    int top = 0;
    int h = vf.size.height;//sv.bounds.size.height;
    int w = vf.size.width;//sv.bounds.size.width;
    int pgCtrlHeight = 36; //self.pageControl.frame.size.height;
    //self.view.frame = CGRectMake(0, 0, w, h);
    self.scrollView.frame = CGRectMake(0, top, w, h);
    self.pageControl.frame = CGRectMake(0, h + top - pgCtrlHeight, w, pgCtrlHeight);
    
    [self changeRows:self.rowCount columns:self.colCount];
}

- (void) elementTapped:(id)tappedelement {
    DPDataElement *element = tappedelement;
    if (element == nil) return;
    
    switch (element.Id) {
        case CTGID_ISLAND: {
            [self showIslandMenu:self.scrollView.subviews[3]
                      ofCategory:element.Id
                    islandsCount:3];
            break;
        }
            
        case CTGID_EXCLUSIVE:
            
            break;
            
        case CTGID_SMART:
        case CTGID_LOFT:
        case CTGID_FINLAND:
        case CTGID_COUNTRY:
        case CTGID_CONTAINER:
        case CTGID_VILLAS: {
            DPCategoryViewController *ctgVC = [[DPCategoryViewController alloc]
                                               initWithCategory:element.Id];
            [self.navigationController pushViewController:ctgVC animated:YES];
            
            break;
        }
            
        case CTGID_VIDEOS:
            
            break;
            
        case CTGID_ISLAND_AEGEAN:
            
            break;
            
        case CTGID_ISLAND_CYCLADIC:
            
            break;
            
        case CTGID_ISLAND_IONIAN:
            
            break;
            
        case CTGID_EXCLUSIVE_EXCLUSIVE:
            
            break;
            
        case CTGID_EXCLUSIVE_ART:
            
            break;
            
        default:
            break;
    }
}

- (void)handleIslandTap:(UITapGestureRecognizer *)sender {
    [self.popController dismissPopoverAnimated:YES];
    self.popController = nil;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        int indx = sender.view.tag;
        DPDataElement *element = self.islandsContent[indx];
        NSLog(@"Clicked island image at index %i named %@ ", indx, element.title);
        
        [self elementTapped:element];
    }
}

- (UIView *) doCreateItem:(DPDataElement *)element tag:(int)indx{
    int posX = self.scrollDirection == DPScrollDirectionHorizontal ? island_width * indx : 0;
    int posY = self.scrollDirection == DPScrollDirectionVertical ? island_height * indx : 0;
    CGRect frm = CGRectMake(posX, posY, island_width,  island_height);
    
    UIView *v = [[UIView alloc] initWithFrame: frm];
    v.clipsToBounds = YES;
    
    frm = CGRectMake(0, 0, island_width, island_height);
    UIImageView *iv = [[UIImageView alloc] initWithFrame: frm];
    iv.image = [UIImage imageNamed: element.imageUrl];
    iv.contentMode = UIViewContentModeScaleAspectFit; 
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
    lv.text = element.title;
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

-(id) doCreateIslandViewController:(int)ctgId islandsCount:(int)islandsCount frame:(CGRect)vframe {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.frame = vframe;
    
    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
    self.islandsContent = [appHelper paidMenuOfCategory:ctgId lang:appHelper.currentLang];
    
    for (int i = 0; i < self.islandsContent.count; i++) {
        DPDataElement *element = self.islandsContent[i];
        [vc.view addSubview:[self doCreateItem:element tag:i]];
    }
    
    return vc;
}

-(void) showIslandMenu:(id)fromView ofCategory:(int)ctgId islandsCount:(int)islandsCount {
    CGRect mmfrm = self.view.superview.frame;
    
    island_width = mmfrm.size.width / self.colCount;
    island_height = mmfrm.size.height / self.rowCount;
    CGFloat ratio = (1.0 * island_width) / island_height;
    island_width = island_width - 8;
    island_height = island_width / ratio;
    
    int width = island_width;
    int height = island_height;
    if (self.scrollDirection == DPScrollDirectionHorizontal)
        width = width * islandsCount;
    else
        height = height * islandsCount;
    
    CGRect frame = CGRectMake(0, //island_width * islandsCount,
                              0,
                              width,//island_width,
                              height);//island_height);

    //the view controller you want to present as popover
    if (!self.islandPopupViewController)
        self.islandPopupViewController = [self doCreateIslandViewController:ctgId
                                                               islandsCount:islandsCount
                                                                      frame:frame];
    
    self.islandPopupViewController.title = nil;
    
    //our popover
    self.popController = [[FPPopoverController alloc]
                          initWithViewController:self.islandPopupViewController];
    self.popController.delegate = self;
    self.popController.border = YES;
    if (self.scrollDirection == DPScrollDirectionHorizontal) {
        self.popController.arrowDirection = FPPopoverArrowDirectionDown;
        self.popController.contentSize = CGSizeMake(frame.size.width + 20, frame.size.height + 40);
    } else {
        self.popController.arrowDirection = FPPopoverArrowDirectionRight;
        self.popController.contentSize = CGSizeMake(frame.size.width + 40, frame.size.height + 80);

    }
    
    [self.popController presentPopoverFromView:fromView];
}


- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    
}



@end
