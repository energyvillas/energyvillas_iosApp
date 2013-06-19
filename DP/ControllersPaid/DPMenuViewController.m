//
//  DPMenuViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/5/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMenuViewController.h"
#import "DPConstants.h"
#import "Category.h"
#import "DPDataElement.h"
#import "DPCategoryViewController.h"
#import "DPAppHelper.h"
#import "DPButton.h"
#import "UIImage+FX.h"

@interface DPMenuViewController ()

@property (strong, nonatomic) FPPopoverController *popController;
@property (strong, nonatomic) UIViewController *islandPopupViewController;
@property (strong, nonatomic) NSArray *islandsContent;

@end

@implementation DPMenuViewController {
    int menulevel;
    int island_width;
    int island_height;
    int activeMenuID;
}

@synthesize currentMenuPage = _currentMenuPage;



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
         autoScroll:(BOOL)autoscroll
          showPages:(BOOL)showpages
    scrollDirection:(DPScrollDirection)scrolldir
          menulevel:(int)level
        initialPage:(int)initialPage
         activeMenu:(int)ctgID {

    menulevel = level;
    activeMenuID = ctgID;
    
    self = [super initWithContent:[DPMenuViewController loadMenuData]
                             rows:rows
                          columns:columns
                       autoScroll:NO
                        showPages:showpages
                  scrollDirection:scrolldir
                      initialPage:initialPage];
    
    if (self) {
        self.scrollableViewDelegate = self;
        self.dataDelegate = self;
    }
    
    return self;
}

- (void) dealloc {
    self.popController = nil;
    self.islandPopupViewController = nil;
    self.islandsContent = nil;
}

+ (NSArray *) loadMenuData {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    NSArray *content = [apphelper paidMenuOfCategory:-1
                                                lang:apphelper.currentLang];
    return content;
}

- (void) doLocalize {
    [super doLocalize];
    NSArray *lst = [DPMenuViewController loadMenuData];    
    [self contentLoaded:lst];
    [self changeRows:self.rowCount columns:self.colCount scrollDirection:self.scrollDirection];
}

- (void) scrolledToPage:(int)newPage fromPage:(int)oldPage {
    _currentMenuPage = newPage;
    NSLog(@"scrolledToPage:%d", _currentMenuPage);
}

- (int) getCurrentMenuPage {
    return _currentMenuPage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPAID_SelectedCategoryChanged_Notification
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
//                                                                                               forKey:@"menuCategory"]];
//    });
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearPopups];
    
//    if (menulevel == 1)
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPAID_SelectedCategoryChanged_Notification
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
//                                                                                               forKey:@"menuCategory"]];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self clearPopups];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeRows:(int)rows columns:(int)columns {
    // dismiss popover since the positioning will be wrong
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

/*
//- (void) doLayoutSubviews:(BOOL)fixtop {
//   
////    CGRect vf = self.view.frame;
////    int h = vf.size.height;//sv.bounds.size.height;
////    int w = vf.size.width;//sv.bounds.size.width;
//    //self.view.frame = CGRectMake(0, 0, w, h);
////    self.scrollView.frame = CGRectMake(0, 0, w, h);
////    self.pageControl.frame = CGRectMake(0, h - PAGE_CONTROL_HEIGHT, w, PAGE_CONTROL_HEIGHT);
//    
//    [self changeRows:self.rowCount columns:self.colCount];
//}
*/

- (void) elementTapped:(id)sender element:(id)tappedelement {
    DPDataElement *element = tappedelement;
    if (element == nil) return;
    
    switch (element.Id) {
        case CTGID_ISLAND: {
            [self showIslandMenu:self.scrollView.subviews[3]
                      ofCategory:element.Id
                    islandsCount:3];
            break;
        }
            
        case CTGID_EXCLUSIVE:{
            [self showIslandMenu:self.scrollView.subviews[6]
                      ofCategory:element.Id
                    islandsCount:2];
            break;
        }
            
        case CTGID_SMART:
        case CTGID_LOFT:
        case CTGID_FINLAND:
        case CTGID_COUNTRY:
        case CTGID_CONTAINER:
        case CTGID_VILLAS:

        case CTGID_ISLAND_AEGEAN:
        case CTGID_ISLAND_CYCLADIC:
        case CTGID_ISLAND_IONIAN:
        
        case CTGID_EXCLUSIVE_DESIGNER:
        case CTGID_EXCLUSIVE_ART:

        case CTGID_VIDEOS:{
//            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:element.Id]
                                                                                                       forKey:@"menuCategory"]];
//            });

            if (menulevel == 0) {
                DPCategoryViewController *ctgVC = [[DPCategoryViewController alloc]
                                                   initWithCategory:element.Id];
                [self.navigationController pushViewController:ctgVC animated:YES];
            } else {
                UIViewController *top = [self.navigationController topViewController];
                if ([top isKindOfClass:[DPCategoryViewController class]])
                    [((DPCategoryViewController *)top) showCategory:element.Id];
            }
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - START :: DPScrollableDataSourceDelegate
-(NSString *) resolveImageName:(DPDataElement *)elm {
    return [self calcImageName:elm isHighlight:NO];
}
-(NSString *) resolveHighlightImageName:(DPDataElement *)elm {
    return [self calcImageName:elm isHighlight:YES];
}
//- (NSString *) calcImageName:(NSString *)baseName {
//    return [self calcImageName:baseName isHighlight:NO];
//}
- (NSString *) calcImageName:(DPDataElement *)elm isHighlight:(BOOL)ishighlight {
    @try {
#ifdef LOG_MENU
        NSLog(@"Menu - calcImageName - baseName='%@'", elm.imageUrl);
#endif
        NSArray *parts = [elm.imageUrl componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *result = elm.imageUrl;
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";            
            NSString *high = ishighlight ? @"_roll" : @"";

            if (menulevel == 0)
                result = [NSString stringWithFormat:@"MainMenu/main_menu_%@_%@%@.%@",
                                    orientation, parts[0], high, parts[1]];
            else
                result = [NSString stringWithFormat:@"MenuLevel1/menu_level-1_%@_%@%@.%@",
                          orientation, parts[0], high, parts[1]];

            return result;
        }
        else
            return elm.imageUrl;
    }
    @catch (NSException* exception) {
        return elm.imageUrl;
    }
}

- (void) updateHighlightsInView:(UIView *)v isExclusive:(BOOL)isexcl {
    if ([v isKindOfClass:[DPButton class]]) {
        ((DPButton *)v).showExtraLayerOnHighlight = !isexcl;
    } else
        for (UIView *sv in v.subviews)
            [self updateHighlightsInView:sv isExclusive:isexcl];
}

- (void) updateHighlights:(int)activemenu {
    activeMenuID = activemenu;
    BOOL isExclusive = activeMenuID == CTGID_EXCLUSIVE_ART || activeMenuID == CTGID_EXCLUSIVE_DESIGNER;
    for (UIView *v in self.scrollView.subviews)
        [self updateHighlightsInView:v isExclusive:isExclusive];
}

- (UIView *) createViewFor:(int)contentIndex
                     frame:(CGRect)frame {
    DPDataElement *element = self.contentList[contentIndex];
    
    NSString *imgname =[self resolveImageName:element];
    UIImage *img = [UIImage imageNamed:imgname];
    NSString *imgnameHigh =[self resolveHighlightImageName:element];
    UIImage *imgHigh = [UIImage imageNamed:imgnameHigh];
    
    
    UIButton *button = nil;
    if (imgHigh)
        button = [UIButton buttonWithType:UIButtonTypeCustom];
    else {
        button = [DPButton buttonWithType:UIButtonTypeCustom];
        if (menulevel == 0)
            ((DPButton *)button).showExtraLayerOnHighlight = YES;
        else {
            BOOL isExclusive = activeMenuID == CTGID_EXCLUSIVE_ART || activeMenuID == CTGID_EXCLUSIVE_DESIGNER;
            ((DPButton *)button).showExtraLayerOnHighlight = !isExclusive;
        }
    }
    
    [button setTag: contentIndex];
    [button addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];

    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = NO;
    button.contentMode = UIViewContentModeCenter;
    
    if (menulevel == 0) {
        if (IS_IPHONE) {
            button.frame = IS_PORTRAIT ? CGRectInset(frame, 3.0f, 3.0f) : CGRectInset(frame, 2.0f, 2.0f);
            button.layer.borderWidth = 1.0f;
        } else if (IS_IPHONE_5) {
            button.frame = IS_PORTRAIT ? CGRectInset(frame, 3.0f, 5.0f) : CGRectInset(frame, 4.0f, 3.0f);
            button.layer.borderWidth = 1.0f;
        } else {
            button.frame = IS_PORTRAIT ? CGRectInset(frame, 5.0f, 6.0f) : CGRectInset(frame, 5.0f, 7.0f);
            button.layer.borderWidth = 1.5f;
        }
    } else {
        CGSize imgsz = CGSizeZero;
        
        if (IS_IPHONE) {
            button.frame = IS_PORTRAIT ? CGRectInset(frame, 3.0f, 2.0f) : CGRectInset(frame, 3.0f, 3.0f);
            button.layer.borderWidth = 1.0f;
            imgsz = CGRectInset(button.frame, button.layer.borderWidth + 3.0,
                                button.layer.borderWidth + 2.0).size;
        } else if (IS_IPHONE_5) {
            button.frame = IS_PORTRAIT ? CGRectInset(frame, 3.0f, 3.0f) : CGRectInset(frame, 3.0f, 3.0f);
            button.layer.borderWidth = 1.0f;
            imgsz = CGRectInset(button.frame, button.layer.borderWidth + 4.0,
                                button.layer.borderWidth + 2.0).size;
        } else {
            button.frame = IS_PORTRAIT ? CGRectInset(frame, 3.0f, 4.0f) : CGRectInset(frame, 2.0f, 5.0f);
            button.layer.borderWidth = 2.0f;
            
            imgsz = CGRectInset(button.frame, button.layer.borderWidth + 10.0,
                                button.layer.borderWidth + 2.0).size;
        }
        
        if (img)
            img = [img imageScaledToFitSize:imgsz];
        if (imgHigh)
            imgHigh = [imgHigh imageScaledToFitSize:imgsz];
    }

    button.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;

    if (img) [button setImage:img forState:UIControlStateNormal];
    if (imgHigh) [button setImage:imgHigh forState:UIControlStateHighlighted];
    

    return button;
}

- (void) onTap:(id)sender {
    int indx = ((UIButton *)sender).tag;
    DPDataElement * element = self.contentList[indx];
#ifdef LOG_MENU
    NSLog(@"Clicked image at index %i named %@", indx, element.title);
#endif
    
    [self elementTapped:sender element:element];
    
    // navigation logic goes here. create and push a new view controller;
    //        DPTestViewController *vc = [[DPTestViewController alloc] init];
    //        [self.navigationController pushViewController: vc animated: YES];
    
}

/**/
- (UILabel *) createLabelFor:(int)contentIndex
                       frame:(CGRect)frame
                       title:(NSString *)title {
    UIFont *fnt = nil;
    if (IS_IPAD)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size: IS_PORTRAIT ? 16 : 15.0f]; //HelveticaNeue-CondensedBold"
    else  if (IS_IPHONE)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size: IS_PORTRAIT ? 8.7f : 8.4f];
    else
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:8.0f];
    UILabel *label = createLabel(frame, title, fnt);
    int offsetV = [self calcLabelOffset];
    label.frame = CGRectOffset(label.frame, 0, offsetV);
    return label;
}
/**/

-(int) calcLabelOffset {
    switch (menulevel) {
        case 0:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? -6 : -5;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? -16 : -4;
            } else {
                return IS_PORTRAIT ? -15 : -27;
            }
            break;
            
        case 1:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? -9 : -5;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? -9 : -5;
            } else {
                return IS_PORTRAIT ? -24 : -26;
            }
            break;
    }
    
    return 0;
}

#pragma END :: DPScrollableDataSourceDelegate

#pragma mark - START :: island's and exclusive popover sbmenus
//- (void)handleIslandTap:(UITapGestureRecognizer *)sender {
//    [self.popController dismissPopoverAnimated:YES];
//    self.popController = nil;
//    
//    if (sender.state == UIGestureRecognizerStateEnded) {
//        // handling code
//        int indx = sender.view.tag;
//        DPDataElement *element = self.islandsContent[indx];
//#ifdef LOG_MENU
//        NSLog(@"Clicked island image at index %i named %@ ", indx, element.title);
//#endif
//        [self elementTapped:nil element:element];
//    }
//}
- (void)handleIslandTap:(UIButton *)sender {
    [self.popController dismissPopoverAnimated:YES];
    self.popController = nil;
    
    // handling code
    int indx = sender.tag;
    DPDataElement *element = self.islandsContent[indx];
#ifdef LOG_MENU
    NSLog(@"Clicked island image at index %i named %@ ", indx, element.title);
#endif
    [self elementTapped:nil element:element];
}

- (UIView *) doCreateItem:(DPDataElement *)element tag:(int)indx{
    int posX = 0, posY = 0;
    if (menulevel == 0 && IS_LANDSCAPE) {
        posX = 0;
        posY = island_height * indx;
    } else {
        posX = self.scrollDirection == DPScrollDirectionHorizontal ? island_width * indx : 0;
        posY = self.scrollDirection == DPScrollDirectionVertical ? island_height * indx : 0;
    }
    
    CGRect frm = CGRectMake(posX, posY, island_width,  island_height);
    
    UIView *v = [[UIView alloc] initWithFrame: frm];
    v.clipsToBounds = YES;
    
    NSString *imgname =[self resolveImageName:element];

    frm = CGRectMake(0, 0, island_width, island_height);
//    UIImageView *iv = [[UIImageView alloc] initWithFrame: frm];
//    iv.image = [UIImage imageNamed:imgname];
//    iv.contentMode = UIViewContentModeScaleAspectFit; 
//    iv.tag = indx;
//    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
//                                      initWithTarget:self action:@selector(handleIslandTap:)];
//    [iv addGestureRecognizer:tapper];
//    iv.userInteractionEnabled = YES;
    UIView *bv = nil;
    if (((Category *)element).parentId == CTGID_ISLAND) {
        UIButton *btnview = [UIButton buttonWithType:UIButtonTypeCustom];
        btnview.frame = frm;
        btnview.contentMode = UIViewContentModeScaleAspectFit;
        btnview.backgroundColor = [UIColor clearColor];
        btnview.tag = indx;
        [btnview addTarget:self action:@selector(handleIslandTap:) forControlEvents:UIControlEventTouchUpInside];
//        btnview.extraLayerColor = [UIColor colorWithWhite:0.0f alpha:0.15f];
//        btnview.showExtraLayerOnHighlight = YES;
        [btnview setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal];
        bv = btnview;
    } else { // these are the exclusives
        UIButton *btnview = [UIButton buttonWithType:UIButtonTypeCustom];
        btnview.frame = frm;
        btnview.contentMode = UIViewContentModeScaleAspectFit;
        btnview.backgroundColor = [UIColor clearColor];
        btnview.tag = indx;
        [btnview addTarget:self action:@selector(handleIslandTap:) forControlEvents:UIControlEventTouchUpInside];
        [btnview setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal];
        NSString *imgnamehigh =[self resolveHighlightImageName:element];
        [btnview setImage:[UIImage imageNamed:imgnamehigh] forState:UIControlStateHighlighted];
        bv = btnview;
    }
    
    UILabel *lv = [[UILabel alloc] initWithFrame: frm];
    lv.textAlignment = NSTextAlignmentCenter;
    
    UIFont *fnt = nil;
    if (IS_IPAD)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:19]; //HelveticaNeue-CondensedBold"
    else  if (IS_IPHONE)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:9];
    else
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10.0f];

    lv.font = fnt;
//    if (IS_IPAD)
//        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
//    else
//        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    lv.adjustsFontSizeToFitWidth = YES;
    lv.text = element.title;
    lv.backgroundColor = [UIColor clearColor];
    lv.textColor = [UIColor whiteColor];
    [lv sizeToFit];
    CGRect b = lv.bounds;
    int offsetV = [self calcPopupLabelOffset];
    frm = CGRectMake(frm.origin.x, frm.origin.y + offsetV,
                     frm.size.width, b.size.height);
    lv.frame = frm;
    
//    [v addSubview:iv];
    [v addSubview:bv];
    [v addSubview:lv];
    
    return v;
}

-(int) calcPopupLabelOffset {
    switch (menulevel) {
        case 0:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? 2 : 2;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? 2 : 2;
            } else {
                return IS_PORTRAIT ? 6 : 6;
            }
            break;
            
        case 1:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? 2 : 2;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? 2 : 2;
            } else {
                return IS_PORTRAIT ? 6 : 6;
            }
            break;
    }
    
    return 0;
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
    [self clearPopups];
    CGRect mmfrm = self.view.superview.frame;
    
    island_width = mmfrm.size.width / self.colCount;
    island_height = mmfrm.size.height / self.rowCount;
    CGFloat ratio = (1.0 * island_width) / island_height;
    island_width = island_width - 7;
    island_height = island_width / ratio;
    
    int width = island_width;
    int height = island_height;
    if (menulevel == 0) {
        width = IS_PORTRAIT ? width * islandsCount : width;
        height = IS_PORTRAIT ? height : height * islandsCount;
    } else {
        if (self.scrollDirection == DPScrollDirectionHorizontal)
            width = width * islandsCount;
        else
            height = height * islandsCount;
    }
    
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
    self.popController.tint = FPPopoverBlackTint;
    if (menulevel == 0) {
        if (IS_PORTRAIT) {
            self.popController.arrowDirection = FPPopoverArrowDirectionDown;
            self.popController.contentSize = CGSizeMake(frame.size.width + 20, frame.size.height + 40);
        } else {
            self.popController.arrowDirection = FPPopoverArrowDirectionLeft;
            self.popController.contentSize = CGSizeMake(frame.size.width + 40,
                                                        frame.size.height + (islandsCount == 3 ? 20 : 20));
        }
    } else {
        if (self.scrollDirection == DPScrollDirectionHorizontal) {
            self.popController.arrowDirection = FPPopoverArrowDirectionDown;
            self.popController.contentSize = CGSizeMake(frame.size.width + 20, frame.size.height + 40);
        } else {
            self.popController.arrowDirection = FPPopoverArrowDirectionRight;
            self.popController.contentSize = CGSizeMake(frame.size.width + 40,
                                                        frame.size.height +
                                                        (islandsCount == 3 ? (IS_IPAD ? 250 : 80): (IS_IPAD ? 40 : 20)));
        }
    }
    
    if (menulevel == 0) {
        if (IS_PORTRAIT)
            [self.popController presentPopoverFromView:fromView];
        else {
            CGPoint p = CGPointZero;
            
            if (!IS_IPAD)
                p = CGPointMake(mmfrm.origin.x + island_width,
                                mmfrm.origin.y + island_height * (islandsCount == 3 ? 2.3 : 3.3));
            else
                p = CGPointMake(mmfrm.origin.x + island_width,
                                mmfrm.origin.y + island_height * (islandsCount == 3 ? 1.9 : 2.4));
            
            [self.popController presentPopoverFromPoint:p];
        }
    } else {
        if (IS_PORTRAIT) {
            CGPoint p = CGPointMake(mmfrm.origin.x + (island_width / 2.0),
                                    mmfrm.origin.y + (island_height / 2.0) + (IS_IPAD ? -45.0: 10.0));
            [self.popController presentPopoverFromPoint:p];
        } else {
            CGPoint p = CGPointMake(mmfrm.origin.x + 10.0, mmfrm.origin.y + island_height);
            [self.popController presentPopoverFromPoint:p];
        }
    }
}


- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    
}
#pragma END :: islands and exclusive popover sbmenus



@end
